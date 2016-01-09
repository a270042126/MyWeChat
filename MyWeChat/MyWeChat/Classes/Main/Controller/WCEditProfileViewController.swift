//
//  WCEditProfileViewController.swift
//  MyWeChat
//
//  Created by GDG on 16/1/9.
//  Copyright © 2016年 MyWeChat. All rights reserved.
//

import UIKit

protocol WCEditProfileViewControllerDelegate:class{
    func editProfileViewControllerDidSave()
}

class WCEditProfileViewController: UITableViewController {
    
    weak var delegate:WCEditProfileViewControllerDelegate?
    var cell:UITableViewCell?

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = cell?.textLabel?.text
        textField.text = cell?.detailTextLabel?.text
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .Plain, target: self, action: "saveBtnClick")
        
    }
    
    func saveBtnClick(){
        // 1.更改Cell的detailTextLabel的text
        cell?.detailTextLabel?.text = textField.text
        cell?.layoutSubviews()
        delegate?.editProfileViewControllerDidSave()
        // 2.当前的控制器消失
        self.navigationController?.popViewControllerAnimated(true)
       
    }

  

}
