//
//  UIButton+Extenstion.swift
//  MyWeChat
//
//  Created by GDG on 15/12/29.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

extension UIButton {
    /**
    * 设置普通状态与高亮状态的背景图片
    */
    func setN_BG(nbg:String,hbg:String){
        self.setBackgroundImage(UIImage(named: nbg), forState: .Normal)
        self.setBackgroundImage(UIImage(named: hbg), forState: .Highlighted)
    }
    
    /**
    * 设置普通状态与高亮状态的拉伸后背景图片
    */
    func setResizedN_BG(nbg:String,hbg:String){
        self.setBackgroundImage(UIImage.stretchedImageWithName(nbg), forState: .Normal)
        self.setBackgroundImage(UIImage.stretchedImageWithName(hbg), forState: .Highlighted)
    }
}
