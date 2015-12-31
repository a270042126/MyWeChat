//
//  UITextField+Extension.swift
//  MyWeChat
//
//  Created by GDG on 15/12/30.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

extension UITextField {

    func addLeftViewWithImage(image:String){
        let leftView = UIImageView()
        var imageBounds = self.bounds
        imageBounds.size.width = imageBounds.size.height
        leftView.bounds = imageBounds
        
        leftView.image = UIImage(named: image)
        leftView.contentMode = .Center
        self.leftView = leftView
        
        self.leftViewMode = .Always
    }
    
    func telphoneNum() -> Bool{
        let telRegex = "^1[3578]\\d{9}$"
        let prediate = NSPredicate(format: "SELF MATCHES %@", telRegex)
        return prediate.evaluateWithObject(self.text)
    }

}
