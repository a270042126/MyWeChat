//
//  WCBaseLoginController.swift
//  MyWeChat
//
//  Created by GDG on 15/12/30.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

class WCBaseLoginController: UIViewController {
    
    var HUD:MBProgressHUD?
    
    
    //子类调用
    func login(){
        self.view.endEditing(true)
        
        HUD = MBProgressTool.showMessWithLoad("正在登陆中...", self.view.window)
        WCXMPPTool.sharedInstance.registerOperation = false
        WCXMPPTool.sharedInstance.xmppUserLogin { [unowned self] (type) -> Void in
            self.handleResultType(type)
        }
    }
    
    private func handleResultType(type:XMPPResultType){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.HUD?.hide(true)
            switch(type){
            case .LoginSuccess:
                NSLog("登陆成功")
                self.enterMainPage()
                break
            case.LoginFailure:
                NSLog("登陆失败")
                MBProgressTool.showMessWithErr("用户名或者密码不正确",self.view.window)
                break
                
            default:
                MBProgressTool.showMessWithErr("网络不给力",self.view.window)
                break
            }
        }
    }
    
    private func enterMainPage(){
        WCUserInfo.sharedInstance.loginStatus = true
        WCUserInfo.sharedInstance.saveUserInfoToSanbox()
        //隐藏模态窗口
        self.dismissViewControllerAnimated(false, completion: nil)
        UIStoryboard.showInitialVCWithName("Main")
    }

}
