//
//  RegisterShareInputVC.swift
//  indogo
//
//  Created by mac on 2020/7/27.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Alamofire

class RegisterShareInputVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var barV: UIView!
    @IBOutlet weak var scanImgV: UIImageView!
    @IBOutlet weak var introL: UILabel!
    @IBOutlet weak var scanL: UILabel!
    @IBOutlet weak var msgL: UILabel!
    @IBOutlet weak var divL: UILabel!
    @IBOutlet weak var belowL: UILabel!
    @IBOutlet weak var downBtn: UIButton!
    @IBOutlet weak var textBgV: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var scanBgV: UIView!
    @IBOutlet weak var inputMoreSpaceView: UIView!
    @IBOutlet weak var textBackV: UIView!
    @IBOutlet weak var topScrollView: UIScrollView!
    
    var parentVC:RegisterPurpleInputVC!
    //從註冊資料頁帶入的已填推薦碼
    var presetCode = ""
    var loadOnce = false
    
    //推薦碼只收數字（含貼上），不限長度，其餘交給後端判斷
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true   //刪除
        }
        //只收 ASCII 0～9（decimalDigits 會放行全形數字，不用）
        return string.unicodeScalars.allSatisfy { $0.value >= 0x30 && $0.value <= 0x39 }
    }
    
    //MARK: - API
    //按 KIRIM 先打 share_member_check，成功才回填到註冊資料頁；失敗留在原頁顯示後端訊息
    func checkShareMember(Code code:String) {
        
        AppDelegate.shared().tempShareMemberId = ""
        //回應夾 PHP 警告時 getResponseState 不會清空上一次的錯誤訊息，送出前先清
        AppDelegate.shared().apiBackContentStr = ""
        
        //IndoGO 後端（照 Android）收 member_id，不是 GoPadala 的 share_member_id；register_step_1 的 share_member_id 不受影響
        let parameters:Parameters = ["member_id":code]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_ShareMemberCheck
        
        Dlog("checkShareMember todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
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
                Dlog("checkShareMember responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    //回填到註冊資料頁的推薦碼變數（不是 ARC 號碼）
                    self.parentVC?.setShareCode(Code: code)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    //顯示後端回的訊息；回傳格式不對、沒有訊息時才退回既有的連線異常文字
                    var msg = AppDelegate.shared().apiBackContentStr
                    if msg == "" {
                        msg = NSLocalizedString("API Timeout", comment: "")
                    }
                    AppDelegate.shared().showAlertWithWindow(self, Message: msg)
                }
        }
    }
    
    //KIRIM 按鈕樣式比照註冊資料頁的 Lanjut：可按是紫色漸層膠囊，不可按是透明底紫框
    //輸入值和目前已填的碼相同（含兩者都是空）時不可按；清空後可按，送出會清掉已填的碼
    func checkBtnState() {
        downBtn.removeGradienLayer()
        if inputTextField.text! != presetCode {
            downBtn.addGradienOfIndoGo()
            downBtn.layer.borderWidth = 0
            downBtn.isEnabled = true
        } else {
            downBtn.backgroundColor = .clear
            downBtn.layer.borderWidth = 0.5
            downBtn.isEnabled = false
        }
    }
    
    //邊打字就更新 KIRIM 狀態；數字鍵盤沒有 return 鍵，不必先收鍵盤才能送
    @objc func inputTextChanged(_ textField: UITextField) {
        checkBtnState()
    }
    
    //MARK: - Button-Action
    public func setCodeString(Code code:String) {
        inputTextField.text = code
        checkBtnState()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterShareScanQRCodeVC") as? RegisterShareScanQRCodeVC
        nextVC?.parentVC = self
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func downAction(_ sender: Any) {
        let code = inputTextField.text ?? ""
        if code == presetCode {
            return
        }
        inputTextField.resignFirstResponder()
        if code == "" {
            //清空送出：不打 API，直接清掉註冊資料頁已填的碼
            parentVC?.setShareCode(Code: "")
            self.navigationController?.popViewController(animated: true)
            return
        }
        checkShareMember(Code: code)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Text Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        topScrollView.contentOffset = CGPoint.init(x: 0, y: textBackV.frame.origin.y)
        inputMoreSpaceView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputMoreSpaceView.isHidden = true
        checkBtnState()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("Register Share Input Title", comment: "")
        introL.text = NSLocalizedString("Register Share Input Top", comment: "")
        belowL.adjustsFontSizeToFitWidth = true
        downBtn.layer.cornerRadius = downBtn.frame.size.height/2
        
        scanL.text = NSLocalizedString("Register Share Input Scan", comment: "")
        scanL.adjustsFontSizeToFitWidth = true
        msgL.text = NSLocalizedString("Register Share Input Msg", comment: "")
        msgL.adjustsFontSizeToFitWidth = true
        divL.text = NSLocalizedString("Register Share Input Div", comment: "")
        belowL.text = NSLocalizedString("Register Share Input Below", comment: "")
        
        //紫色主題（與 RegisterPurpleInputVC 同款）：淺灰底、深色字、白色圓角卡片與輸入框
        downBtn.backgroundColor = .clear
        downBtn.setTitleColor(.white, for: .normal)
        downBtn.setTitleColor(.white, for: .disabled)
        downBtn.layer.borderWidth = 0.5
        downBtn.layer.borderColor = Color_Purple.cgColor
        
        //掃碼卡片一律不淡化（舊程式輸入後會把 alpha 降到 0.2，看起來像停用）
        scanBgV.backgroundColor = .white
        scanBgV.alpha = 1
        //掃碼圖示原本是白色 QR 配紫色框角，放到白卡上會看不見，改成整張染紫
        scanImgV.image = scanImgV.image?.withRenderingMode(.alwaysTemplate)
        scanImgV.tintColor = Color_Purple
        scanBgV.layer.borderWidth = 1
        scanBgV.layer.borderColor = Color_Purple.cgColor
        scanBgV.layer.cornerRadius = 20
        
        textBgV.backgroundColor = .white
        textBgV.layer.borderWidth = 0.5
        textBgV.layer.borderColor = Color_Purple.cgColor
        textBgV.layer.cornerRadius = textBgV.frame.size.height/2
        
        for l in [introL, msgL, divL, belowL] {
            l?.textColor = .black
        }
        scanL.textColor = Color_Purple
        scanL.font = UIFont.boldSystemFont(ofSize: 23)
        inputTextField.textColor = .black
        
        downBtn.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
        inputMoreSpaceView.isHidden = true
        
        inputTextField.delegate = self
        inputTextField.addTarget(self, action: #selector(inputTextChanged(_:)), for: .editingChanged)
        inputTextField.keyboardType = .numberPad
        inputTextField.attributedPlaceholder = NSAttributedString(string: "MID", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        checkBtnState()
        if presetCode != "" {
            setCodeString(Code: presetCode)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if loadOnce {
            return
        }
        loadOnce = true
        barV.addGradienOfIndoGo()
        //版面定好後再畫一次按鈕漸層，避免用到 storyboard 的舊尺寸
        checkBtnState()
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
