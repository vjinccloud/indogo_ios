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
    var floatingBtnBackFrame:CGRect!
    var hasFloatingBtn = false
    
    public var promoUrlAry:[String] = []
    public var sessionToken:String = ""
    public var memberData:[String:String] = [:]
    
    public var forgotPassTempMemID:String = ""
    public var forgotPassTempPhone:String = ""
    public var forgotPassTempSMS:String = ""
    public var forgotPassTempEnterCode:String = ""
    
    public var tempRegisterObj:RegisterDataObj = RegisterDataObj()
    
    var noteListObjs:[NoticeObj] = []
    var seperatorStr:String = ""
    var subSeperatorStr:String = ""
    var bottomMenu:BottomMenuView!
    var hasBottomMenu = false
    var bottomPadding:CGFloat!
    
    var defautBottomMenuType:BottomMenuType = .profile
    var nowBottomMenuType:BottomMenuType = .profile
    
    //MARK: - App Life
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //addTopButton()
        
        //指定分隔字元
        AppDelegate.shared().seperatorStr = NSLocalizedString("leading space", comment: "")
        AppDelegate.shared().subSeperatorStr = NSLocalizedString("leading sub space", comment: "")

        return true
    }
    
    //MARK: - Bottom Menu
    func showBottomMenu() {
        bottomMenu.isHidden = false
        bottomMenu.paintMenu()
    }
    
    func hideBottomMenu() {
        bottomMenu.isHidden = true
    }
    
    func addBttomMenu() {
        let window = UIApplication.shared.keyWindow
        
        bottomPadding = window?.safeAreaInsets.bottom
        
        bottomMenu = BottomMenuView()
        bottomMenu.frame = CGRect.init(x: 0, y: (window?.frame.size.height)!-(bottomPadding+50), width: (window?.frame.size.width)!, height: bottomPadding+50)
        bottomMenu.initFirst(RealHeight: 50)
        window?.addSubview(bottomMenu)
        
        //把浮動按鈕拉到最上面
        if hasFloatingBtn {
            window?.bringSubviewToFront(floatingButton)
        }
        
        //先隱藏
        bottomMenu.isHidden = true
        
        hasBottomMenu = true
    }

    //MARK: - Floating Button
    func saveFloatingButtonPosition() {
        floatingBtnBackFrame = floatingButton.frame
    }
    
    func reStoreFloatingButtonPosition() {
        floatingButton.frame = floatingBtnBackFrame
    }
    
    func addFloatingBtn() {
        if hasFloatingBtn {
            saveFloatingButtonPosition()
        }
        
        let window = UIApplication.shared.keyWindow
        
        floatingButton = UIButton(type: .custom)
        floatingButton.frame = CGRect(origin: CGPoint(x: (window?.frame.size.width)!-65, y: (window?.frame.size.height)!-132), size: CGSize(width: 55, height: 55))
        floatingButton.imageView?.contentMode = .scaleToFill
        //floatingButton.setImage(UIImage.init(named: "question.png"), for: .normal)
        floatingButton.setBackgroundImage(UIImage.init(named: "online_service.png"), for: .normal)
        floatingButton.backgroundColor = UIColor.clear
        floatingButton.layer.shadowColor = UIColor.black.cgColor
        floatingButton.layer.shadowRadius = 3
        floatingButton.layer.shadowOpacity = 0.8
        floatingButton.layer.shadowOffset = CGSize.zero
        
        window?.addSubview(floatingButton)
        
        let panner = UIPanGestureRecognizer(target: self, action: #selector(panDidFire(panner:)))
        floatingButton.addGestureRecognizer(panner)
        
        if hasFloatingBtn {
            reStoreFloatingButtonPosition()
        }
        
        hasFloatingBtn = true
        
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
        
        if hasBottomMenu {
            bottomMenu.removeFromSuperview()
        }
        hasBottomMenu = false
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
    
    //MARK: - Change Root
    public func changeRootOfFunc(Type type:LoginFuncType) {
        
        var storyboardId = ""
        var navigaterId = ""
        
        if type == LoginFuncType.main {
            storyboardId = "Main"
            navigaterId = "MainNC"
        } else {
            
            if type == LoginFuncType.member {
                storyboardId = "Member"
                navigaterId = "MemberMainNC"
            } else if type == LoginFuncType.notice {
                storyboardId = "Member"
                navigaterId = "NoticeMainNC"
            }
        }
        
        let window = UIApplication.shared.keyWindow
        // Set initial view controller from Main storyboard as root view controller of UIWindow
        let nextVC = UIStoryboard(name: storyboardId, bundle: nil).instantiateViewController(withIdentifier: navigaterId)
        window!.rootViewController = nextVC
        // Present window to screen
        self.window?.makeKeyAndVisible()
        
        //底層Menu
        addFloatingBtn()
        addBttomMenu()
        
        if type != LoginFuncType.main {
            showBottomMenu()
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
    
    func showTopButton() {
        topContainer.isHidden = false
    }
    
    func hideTopButton() {
        topContainer.isHidden = true
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

