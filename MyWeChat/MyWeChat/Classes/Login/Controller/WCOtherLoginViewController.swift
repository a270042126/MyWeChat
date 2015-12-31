//
//  WCOtherLoginViewController.swift
//  MyWeChat
//
//  Created by GDG on 15/12/30.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

class WCOtherLoginViewController: WCBaseLoginController {
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rigthContraint: NSLayoutConstraint!
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "其他方式登录"
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone{
            leftConstraint.constant = 10
            rigthContraint.constant = 10
        }
        
        self.userField.background = UIImage.stretchedImageWithName("operationbox_text")
        self.pwdField.background = UIImage.stretchedImageWithName("operationbox_text")
        self.pwdField.addLeftViewWithImage("Card_Lock")
        self.loginBtn.setResizedN_BG("fts_green_btn", hbg: "fts_green_btn_HL")
    }

    
    @IBAction func loginClick(sender: UIButton) {
        let userInfo = WCUserInfo.sharedInstance
        userInfo.user = self.userField.text
        userInfo.pwd = self.pwdField.text
        super.login()
    }

    @IBAction func cancelClick(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   

}
