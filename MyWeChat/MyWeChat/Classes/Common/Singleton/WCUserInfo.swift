//
//  WCUserInfo.swift
//  MyWeChat
//
//  Created by GDG on 15/12/29.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

struct UserInfoStatic{
    static let Domain = "chashao.local"
    static let UserKey = "user"
    static let PwdKey = "pwd"
    static let LoginStatusKey = "LoginStatus"
    static let PostHost = 5222
    static let IP = "127.0.0.1"
}

class WCUserInfo: NSObject {
    
    class var sharedInstance:WCUserInfo{
        struct Static{
            static var onceToken:dispatch_once_t = 0;
            static var instance:WCUserInfo? = nil
        }
        dispatch_once(&Static.onceToken){
            Static.instance = WCUserInfo()
        }
        return Static.instance!
    }
    
    //登录
    var user:String?
    var pwd:String?
    
    /**
    *  登录的状态 YES 登录过/NO 注销
    */
    var loginStatus:Bool = false
    //注册
    var registerUser:String?
    var registerPwd:String?
    var jid:String{
        get{
            return String(format: "%@@%@", arguments: [self.user!,UserInfoStatic.Domain])
        }
    }
    
    func loadUserInfoFromSanbox(){
        let defaults = NSUserDefaults.standardUserDefaults()
        self.user = defaults.objectForKey(UserInfoStatic.UserKey) as? String
        self.pwd = defaults.objectForKey(UserInfoStatic.PwdKey) as? String
        if let loginStatus = defaults.objectForKey(UserInfoStatic.LoginStatusKey) as? Bool{
            self.loginStatus = loginStatus
        }
    }
    
    func saveUserInfoToSanbox(){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(user, forKey: UserInfoStatic.UserKey)
        defaults.setObject(loginStatus, forKey: UserInfoStatic.LoginStatusKey)
        defaults.setObject(pwd, forKey: UserInfoStatic.PwdKey)
        defaults.synchronize()
    }
    
}





