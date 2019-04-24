//
//  BaseVC.swift
//  MovieApp
//
//  Created by Sunil Kumar on 03/04/19.
//  Copyright © 2019 Sunil. All rights reserved.
//

import UIKit
import MBProgressHUD

class BaseVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showAlert(titleStr: String? = "", messageStr: String? = "") {
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showHud() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func hideHud() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
}
