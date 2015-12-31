//
//  WCLoginViewController.swift
//  MyWeChat
//
//  Created by GDG on 15/12/30.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

class WCLoginViewController: WCBaseLoginController,WCRegisgerViewControllerDelegate {

    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rigthContraint: NSLayoutConstraint!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone{
            leftConstraint.constant = 10
            rigthContraint.constant = 10
        }
        
        self.pwdField.background = UIImage.stretchedImageWithName("operationbox_text")
        self.pwdField.addLeftViewWithImage("Card_Lock")
        self.loginBtn.setResizedN_BG("fts_green_btn", hbg: "fts_green_btn_HL")
        
        if let user = WCUserInfo.sharedInstance.user{
            self.userLabel.text = user
        }
        
    }

    @IBAction func loginBtnClick(sender: UIButton) {
        let userInfo = WCUserInfo.sharedInstance
        userInfo.user = self.userLabel.text
        userInfo.pwd = self.pwdField.text
        super.login()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoRegister"{
            let destVc = segue.destinationViewController
            if destVc.isKindOfClass(WCNavigationController){
                let nav = destVc as! WCNavigationController
                if nav.topViewController!.isKindOfClass(WCRegisgerViewController){
                    let registerVc = nav.topViewController as! WCRegisgerViewController
                    registerVc.delegate = self
                }
            }
        }
    }
    
    //MARK: - WCRegisgerViewControllerDelegate
    func regisgerViewControllerDidFinishRegister() {
        NSLog("完成注册")
        self.userLabel.text = WCUserInfo.sharedInstance.registerUser
        MBProgressTool.showMessWithSuccess("请重新输入密码进行登录", self.navigationController?.view)
    }

    

}
