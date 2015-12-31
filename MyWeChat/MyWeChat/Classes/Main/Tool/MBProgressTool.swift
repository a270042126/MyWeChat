//
//  MBProgressTool.swift
//  MyWeChat
//
//  Created by GDG on 15/12/30.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

class MBProgressTool: NSObject {
    
    class func showMessWithErr(mes:String,_ view:UIView?) -> MBProgressHUD{
        let HUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        HUD?.mode = .CustomView
        HUD?.customView = UIImageView(image: UIImage(named: "error"))
        HUD?.labelText = mes
        HUD?.removeFromSuperViewOnHide = true
        HUD?.show(true)
        HUD?.hide(true, afterDelay: 2)
        return HUD
    }
    
    class func showMessWithLoad(mes:String, _ view:UIView?) -> MBProgressHUD{
        let HUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        HUD?.labelText = mes
        HUD.removeFromSuperViewOnHide = true
        return HUD
    }
    
    class func showMessWithSuccess(mes:String,_ view:UIView?) -> MBProgressHUD{
        let HUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        HUD?.mode = .CustomView
        HUD?.customView = UIImageView(image: UIImage(named: "37x-Checkmark.png"))
        HUD?.labelText = mes
        HUD?.removeFromSuperViewOnHide = true
        HUD?.show(true)
        HUD?.hide(true, afterDelay: 2)
        return HUD
    }
    
    class func showMessWithTextOnly(mes:String,_ view:UIView?) -> MBProgressHUD{
        let HUD = MBProgressHUD(view: view)
        HUD.mode = .Text
        HUD.labelText = mes
        HUD.margin = 10
        HUD.removeFromSuperViewOnHide = true
        HUD.hide(true, afterDelay: 2)
        return HUD
    }
}
