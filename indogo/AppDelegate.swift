//
//  AppDelegate.swift
//  indogo
//
//  Created by mac on 2020/7/9.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import UserNotifications
import iProgressHUD
import PKHUD
import CryptoKit
import CommonCrypto
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var topMargin: CGFloat!
    
    var topContainer:UIView!
    var normalPageBtn:UIButton!
    var shopPageBtn:UIButton!
    var topLine:UIView!
    var nowPage = 0
    
    public var promoUrlAry:[String] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //addTopButton()
        return true
    }
    
    //MARK: - Utility
    class func shared() -> AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    //頂部兩個按鈕
    func addTopButton() {
        
        let window = UIApplication.shared.keyWindow
        
        topContainer = UIView(frame: CGRect.init(x: 0, y: topMargin, width: window!.bounds.width, height: 40))
        window!.addSubview(topContainer);
        topContainer.backgroundColor = UIColor.black
        normalPageBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: topContainer.frame.size.width/2, height: topContainer.frame.size.height))
        normalPageBtn.backgroundColor = UIColor.black
        normalPageBtn.setTitle("REMIT", for: .normal)
        topContainer.addSubview(normalPageBtn)
        
        shopPageBtn = UIButton.init(frame: CGRect(x: topContainer.frame.size.width/2, y: 0, width: topContainer.frame.size.width/2, height: topContainer.frame.size.height))
        shopPageBtn.backgroundColor = UIColor.black
        shopPageBtn.setTitle("SHOPPING", for: .normal)
        topContainer.addSubview(shopPageBtn)
        
        topLine = UIView.init(frame: CGRect.init(x: 0, y: topContainer.frame.size.height-2, width: topContainer.frame.size.width/2, height: 2))
        topLine.backgroundColor = UIColor.init(red: 26/255, green: 143/255, blue: 246/255, alpha: 1)
        topContainer.addSubview(topLine)
        
        initLinePosX()
    }
    
    //底部線條
    func initLinePosX() {
        if nowPage == 0 {
            topLine.frame =  CGRect.init(x: 0, y: topContainer.frame.size.height-2, width: topContainer.frame.size.width/2, height: 2)
        } else {
            topLine.frame =  CGRect.init(x: topContainer.frame.size.width/2, y: topContainer.frame.size.height-2, width: topContainer.frame.size.width/2, height: 2)
        }
    }
    
    //正在讀取
    func addLoadingView() {
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
    }
    
    //關掉讀取按鈕
    func removeLoadingView() {
        PKHUD.sharedHUD.hide()
    }
    
    //跳出alert
    func showAlertWithWindow (_ onVC:UIViewController, Message msg:String) {
        let vc = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "確定", style: .default, handler: { action in
            
        }))
        onVC.present(vc, animated: true, completion: nil)
    }
}

