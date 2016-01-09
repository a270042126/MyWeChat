//
//  WCMeViewController.swift
//  MyWeChat
//
//  Created by GDG on 16/1/6.
//  Copyright © 2016年 MyWeChat. All rights reserved.
//

import UIKit

class WCMeViewController: UITableViewController {
    
    
    @IBOutlet weak var imageVIew: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myVCard = WCXMPPTool.sharedInstance.vCard?.myvCardTemp
        // 设置头像
        if let photo = myVCard?.photo{
            self.imageVIew.image = UIImage(data: photo)
        }
        // 设置昵称
        self.label1.text = myVCard?.nickname
        
        // 设置微信号[用户名]
        let user = WCUserInfo.sharedInstance.user
        label2.text = String(format: "微信号:%@", user!)
        
    }

    @IBAction func loginout(sender: UIBarButtonItem) {
        WCXMPPTool.sharedInstance.xmppUserLogout()
    }
    
    

}
