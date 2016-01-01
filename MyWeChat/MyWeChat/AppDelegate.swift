//
//  AppDelegate.swift
//  MyWeChat
//
//  Created by GDG on 15/12/29.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

   
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last
        NSLog("%@",path!)
        
        //设置导航栏样式
        WCNavigationController.setupNavTheme()
        
        WCUserInfo.sharedInstance.loadUserInfoFromSanbox()
        
        if WCUserInfo.sharedInstance.loginStatus{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.rootViewController = storyboard.instantiateInitialViewController()
            //1秒后再自动登录
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                WCXMPPTool.sharedInstance.xmppUserLogin(nil)
            }
        }
        
        //注册应用接收通知
        if Double(UIDevice.currentDevice().systemVersion) > 8.0{
            let settings = UIUserNotificationSettings(forTypes: [.Alert,.Sound,.Badge], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        
        return true
    }

  

}

