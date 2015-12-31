//
//  WCNavigationController.swift
//  MyWeChat
//
//  Created by GDG on 15/12/29.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

class WCNavigationController: UINavigationController {

    //UINavigation Theme
    class func setupNavTheme(){
        
        let navBar = UINavigationBar.appearance()
        navBar.setBackgroundImage(UIImage(named: "topbarbg_ios7"), forBarMetrics: .Default)
        
        //设置字体
        var att = [String:AnyObject]()
        att[NSForegroundColorAttributeName] = UIColor.whiteColor()
        att[NSFontAttributeName] = UIFont.systemFontOfSize(20)
        navBar.titleTextAttributes = att
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
}
