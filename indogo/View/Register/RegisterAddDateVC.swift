//
//  RegisterAddDateVC.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/3/8.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Alamofire

class RegisterAddDateVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputMoreSpaceView: UIView!
    @IBOutlet weak var backL: UILabel!
    
    @IBOutlet weak var topScrollView: UIScrollView!
    
    @IBOutlet weak var phoneTitle: UILabel!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var phoneTextfield: UITextField!
    
    @IBOutlet weak var phoneNewTitle: UILabel!
    @IBOutlet weak var phoneNewView: UIView!
    @IBOutlet weak var phoneNewBtn: UIButton!
    @IBOutlet weak var phoneNewTextfield: UITextField!
    
    //ARC 發證日期
    @IBOutlet weak var issueTitle: UILabel!
    @IBOutlet weak var issueView: UIView!
    @IBOutlet weak var issueBtn: UIButton!
    @IBOutlet weak var issueTextfield: UITextField!
    var dateIssue:Date?
    var issueDatePicker:UIDatePicker!
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var arcCodeL: UILabel!
    
    var dateStart:Date = Date()
    var dateEnd:Date = Date()
    
    var startDatePicker:UIDatePicker!
    var endDatePicker:UIDatePicker!
    var nowTextIdx = 0
    
    func addDatePicker() {
        
        let dateNow = Date()
        
        if phoneTextfield != nil {
            let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            datePicker.datePickerMode = .date
            
            //datePicker.locale = NSLocale(localeIdentifier: "zh_TW") as Locale
            
            dateStart = dateNow.addDays(Days: 0, Month: 0, Year: -17)
            datePicker.date = dateStart
            datePicker.minimumDate = dateNow.addDays(Days: 0, Month: 0, Year: -65)
            datePicker.maximumDate = dateNow.addDays(Days: 0, Month: 0, Year: -17)
            phoneTextfield.inputView = datePicker
            let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.datePickerDone))
            let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
            phoneTextfield.inputAccessoryView = toolBar
            startDatePicker = datePicker
            if #available(iOS 14, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
        }
        
        if phoneNewTextfield != nil {
            let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            datePicker.datePickerMode = .date
            dateEnd = dateNow
            datePicker.date = dateEnd
            datePicker.minimumDate = dateNow
            datePicker.maximumDate = dateNow.addDays(Days: 0, Month: 0, Year: 5)
            
            phoneNewTextfield.inputView = datePicker
            let doneButton = UIBarButtonItem.init(title: NSLocalizedString("ok", comment: ""), style: .done, target: self, action: #selector(self.datePickerDone))
            let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
            phoneNewTextfield.inputAccessoryView = toolBar
            endDatePicker = datePicker
            if #available(iOS 14, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
        }
        
        if issueTextfield != nil {
            let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            datePicker.datePickerMode = .date
            //發證日期：最晚今天、最早往前 10 年（與 Android 一致，10 年為暫定值）
            datePicker.date = dateNow
            datePicker.minimumDate = dateNow.addDays(Days: 0, Month: 0, Year: -10)
            datePicker.maximumDate = dateNow
            
            issueTextfield.inputView = datePicker
            let doneButton = UIBarButtonItem.init(title: NSLocalizedString("ok", comment: ""), style: .done, target: self, action: #selector(self.datePickerDone))
            let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
            issueTextfield.inputAccessoryView = toolBar
            issueDatePicker = datePicker
            if #available(iOS 14, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
        }
    }
    
    @objc func datePickerDone() {
        phoneTextfield.resignFirstResponder()
        phoneNewTextfield.resignFirstResponder()
        issueTextfield.resignFirstResponder()
        
        if nowTextIdx == 2 {
            let date = issueDatePicker.date
            dateIssue = date
            issueTextfield.text = date.toString()
        } else if nowTextIdx == 0 {
            let date = startDatePicker.date
            dateStart = date
            phoneTextfield.text = date.toString()
        } else if nowTextIdx == 1 {
            let date = endDatePicker.date
            dateEnd = date
            phoneNewTextfield.text = date.toString()
        }
        updateRegisterBtnState()
    }
    
    //日期整列（含右側箭頭）都可點
    @objc func dateRowTapped(_ sender: UIButton) {
        if sender == phoneBtn {
            phoneTextfield.becomeFirstResponder()
        } else if sender == phoneNewBtn {
            phoneNewTextfield.becomeFirstResponder()
        } else if sender == issueBtn {
            issueTextfield.becomeFirstResponder()
        }
    }
    
    //ARC 發證日期：必填、不可晚於今天、不可晚於到期日。回傳錯誤字串的 key，通過回傳空字串
    func checkIssueDate() -> String {
        guard let issue = dateIssue else {
            return "Register Error ARC Issue Date Empty"
        }
        let calendar = Calendar.current
        let issueDay = calendar.startOfDay(for: issue)
        if issueDay > calendar.startOfDay(for: Date()) {
            return "Register Error ARC Issue Date Future"
        }
        if issueDay > calendar.startOfDay(for: dateEnd) {
            return "Register Error ARC Issue Date After Expire"
        }
        return ""
    }
    
    func updateRegisterBtnState() {
        let pass = checkIssueDate() == ""
        registerBtn.isEnabled = pass
        registerBtn.alpha = pass ? 1.0 : 0.5
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        nowTextIdx = textField.tag
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //日期欄只能用日期選擇器選
        return false
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        arcCodeL.text = AppDelegate.shared().tempRegisterObj.arcNum
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("back", comment: "")
        phoneTitle.text = NSLocalizedString("Register AddDate Title", comment: "")
        phoneNewTitle.text = NSLocalizedString("Register AddDate Title2", comment: "")
        
        phoneBtn.layer.cornerRadius = phoneBtn.frame.size.height/2
        phoneBtn.layer.borderColor =  UIColor.white.cgColor
        phoneBtn.layer.borderWidth = 0.5
        phoneTextfield.delegate = self
        phoneTextfield.tag = 0
        phoneTextfield.inputAccessoryView = generateToolBar()
        //phoneTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Input Phone", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        phoneNewBtn.layer.cornerRadius = phoneNewBtn.frame.size.height/2
        phoneNewBtn.layer.borderColor =  UIColor.white.cgColor
        phoneNewBtn.layer.borderWidth = 0.5
        phoneNewTextfield.delegate = self
        phoneNewTextfield.tag = 1
        phoneNewTextfield.inputAccessoryView = generateToolBar()
        
        issueTitle.text = NSLocalizedString("Register ARC Issue Date", comment: "")
        issueBtn.layer.cornerRadius = issueBtn.frame.size.height/2
        issueBtn.layer.borderColor =  UIColor.white.cgColor
        issueBtn.layer.borderWidth = 0.5
        issueTextfield.delegate = self
        issueTextfield.tag = 2
        issueTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register ARC Issue Date Placeholder", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        phoneBtn.addTarget(self, action: #selector(dateRowTapped(_:)), for: .touchUpInside)
        phoneNewBtn.addTarget(self, action: #selector(dateRowTapped(_:)), for: .touchUpInside)
        issueBtn.addTarget(self, action: #selector(dateRowTapped(_:)), for: .touchUpInside)
        //phoneNewTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Input Phone", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        registerBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        registerBtn.layer.cornerRadius = registerBtn.frame.size.height/2
        registerBtn.layer.borderColor = Color_Main_Red.cgColor
        registerBtn.layer.borderWidth = 0.5
        
        //dateStart = obj.getStartDate()
        //dateEnd = obj.getEndDate()
        addDatePicker()
        phoneTextfield.text = dateStart.toString()
        phoneNewTextfield.text = dateEnd.toString()
        //發證日期必填，不預填
        issueTextfield.text = ""
        updateRegisterBtnState()
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
        phoneTextfield.resignFirstResponder()
        phoneNewTextfield.resignFirstResponder()
        issueTextfield.resignFirstResponder()
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        
        let issueError = checkIssueDate()
        if issueError != "" {
            AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString(issueError, comment: ""))
            return
        }
        
        AppDelegate.shared().tempRegisterObj.birthday = phoneTextfield.text!
        AppDelegate.shared().tempRegisterObj.arcDay = phoneNewTextfield.text!
        AppDelegate.shared().tempRegisterObj.arcIssueDay = dateIssue!.toString()
        registerStep1()
        /*
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDTakePhotoVC") as? RegisterIDTakePhotoVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
         */
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - API
    func registerStep1() {
        
        let obj = AppDelegate.shared().tempRegisterObj
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_RegisterStep1;
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(obj.account!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "name")
            multipartFormData.append(obj.phoneNum!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "phone")
            multipartFormData.append(obj.arcNum!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "arc_no")
            multipartFormData.append(UtilityTool().sha256(Code: obj.passwaord!).data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "password")
            multipartFormData.append(obj.shareCode.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "share_member_id")
            multipartFormData.append(obj.arcDay.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "arc_expire_date")
            multipartFormData.append(obj.arcIssueDay.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "arc_issue_date")
            multipartFormData.append(obj.birthday.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "birthday")
            
        }, usingThreshold: UInt64.init(), to: todoEndpoint, method: .post, headers: headers) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                upload.response { response in
                    
                    AppDelegate.shared().removeLoadingView()
                    
                    guard response.error == nil else {
                        // got an error in getting the data, need to handle it
                        print("error calling on \(todoEndpoint), response = \(response)")
                        print(response.error!)
                        return
                    }
                    
                    //下一步，簡訊
                    let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                    Dlog("responseStr = \(responseStr ?? "")")
                    let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                    
                    if result == ResponseState.ok {
                        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterEnterSMSCodeVC") as? RegisterEnterSMSCodeVC
                        nextVC?.registerFromIndex = 1
                        self.navigationController?.pushViewController(nextVC!, animated: true)
                    } else if result == ResponseState.failed {
                        AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
    
    func registerStep1NextAction() {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDTakePhotoVC") as? RegisterIDTakePhotoVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
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
