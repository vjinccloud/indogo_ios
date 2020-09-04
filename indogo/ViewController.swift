//
//  ViewController.swift
//  indogo
//
//  Created by mac on 2020/7/9.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource, CustomAlertDelegate {
    
    @IBOutlet weak var accountBtn: UIButton!
    @IBOutlet weak var accountTextfield: UITextField!
    
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var remeberBtn: UIButton!
    
    @IBOutlet weak var lupaBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var showPassBtn: UIButton!
    @IBOutlet weak var topScrollView: UIScrollView!
    @IBOutlet weak var promoView: UIView!
    @IBOutlet weak var promoPageCtrl: UIPageControl!
    var promoNum = 0
    var promoPageVC: NSMutableArray!
    var pageController: UIPageViewController!
    var currentPageIndex = 0
    
    var loadOnce:Bool = false
    
    //MARK: - Button-Action
    @IBAction func showPassAction(_ sender: Any) {
        passTextField.isSecureTextEntry.toggle()
        
        if passTextField.isSecureTextEntry {
            showPassBtn.setBackgroundImage(UIImage.init(named: "noview_b"), for: .normal)
        } else {
            showPassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if accountTextfield.text?.count == 0 {
            AppDelegate.shared().showAlertWithWindow(self, Message: "請輸入帳號")
            return
        }
        
        if passTextField.text?.count == 0 {
            AppDelegate.shared().showAlertWithWindow(self, Message: "請輸入密碼")
            return
        }
        
        loginNext()
    }
    
    @IBAction func forgotPassAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassMainVC") as? ForgotPassMainVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func registAction(_ sender: Any) {
        
        //進入註冊
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterAgreementVC") as? RegisterAgreementVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
        /*
        let customAlert = CustomAlertView.init(frame: topScrollView.frame)
        customAlert.initAlert(Title: NSLocalizedString("Main Register Alert Title" , comment: ""), Content: NSLocalizedString("Main Register Alert Content" , comment: ""), NextBtn1Str: NSLocalizedString("agree" , comment: ""), CancelBtn1Str: NSLocalizedString("cancel" , comment: ""))
        self.view.addSubview(customAlert)
        customAlert.customDelegate = self
         */
    }
    
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        
        //進入註冊
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterAgreementVC") as? RegisterAgreementVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    func customAlertnextActionSecond(Ref obj: CustomAlertView) {
        
    }
    
    //MARK: - API
    func checkTokenLogin() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_CheckLogin;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        Alamofire.request(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    AppDelegate.shared().nowBottomMenuType = AppDelegate.shared().defautBottomMenuType
                    AppDelegate.shared().changeRootOfFunc(Type: .transaction)
                    //AppDelegate.shared().showAlertWithWindow(self, Message: "Hi, \(AppDelegate.shared().memberData["member_name"] ?? "") 自動登入成功")
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: Lang_APIDecodeFail)
                }
        }
    }
    
    func loginNext() {
        let parameters:Parameters = ["login_id":accountTextfield.text!, "login_password": UtilityTool().sha256(Code: passTextField.text!)]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_Login;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        Alamofire.request(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    AppDelegate.shared().nowBottomMenuType = AppDelegate.shared().defautBottomMenuType
                    AppDelegate.shared().changeRootOfFunc(Type: .transaction)
                    //AppDelegate.shared().showAlertWithWindow(self, Message: "Hi, \(AppDelegate.shared().memberData["member_name"] ?? "") 登入成功")
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: Lang_APIDecodeFail)
                }
        }
    }
    
    func getPromo() {
        
        let parameters:Parameters = [:]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_Promo;
        Alamofire.request(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    
                    self.promoNum = AppDelegate.shared().promoUrlAry.count
                    self.setController()
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: Lang_APIDecodeFail)
                }
        }
    }
    
    //MARK: - Page
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // 取得當前頁數的 index(未翻頁前)
        let currentIndex: Int =  self.promoPageVC.index(of: viewController)
        
        // 設定上一頁的 index
        let priviousIndex: Int = currentIndex - 1
        self.promoPageCtrl.currentPage = priviousIndex < 0 ? priviousIndex : currentIndex
        // 判斷上一頁的 index 是否小於 0，若小於 0 則停留在當前的頁數
        return priviousIndex < 0 ? nil : self.promoPageVC![priviousIndex] as? PromoPageVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // 取得當前頁數的 index(未翻頁前)
        let currentIndex: Int =  self.promoPageVC.index(of: viewController)
        
        // 設定下一頁的 index
        let nextIndex: Int = currentIndex + 1
        self.promoPageCtrl.currentPage = nextIndex > self.promoPageVC.count - 1 ? nextIndex : currentIndex
        // 判斷下一頁的 index 是否大於總頁數，若大於則停留在當前的頁數
        return nextIndex > self.promoPageVC.count - 1 ? nil : self.promoPageVC![nextIndex] as? PromoPageVC
    }
    
    @objc func endPromo() {
        self.promoView.removeFromSuperview()
        self.topScrollView.isHidden = false
    }
    
    func setController() {
        promoPageVC = NSMutableArray()
        let scenseView = UIStoryboard(name: "Main", bundle: nil)
        
        promoNum = 0
        for str in AppDelegate.shared().promoUrlAry {
            if let page = scenseView.instantiateViewController(withIdentifier: "PromoPageVC") as? PromoPageVC{
                page.view.tag = promoNum
                page.view.backgroundColor = .black
                page.promoUrl = str
                promoPageVC.add(page)
                page.setImage()
                if promoNum == (AppDelegate.shared().promoUrlAry.count-1) { //最後一頁
                    page.endBtn.isHidden = false
                    page.endBtn.addTarget(self, action: #selector(endPromo), for: .touchUpInside)
                }
            }
            promoNum += 1
        }
        
        print("promoNum = \(promoPageVC.count)")
        
        if promoNum == 0 {
            return
        } else {
            self.promoView.isHidden = false
            self.promoPageCtrl.isHidden = false
            
            self.topScrollView.isHidden = true
        }
        
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageController.view.frame = CGRect(x: 0, y: 0, width: promoView.frame.size.width, height: promoView.frame.size.height)
        self.pageController.setViewControllers([promoPageVC.object(at: currentPageIndex) as! PromoPageVC],                                                         direction: .forward,                                                         animated: false) {(isFinished:Bool) -> Void in
        }
        self.pageController.delegate = self
        self.pageController.dataSource = self
        self.addChild(self.pageController)
        promoView.addSubview(self.pageController.view)
        
        self.promoPageCtrl.numberOfPages = promoNum
        self.promoPageCtrl.currentPage = currentPageIndex
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        promoView.isHidden = true
        promoPageCtrl.isHidden = true
        
        accountBtn.layer.cornerRadius = accountBtn.frame.height/2
        passBtn.layer.cornerRadius = passBtn.frame.height/2
        loginBtn.layer.cornerRadius = loginBtn.frame.height/2
        
        lupaBtn.layer.cornerRadius = lupaBtn.frame.height/2
        lupaBtn.layer.borderColor = UIColor.white.cgColor
        lupaBtn.layer.borderWidth = 0.5
        
        accountTextfield.placeholder = NSLocalizedString("account", comment: "")
        passTextField.placeholder = NSLocalizedString("passcode", comment: "")
        loginBtn.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
        lupaBtn.setTitle(NSLocalizedString("recover passcode", comment: ""), for: .normal)
        registerBtn.setTitle(NSLocalizedString("register", comment: ""), for: .normal)
        
        passTextField.isSecureTextEntry = true
        registerBtn.layer.cornerRadius = registerBtn.frame.height/2
        
        if DevMode {
            //accountTextfield.text = "XX00000078"
            //passTextField.text = "123456"
            
            accountTextfield.text = "XX00000026"
            passTextField.text = "123456"
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            AppDelegate.shared().showTopButton()
            return
        }
        
        loadOnce = true
        
        //頂部兩個按鈕
        AppDelegate.shared().topMargin = self.view.safeAreaInsets.top
        AppDelegate.shared().addTopButton()
        
        //AppDelegate.shared().floatingButtonController = FloatingButtonController()
        //AppDelegate.shared().floatingButtonController?.button.addTarget(self, action: #selector(AppDelegate.floatingButtonWasTapped), for: .touchUpInside)
        AppDelegate.shared().addFloatingBtn()
        
        //取得Promo
        //getPromo()
        
        //自動登入
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "sessionToken") != nil {
            AppDelegate.shared().sessionToken = userDefaults.value(forKey: "sessionToken") as! String
            checkTokenLogin()
        }
    }
}

