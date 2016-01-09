//
//  WCProfileViewController.swift
//  MyWeChat
//
//  Created by GDG on 16/1/9.
//  Copyright © 2016年 MyWeChat. All rights reserved.
//

import UIKit

class WCProfileViewController: UITableViewController,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,WCEditProfileViewControllerDelegate{

    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var weixinNumLabel: UILabel!
    @IBOutlet weak var orgnameLabel: UILabel!
    @IBOutlet weak var orgunitLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "个人信息"
        loadVCard()
    }

    private func loadVCard(){
        //显示人个信息
        //xmpp提供了一个方法，直接获取个人信息
        let myVCard = WCXMPPTool.sharedInstance.vCard?.myvCardTemp
        // 设置头像
        if let photo = myVCard?.photo{
            self.headImage.image = UIImage(data: photo)
        }
        //设置昵称
        self.nickNameLabel.text = myVCard?.nickname
        //设置微信号
        self.weixinNumLabel.text = WCUserInfo.sharedInstance.user
        //公司
        orgnameLabel.text = myVCard?.orgName
        //部门
        if let units = myVCard?.orgUnits {
            if units.count > 0{
                 self.orgunitLabel.text = myVCard?.orgUnits[0] as? String
            }
        }
        //职位
        self.titleLabel.text = myVCard?.title
        //电话   myVCard.telecomsAddresses 这个get方法，没有对电子名片的xml数据进行解析
        self.phoneLabel.text = myVCard?.note // 使用note字段充当电话
        //邮件
        // 用mailer充当邮件
        //self.emailLabel.text = myVCard.mailer;
        //邮件解析
        if let emails = myVCard?.emailAddresses {
            if emails.count > 0{
                self.emailLabel.text = myVCard?.emailAddresses[0] as? String
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        //let tag = cell!.tag
        
        if indexPath.section == 0 && indexPath.row == 2{
            //不作任务操作
            NSLog("不作任务操作")
            return
        }
        
        if indexPath.section == 0 && indexPath.row == 0{
            NSLog("选择照片")
            
            
            let sheet = UIActionSheet(title: "请选择", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "照相", otherButtonTitles: "相册")
            sheet.showInView(self.view)
        }else{
            NSLog("跳到下一个控制器")
            self.performSegueWithIdentifier("EditVCardSegue", sender: cell)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditVCardSegue"{
            let destVC = segue.destinationViewController
            if destVC.isKindOfClass(WCEditProfileViewController) {
                let editVC = destVC as! WCEditProfileViewController
                editVC.cell = sender as? UITableViewCell
                editVC.delegate = self
            }
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        print(buttonIndex)
        
        if buttonIndex == 1{
            return;
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //允许编辑
        imagePicker.allowsEditing = true
        
        if(buttonIndex == 0){//照相
            imagePicker.sourceType = .Camera
        }else{
            imagePicker.sourceType = .PhotoLibrary
        }
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.headImage.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
        editProfileViewControllerDidSave()
    }
    
    func editProfileViewControllerDidSave() {
        //保存
        //获取当前的电子名片信息
        let myvCard = WCXMPPTool.sharedInstance.vCard?.myvCardTemp
        //图片
        myvCard?.photo = UIImageJPEGRepresentation(headImage.image!, 0.7)
        myvCard?.nickname = nickNameLabel.text
        myvCard?.orgName = orgnameLabel.text
        if orgunitLabel.text?.characters.count > 0 {
            myvCard?.orgUnits = [orgunitLabel.text!]
        }
        
        myvCard?.title = titleLabel.text
        myvCard?.note = phoneLabel.text
        if emailLabel.text?.characters.count > 0{
            myvCard?.emailAddresses = [emailLabel.text!]
        }
        //更新 这个方法内部会实现数据上传到服务，无需程序自己操作
        WCXMPPTool.sharedInstance.vCard?.updateMyvCardTemp(myvCard)
    }
   
}






