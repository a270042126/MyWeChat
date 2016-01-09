//
//  WCXMPPTool.swift
//  MyWeChat
//
//  Created by GDG on 15/12/29.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

struct NotifiStatic {
    static let WCLoginStatusChangeNotification = "WCLoginStatusNotification"
    static let LoginStatusNotifi = "loginStatus"
}

enum XMPPResultType:String{
    case Connecting = "Connecting"
    case LoginSuccess = "LoginSuccess"
    case LoginFailure = "LoginFailure"
    case NetErr = "NetErr"
    case RegisterSuccess = "RegisterSuccess"
    case RegisterFailure = "RegisterFailure"
}


// XMPP请求结果的block
typealias XMPPResultBlock = (_:XMPPResultType) -> Void

class WCXMPPTool: NSObject,XMPPStreamDelegate {
    
    var xmppStream:XMPPStream?
    var registerOperation:Bool = false//注册操作
    var vCard:XMPPvCardTempModule?//电子名片
    var roster:XMPPRoster?//花名册模块
    var rosterStorage:XMPPRosterCoreDataStorage?//花名册数据存储
    var msgStorage:XMPPMessageArchivingCoreDataStorage?//聊天数据存储
    
    var reconnect:XMPPReconnect?//自动连接模块
    var vCardStorage:XMPPvCardCoreDataStorage? //电子名片的数据存储
    var avatar:XMPPvCardAvatarModule? //头像模块
    var msgArchiving:XMPPMessageArchiving? //聊天模块
    
    private var resultBlock:XMPPResultBlock?
    
    class var sharedInstance:WCXMPPTool{
        struct Static {
            static var onceToken:dispatch_once_t = 0;
            static var instance:WCXMPPTool? = nil
        }
        dispatch_once(&Static.onceToken){
            Static.instance = WCXMPPTool()
        }
        return Static.instance!
    }
    
    
    //建立连接
    private func setupXmppStream(){
        xmppStream = XMPPStream()
        
        //每一个模块添加后都要激活
        //添加自动连接模块
        reconnect = XMPPReconnect()
        reconnect?.activate(xmppStream)
        
        //添加电子名片模块
        vCardStorage = XMPPvCardCoreDataStorage.sharedInstance()
        
        vCard = XMPPvCardTempModule(withvCardStorage: vCardStorage)
        vCard?.activate(xmppStream)
        
        //添加头像模块
        avatar = XMPPvCardAvatarModule(withvCardTempModule: vCard)
        avatar?.activate(xmppStream)
        
        //添加花名册模块
        rosterStorage = XMPPRosterCoreDataStorage()
        roster = XMPPRoster(rosterStorage: rosterStorage!)
        roster?.activate(xmppStream)
        
        //添加聊天模块
        msgStorage = XMPPMessageArchivingCoreDataStorage()
        msgArchiving = XMPPMessageArchiving(messageArchivingStorage: msgStorage)
        msgArchiving?.activate(xmppStream)
        
        xmppStream?.enableBackgroundingOnSocket = true
        //设置代理
        xmppStream?.addDelegate(self, delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        
    }
    
    private func teardownXmpp(){
        xmppStream?.removeDelegate(self)
        
        //停止模块
        reconnect?.deactivate()
        vCard?.deactivate()
        avatar?.deactivate()
        roster?.deactivate()
        msgArchiving?.deactivate()
        
        xmppStream?.disconnect()
        xmppStream = nil
        reconnect = nil
        vCard = nil
        vCardStorage = nil
        avatar = nil
        rosterStorage = nil
        msgArchiving = nil
        msgStorage = nil
        xmppStream = nil
    }
    
    //连接到服务器
    private func connectToHost(){
        NSLog("开始连接到服务器")
        if xmppStream == nil {
            setupXmppStream()
        }
        
        postNotification(XMPPResultType.Connecting)
        
        var user:String
        if registerOperation {
            user = WCUserInfo.sharedInstance.registerUser!
        }else{
            user = WCUserInfo.sharedInstance.user!
        }
        
        let myJID = XMPPJID.jidWithUser(user, domain: UserInfoStatic.Domain, resource: "iphone")
        xmppStream?.myJID = myJID
        xmppStream?.hostName = UserInfoStatic.IP
        xmppStream?.hostPort = UInt16(UserInfoStatic.PostHost)
        
        do{
            try xmppStream?.connectWithTimeout(XMPPStreamTimeoutNone)
        }catch{
            NSLog("\(error)")
        }
    }
    
    //发送密码
    private func sendPwdToHost(){
        NSLog("再次发送密码授权")
        let pwd = WCUserInfo.sharedInstance.pwd
        do{
            try xmppStream?.authenticateWithPassword(pwd)
        }catch{
            NSLog("\(error)")
        }
    }
    
    //发送在线消息
    private func sendOnlineToHost(){
        NSLog("发送在线消息")
        let presence = XMPPPresence()
        NSLog("\(presence)")
        xmppStream?.sendElement(presence)
    }
    
    deinit{
        teardownXmpp()
    }
    
    //发送通知
    private func postNotification(resultType:XMPPResultType){
        let userInfo:[String:AnyObject] = [NotifiStatic.LoginStatusNotifi:resultType.rawValue]
        NSNotificationCenter.defaultCenter().postNotificationName(NotifiStatic.WCLoginStatusChangeNotification, object: nil, userInfo: userInfo)
    }
    
    
    //MARK: - XMPPStreamDelegate
    
    //连接成功
    func xmppStreamDidConnect(sender: XMPPStream!) {
        NSLog("与主机连接成功")
        if registerOperation {
            let pwd = WCUserInfo.sharedInstance.registerPwd
            do{
                try xmppStream?.registerWithPassword(pwd)
            }catch{}
        }else{
            sendPwdToHost()
        }
    }
    
    //断开连接
    func xmppStreamDidDisconnect(sender: XMPPStream!, withError error: NSError!) {
        // 如果有错误，代表连接失败
        // 如果没有错误，表示正常的断开连接(人为断开连接)
        
        if(error != nil){
            resultBlock?(XMPPResultType.NetErr)
            //通知网络不稳定
            postNotification(XMPPResultType.NetErr)
        }
        NSLog("与主机断开连接 \(error)")
    }
    
    //授权成功
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        NSLog("授权成功")
        sendOnlineToHost()
        resultBlock?(XMPPResultType.LoginSuccess)
        postNotification(.LoginSuccess)
    }
    
    //授权失败
    func xmppStream(sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        NSLog("授权失败 \(error)")
        resultBlock?(XMPPResultType.LoginFailure)
        postNotification(.LoginFailure)
    }
    
    //注册成功
    func xmppStreamDidRegister(sender: XMPPStream!) {
        NSLog("注册成功")
        resultBlock?(XMPPResultType.RegisterSuccess)
    }
    
    //注册失败
    func xmppStream(sender: XMPPStream!, didNotRegister error: DDXMLElement!) {
        NSLog("注册失败 \(error)")
        resultBlock?(XMPPResultType.RegisterFailure)
    }
    
    //接收好友消息
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        NSLog("\(message)")
        if UIApplication.sharedApplication().applicationState != .Active{
            NSLog("在后台")
            //本地通知
            let localNoti = UILocalNotification()
            localNoti.alertBody = String(format: "%@\n%@", message.fromStr(),message.body() == nil ? "" : message.body())
            localNoti.fireDate = NSDate() //执行时间
            localNoti.soundName = "default"
            UIApplication.sharedApplication().scheduledLocalNotifications = [localNoti] //执行
            
        }
    }
    
    
    //收到状态 sender通道 presence是状态
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        //取得好友状态
        let presenceType = presence.type()
        //我的id
        let myUser = sender.myJID.user
        //对方状态
        let presenceFromUser = presence.from().user
        //如果在列表中把“我”过滤掉
        if presenceFromUser != myUser{
            if presenceType == "available"{
                
                //[_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"thinkdifferent.local"]];
            }
            
            if presenceType == "unavailable" {
                //[_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"thinkdifferent.local"]];
            }
            
            if presenceType == "subscribe" {
                //[_chatDelegate receivedFriendRequest:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"thinkdifferent.local"]];
            }
            
        }
        
    }
    
    
    
    //MARK: - Public
    /**
     *  用户注销
     
     */
    func xmppUserLogout(){
        let offline = XMPPPresence(type: "unavailable")
        xmppStream?.sendElement(offline)
        xmppStream?.disconnect()
        
        //do somthing
        UIStoryboard.showInitialVCWithName("Login")
        
        WCUserInfo.sharedInstance.loginStatus = false
        WCUserInfo.sharedInstance.saveUserInfoToSanbox()

    }
    /**
     *  用户登录
     */
    func xmppUserLogin(resultBlock:XMPPResultBlock?){
        self.resultBlock = resultBlock
        xmppStream?.disconnect()
        connectToHost()
    }
    /**
     *  用户注册
     */
    func xmppUserRegister(resultBlock:XMPPResultBlock){
        self.resultBlock = resultBlock
        xmppStream?.disconnect()
        connectToHost()
    }
}








