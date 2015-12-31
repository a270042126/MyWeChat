//
//  UIImage+Extension.swift
//  MyWeChat
//
//  Created by GDG on 15/12/29.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

extension UIImage {
    /**
    *返回中心拉伸的图片
    */
    class func stretchedImageWithName(name:String) -> UIImage?{
        let image = UIImage(named: name)
        if image != nil{
            let leftCap = image!.size.width * 0.5
            let topCap = image!.size.height * 0.5
            return image?.stretchableImageWithLeftCapWidth(Int(leftCap), topCapHeight: Int(topCap))
        }
        return image
    }
}
