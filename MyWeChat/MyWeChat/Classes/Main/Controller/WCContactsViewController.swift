//
//  WCContactsViewController.swift
//  MyWeChat
//
//  Created by GDG on 15/12/30.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

class WCContactsViewController: UITableViewController,NSFetchedResultsControllerDelegate {
    
    private var resultsContrl:NSFetchedResultsController?
    private var friends:[AnyObject]?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadFriends2()
    }
    
    // 从数据里加载好友列表显示
    private func loadFriends2(){
        //使用CoreData获取数据
        // 1.上下文【关联到数据库XMPPRoster.sqlite】
        let context = WCXMPPTool.sharedInstance.rosterStorage?.mainThreadManagedObjectContext
        // 2.FetchRequest【查哪张表】
        let request = NSFetchRequest(entityName: "XMPPUserCoreDataStorageObject")
        // 3.设置过滤和排序
        // 过滤当前登录用户的好友
        let jid = WCUserInfo.sharedInstance.jid
        let pre = NSPredicate(format: "streamBareJidStr = %@", jid)
        request.predicate = pre
        
        //排序
        let sort = NSSortDescriptor(key: "displayName", ascending: true)
        request.sortDescriptors = [sort]
        
        // 4.执行请求获取数据
        resultsContrl = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
        resultsContrl?.delegate = self
        
        do{
            try resultsContrl?.performFetch()
        }catch{NSLog("\(error)")}
        
    }
    
    //当数据的内容发生改变后，会调用 这个方法
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        NSLog("数据发生改变")
        self.tableView.reloadData()
    }
    
//    private func loadFriends(){
//        //使用CoreData获取数据
//        // 1.上下文【关联到数据库XMPPRoster.sqlite】
//        let context = WCXMPPTool.sharedInstance.rosterStorage?.mainThreadManagedObjectContext
//        // 2.FetchRequest【查哪张表】
//        let request = NSFetchRequest(entityName: "XMPPUserCoreDataStorageObject")
//        
//        // 3.设置过滤和排序
//        // 过滤当前登录用户的好友
//        let jid = WCUserInfo.sharedInstance.jid
//        let pre = NSPredicate(format: "streamBareJidStr = %@", jid)
//        request.predicate = pre
//        
//        //排序
//        let sort = NSSortDescriptor(key: "displayName", ascending: true)
//        request.sortDescriptors = [sort]
//        
//        // 4.执行请求获取数据
//        do{
//              friends = try context?.executeFetchRequest(request)
//        }catch{}
//        
//    }

    private struct Static {
        static let CellID = "ContactCell"
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultsContrl!.fetchedObjects!.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Static.CellID, forIndexPath: indexPath)

        let friend = resultsContrl?.fetchedObjects?[indexPath.row]
        switch(friend!.sectionNum as Int){
        case 0:
            cell.detailTextLabel?.text = "在线"
            break
        case 1:
            cell.detailTextLabel?.text = "离开"
            break
        case 2:
            cell.detailTextLabel?.text = "离线"
            break
        default:
            break
        }
        cell.textLabel?.text = friend?.jidStr

        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            NSLog("删除好友")
            let friend = resultsContrl?.fetchedObjects?[indexPath.row]
            let friendJid = friend?.jid()
            WCXMPPTool.sharedInstance.roster?.removeUser(friendJid)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let friend = resultsContrl!.fetchedObjects![indexPath.row] as! XMPPUserCoreDataStorageObject
        self.performSegueWithIdentifier("gotoChat", sender: friend.jid)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoChat"{
            let destVC = segue.destinationViewController
            if destVC.isKindOfClass(WCChatViewController){
                let chatVC = destVC as! WCChatViewController
                chatVC.friendJid = sender as! XMPPJID
            }
        }
    }

}
