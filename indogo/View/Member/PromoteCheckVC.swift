//
//  PromoteCheckVC.swift
//  indogo
//
//  Created by Wang Jen Chung on 2026/2/9.
//  Copyright © 2026 DIM. All rights reserved.
//

import Alamofire
import SwiftyJSON

class PromoteCheckVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputMoreSpaceView: UIView!
    @IBOutlet weak var backL: UILabel!
    
    @IBOutlet weak var topScrollView: UIScrollView!
    
    @IBOutlet weak var phoneNewTitle: UILabel!
    @IBOutlet weak var phoneNewView: UIView!
    @IBOutlet weak var phoneNewBtn: UIButton!
    @IBOutlet weak var phoneNewTextfield: UITextField!
    
    @IBOutlet weak var phoneNewWarnL: UILabel!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var barV: UIView!
    
    var hasSharedCode = false
    var hasMeCode = false
    var meImg:UIImage!
    var loadOnce = false
    
    //MARK: - API
    func checkCode() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "discount_code":phoneNewTextfield.text!, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_CheckDiscountCode;
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                
                if result == ResponseState.ok {
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Text Bar
    func generateToolBar() ->UIToolbar {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextBarAction))
        
        let toolBar:UIToolbar = UIToolbar()
        toolBar.items = [flexibleSpace,done]
        toolBar.sizeToFit()
        
        return toolBar
    }
    
    @objc func nextBarAction() {
        checkCode()
    }
    
    //MARK: - Text Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        inputMoreSpaceView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputMoreSpaceView.isHidden = true
        
        checkNextBtnState(CheckText: true)
    }
    
    func checkNextBtnState(CheckText checkNow:Bool) {
        var pass = true
        
        if phoneNewTextfield.text?.count == 0 {
            pass = false
        }
        
        if pass {
            registerBtn.setTitleColor(.white, for: .normal)
            registerBtn.addGradienOfIndoGo()
            registerBtn.isEnabled = true
            phoneNewWarnL.isHidden = true
        } else {
            registerBtn.removeGradienLayer()
            registerBtn.setTitleColor(.black, for: .normal)
            registerBtn.isEnabled = false
            phoneNewWarnL.isHidden = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else{
            return true
        }
        
        let textLength = text.count + string.count - range.length
        if textLength>20 {
            return false
        }
        
        return true

    }
    
    //MARK: - View-Life
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            return
        }
        loadOnce = true
        barV.addGradienOfIndoGo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        barV.addGradienOfIndoGo()
        
        backL.text = NSLocalizedString("Change Phone Bar Title", comment: "")
        phoneNewTitle.text = NSLocalizedString("Change Phone Title2", comment: "")
        phoneNewWarnL.text = ""
        phoneNewBtn.layer.cornerRadius = phoneNewBtn.frame.size.height/2
        phoneNewTextfield.delegate = self
        phoneNewTextfield.inputAccessoryView = generateToolBar()
        phoneNewTextfield.placeholder = NSLocalizedString("Register Input Phone", comment: "")
        
        phoneNewWarnL.isHidden = true
        
        registerBtn.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
        registerBtn.layer.backgroundColor = UIColor.clear.cgColor
        registerBtn.layer.cornerRadius = registerBtn.frame.size.height/2
        registerBtn.layer.borderColor = Color_Main_Red.cgColor
        registerBtn.layer.borderWidth = 0.5
        checkNextBtnState(CheckText: false)
        phoneNewWarnL.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        AppDelegate.shared().hideTopButton()
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
