//
//  ViewController.swift
//  indogo
//
//  Created by mac on 2020/7/9.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var accountL: UILabel!
    @IBOutlet weak var accountBtn: UIButton!
    
    @IBOutlet weak var passL: UILabel!
    @IBOutlet weak var passBtn: UIButton!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var remeberBtn: UIButton!
    
    @IBOutlet weak var lupaBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        accountBtn.layer.cornerRadius = accountBtn.frame.height/2
        passBtn.layer.cornerRadius = passBtn.frame.height/2
        loginBtn.layer.cornerRadius = loginBtn.frame.height/2
        
        lupaBtn.layer.cornerRadius = lupaBtn.frame.height/2
        lupaBtn.layer.borderColor = UIColor.white.cgColor
        lupaBtn.layer.borderWidth = 0.5
        
        registerBtn.layer.cornerRadius = registerBtn.frame.height/2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.shared().topMargin = self.view.safeAreaInsets.top
        AppDelegate.shared().addTopButton()
    }


}

