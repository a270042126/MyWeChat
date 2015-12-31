//
//  UIStoryBoard+Extenstion.swift
//  MyWeChat
//
//  Created by GDG on 15/12/29.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    class func showInitialVCWithName(name:String){
        let storyboard = UIStoryboard(name: name, bundle: nil)
        UIApplication.sharedApplication().keyWindow?.rootViewController = storyboard.instantiateInitialViewController()
    }
    
    class func initialVcWithName(name:String) -> UIViewController?{
        let storyboard = UIStoryboard(name: name, bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
}
