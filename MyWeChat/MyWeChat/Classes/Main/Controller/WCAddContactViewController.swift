//
//  WCAddContactViewController.swift
//  MyWeChat
//
//  Created by GDG on 16/1/4.
//  Copyright © 2016年 MyWeChat. All rights reserved.
//

import UIKit

class WCAddContactViewController: UITableViewController,UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let user = textField.text
        
        if user == WCUserInfo.sharedInstance.user {
            NSLog("不能加自己")
            return true
        }
        
        let jidStr = String(format: "%@@%@", arguments: [user!,UserInfoStatic.Domain])
            NSLog("\(jidStr)")
        let friendJid = XMPPJID.jidWithString(jidStr)
        //判断好友是否已经存在
        if WCXMPPTool.sharedInstance.rosterStorage!.userExistsWithJID(friendJid, xmppStream: WCXMPPTool.sharedInstance.xmppStream){
            NSLog("好友已经存在")
            return true
        }
        // 2.发送好友添加的请求
        // 添加好友,xmpp有个叫订阅
        WCXMPPTool.sharedInstance.roster?.subscribePresenceToUser(friendJid)
        textField.resignFirstResponder()
        return true
    }

    

   

}
