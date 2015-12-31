//
//  WCRegisgerViewController.swift
//  MyWeChat
//
//  Created by GDG on 15/12/30.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

protocol WCRegisgerViewControllerDelegate:class{
    func regisgerViewControllerDidFinishRegister()
}

class WCRegisgerViewController: UIViewController {

    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    weak var delegate:WCRegisgerViewControllerDelegate?
    private var HUD:MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "注册"
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone{
            self.leftConstraint.constant = 10
            self.rightConstraint.constant = 10
        }
        
        userField.background = UIImage.stretchedImageWithName("operationbox_text")
        pwdField.background = UIImage.stretchedImageWithName("operationbox_text")
        self.registerBtn.setResizedN_BG("fts_green_btn", hbg: "fts_green_btn_HL")
    }

    
    @IBAction func cancelClick(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func registerClick(sender: UIButton) {
        self.view.endEditing(true)
        
        if !userField.telphoneNum() {
            HUD = MBProgressTool.showMessWithErr("请输入正确的手机号码", self.navigationController?.view)
            return
        }
        
        let userInfo = WCUserInfo.sharedInstance
        userInfo.registerUser = userField.text
        userInfo.registerPwd = pwdField.text
        
        WCXMPPTool.sharedInstance.registerOperation = true
        HUD = MBProgressTool.showMessWithLoad("正在注册中", self.navigationController?.view)
        
        WCXMPPTool.sharedInstance.xmppUserRegister { [unowned self] (type) -> Void in
            self.handleResultType(type)
        }
    }
    
    private func handleResultType(type:XMPPResultType){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.HUD?.hide(true)
            
            switch(type){
            case .NetErr:
                MBProgressTool.showMessWithErr("网络不稳定", self.navigationController?.view)
                break
            case .RegisterSuccess:
                self.delegate?.regisgerViewControllerDidFinishRegister()
                self.dismissViewControllerAnimated(true, completion: nil)
                break
            case .RegisterFailure:
                MBProgressTool.showMessWithErr("注册失败，用户名重复", self.navigationController?.view)
            default:
                break
            }
        }
    }
    
    @IBAction func textChanged(sender: UITextField) {
        registerBtn.enabled = (userField.text?.characters.count > 0 && pwdField.text?.characters.count > 0)
    }

}
