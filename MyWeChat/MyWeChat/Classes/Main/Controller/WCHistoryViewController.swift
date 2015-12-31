//
//  WCHistoryTableViewController.swift
//  MyWeChat
//
//  Created by GDG on 15/12/30.
//  Copyright © 2015年 MyWeChat. All rights reserved.
//

import UIKit

class WCHistoryViewController: UITableViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginStatusChange:", name: NotifiStatic.WCLoginStatusChangeNotification, object: nil)
    }
    
    internal func loginStatusChange(notifi:NSNotification){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let type:XMPPResultType = XMPPResultType(rawValue: notifi.userInfo!["loginStatus"] as! String)!
            switch(type){
            case .Connecting:
                self.activityIndicatorView.startAnimating()
                break
            case .NetErr:
                self.activityIndicatorView.stopAnimating()
                break
            case .LoginSuccess:
                self.activityIndicatorView.stopAnimating()
                break
            case .LoginFailure:
                self.activityIndicatorView.stopAnimating()
                break
            default:
                break
            }
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


}
