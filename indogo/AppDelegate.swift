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
    
    var floatingButton: UIButton!
    var window: UIWindow?
    var topMargin: CGFloat!
    
    var topContainer:UIView!
    var normalPageBtn:UIButton!
    var shopPageBtn:UIButton!
    var topLine:UIView!
    var nowPage = 0
    
    var hasLogin = false
    
    public var promoUrlAry:[String] = []
    public var sessionToken:String = ""
    public var memberData:[String:String] = [:]
    
    public var forgotPassTempPhone:String = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //addTopButton()

        return true
    }
    
    func addFloatingBtn() {
        let window = UIApplication.shared.keyWindow
        
        floatingButton = UIButton(type: .custom)
        floatingButton.frame = CGRect(origin: CGPoint(x: (window?.frame.size.width)!-65, y: (window?.frame.size.height)!-132), size: CGSize(width: 55, height: 55))
        floatingButton.imageView?.contentMode = .scaleToFill
        //floatingButton.setImage(UIImage.init(named: "question.png"), for: .normal)
        floatingButton.setBackgroundImage(UIImage.init(named: "question.png"), for: .normal)
        floatingButton.backgroundColor = UIColor.clear
        floatingButton.layer.shadowColor = UIColor.black.cgColor
        floatingButton.layer.shadowRadius = 3
        floatingButton.layer.shadowOpacity = 0.8
        floatingButton.layer.shadowOffset = CGSize.zero
        
        window?.addSubview(floatingButton)

        let panner = UIPanGestureRecognizer(target: self, action: #selector(panDidFire(panner:)))
        floatingButton.addGestureRecognizer(panner)
    }
    
    @objc func panDidFire(panner: UIPanGestureRecognizer) {
        let window = UIApplication.shared.keyWindow
        
        let offset = panner.translation(in: window)
        panner.setTranslation(CGPoint.zero, in: window)
        var center = floatingButton.center
        center.x += offset.x
        center.y += offset.y
        floatingButton.center = center

        if panner.state == .ended || panner.state == .cancelled {
            UIView.animate(withDuration: 0.3) {
                self.snapButtonToSocket()
            }
        }
    }

    private func snapButtonToSocket() {
        let center = floatingButton.center
        let window = UIApplication.shared.keyWindow
        
        if center.y < (topContainer.frame.origin.y + topContainer.frame.size.height + floatingButton.frame.size.height*0.5) {
            floatingButton.center.y = (topContainer.frame.origin.y+topContainer.frame.size.height+30)
        } else if center.y > ( (window?.frame.size.height)! - floatingButton.frame.size.height*0.5 - 60) {
            floatingButton.center.y = (window?.frame.size.height)! - floatingButton.frame.size.height*0.5 - 60
        }
        
        if center.x < ( 10 + floatingButton.frame.size.width*0.5) {
            floatingButton.center.x = 10 + floatingButton.frame.size.width*0.5
        } else if center.x > ( (window?.frame.size.width)! - floatingButton.frame.size.width*0.5 - 10) {
            floatingButton.center.x = (window?.frame.size.width)! - floatingButton.frame.size.width*0.5 - 10
        }
    }
    
    @objc func floatingButtonWasTapped() {
        let alert = UIAlertController(title: "Warning", message: "Don't do that!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Sorry…", style: .default, handler: nil)
        alert.addAction(action)
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - login
    public func userLogin(TokenStr str:String) {
        sessionToken = str
        hasLogin = true
        //存起來
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(str, forKey: "sessionToken")
        userDefaults.synchronize()
    }
    
    public func userLogout() {
        hasLogin = false
        sessionToken = ""
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "sessionToken")
        userDefaults.removeObject(forKey: "bioState")
        userDefaults.synchronize()
    }
    
    func setBioState() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue("1", forKey: "bioState")
        userDefaults.synchronize()
    }
    
    func getBioState() -> Bool {
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "bioState") == nil || userDefaults.value(forKey: "transPassword") == nil {
            return false
        } else {
            return true
        }
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
        normalPageBtn.setTitle(NSLocalizedString("remit", comment: ""), for: .normal)
        topContainer.addSubview(normalPageBtn)
        
        shopPageBtn = UIButton.init(frame: CGRect(x: topContainer.frame.size.width/2, y: 0, width: topContainer.frame.size.width/2, height: topContainer.frame.size.height))
        shopPageBtn.backgroundColor = UIColor.black
        shopPageBtn.setTitle(NSLocalizedString("shopping", comment: ""), for: .normal)
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

