//
//  NSDate+Extension.swift
//  MyWeChat
//
//  Created by GDG on 15/12/30.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

extension NSDate {

    class func getCurrentTime() -> String{
        let nowDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .MediumStyle
        return dateFormatter.stringFromDate(nowDate)
    }
}
