//
//  WCChatViewController.swift
//  MyWeChat
//
//  Created by GDG on 16/1/4.
//  Copyright © 2016年 MyWeChat. All rights reserved.
//

import UIKit

class WCChatViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,NSFetchedResultsControllerDelegate {
    
    var friendJid:XMPPJID!
    private var resultsContrl:NSFetchedResultsController!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var bottomConstatint: NSLayoutConstraint!
    
    private lazy var httpTool:HttpTool = {
        return HttpTool()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMsgs()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    private func loadMsgs(){
        
        // 上下文
        let context = WCXMPPTool.sharedInstance.msgStorage?.mainThreadManagedObjectContext
        // 请求对象
        let request = NSFetchRequest(entityName: "XMPPMessageArchiving_Message_CoreDataObject")
        // 过滤、排序
        // 1.当前登录用户的JID的消息
        // 2.好友的Jid的消息
        let pre = NSPredicate(format: "streamBareJidStr = %@ AND bareJidStr = %@", WCUserInfo.sharedInstance.jid,friendJid.bare())
        NSLog("%@",pre)
        request.predicate = pre
        
        // 时间升序
        let timeSort = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [timeSort]
        
        //查询
        resultsContrl = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
        resultsContrl?.delegate = self
        do{
            try resultsContrl.performFetch()
        }catch{
            NSLog("\(error)")
        }
        
        NSLog("%@",resultsContrl.fetchedObjects!)
        
    }
    
    func keyboardWillShow(notification:NSNotification){
        let kbEndFrm = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        
        let kbHeight = kbEndFrm.size.height
        //竖屏{{0, 0}, {768, 264}
        //横屏{{0, 0}, {352, 1024}}
        // 如果是ios7以下的，当屏幕是横屏，键盘的高底是size.with
//        if([[UIDevice currentDevice].systemVersion doubleValue] < 8.0
//            && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
//                kbHeight = kbEndFrm.size.width;
//        }
        
        self.bottomConstatint.constant = kbHeight
        scrollToTableBottom()
        
    }
    
    func keyboardWillHide(notification:NSNotification){
        self.bottomConstatint.constant = 0
        
    }
    
    //MARK: - 选择图片
    @IBAction func btnClick(sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //选取后图片的回调
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        NSLog("%@",info)
        self.dismissViewControllerAnimated(true, completion: nil)
         // 获取图片
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        // 把图片发送到文件服务器
        //http post put
        /**
        * put实现文件上传没post那烦锁，而且比POST快
        * put的文件上传路径就是下载路径
        
        *文件上传路径 http://localhost:8080/imfileserver/Upload/Image/ + "图片名【程序员自已定义】"
        */
        
        // 1.取文件名 用户名 + 时间(201412111537)年月日时分秒
        let user = WCUserInfo.sharedInstance.user
        let dataFormatter = NSDateFormatter()
        dataFormatter.dateFormat = "yyyyMMddHHmmss"
        let timeStr = dataFormatter.stringFromDate(NSDate())
        // 针对我的服务，文件名不用加后缀
        let fileName = user!.stringByAppendingString(timeStr)
        // 2.拼接上传路径
        let uploadUrl = "http://localhost:8080/imfileserver/Upload/Image/".stringByAppendingString(fileName)
        // 3.使用HTTP put 上传 图片上传请使用jpg格式 因为我写的服务器只接接收jpg
        self.httpTool.uploadData(UIImageJPEGRepresentation(image, 0.75), url: NSURL(string: uploadUrl), progressBlock: nil) { (error) -> Void in
            if(error != nil){
                 NSLog("上传成功")
                self.sendMsgWithText(uploadUrl, bodyType: "image")
            }
        }
        // 图片发送成功，把图片的URL传Openfire的服务
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsContrl.fetchedObjects!.count
    }
    
    private struct Static{
        static let CellID = "ChatCell"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Static.CellID, forIndexPath: indexPath)
        // 获取聊天消息对象
        let msg = resultsContrl.fetchedObjects![indexPath.row] as? XMPPMessageArchiving_Message_CoreDataObject
        // 判断是图片还是纯文本
        let chatType = msg?.message.attributeStringValueForName("bodyType")
        
        if chatType == "image" {
         //下图片显示
            cell.imageView?.sd_setImageWithURL(NSURL(string: msg!.body), placeholderImage: UIImage(named: "DefaultProfileHead_qq"))
            cell.textLabel?.text = ""
            
        }else if chatType == "text" {
            //显示消息
            if msg!.outgoing.boolValue {//自己发
                cell.textLabel?.text = String(format: "Me: %@", msg!.body)
            }else {//别人发的
                cell.textLabel?.text = String(format: "Other: %@", msg!.body)
            }
            
            cell.imageView?.image = nil
        }else if chatType == nil{
            cell.textLabel?.text = msg?.body
        }
        
        return cell
    }
    
    //MARK: - ResultController
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        NSLog("controllerDidChangeContent数据发生改变")
        tableView.reloadData()
        scrollToTableBottom()
    }
    
    
    
    private func scrollToTableBottom(){
        let lastRow = resultsContrl.fetchedObjects!.count - 1
        if(lastRow < 0){
            return
        }
        let lastPath = NSIndexPath(forRow: lastRow, inSection: 0)
        self.tableView.scrollToRowAtIndexPath(lastPath, atScrollPosition: .Bottom, animated: true)
    }
    
    func textViewDidChange(textView: UITextView) {
        let contentH = textView.contentSize.height
        NSLog("textView的content的高度 %f",contentH)
        // 大于33，超过一行的高度/ 小于68 高度是在三行内
        if contentH > 33 && contentH < 68 {
            textView.frame.size.height = contentH + 18
        }
        
        var text = textView.text
        // 换行就等于点击了的send
        if (text.rangeOfString("\n") != nil) {
            NSLog("发送数据 %@",textView.text!)
            
            //去除换行字符
            text = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.sendMsgWithText(text, bodyType: "text")
            //清空数据
            textView.text = "";
            textView.frame.size.height = 30
        }else{
            NSLog("%@",textView.text)
        }
    }
    
    //发送聊天消息
    private func sendMsgWithText(text:String,bodyType:String){
        let msg = XMPPMessage(type: "chat", to: self.friendJid)
        //text 纯文本
        //image 图片
        msg.addAttributeWithName("bodyType", stringValue: bodyType)
        //设置内容
        msg.addBody(text)
        NSLog("%@",msg)
        WCXMPPTool.sharedInstance.xmppStream?.sendElement(msg)
    }
    

}
