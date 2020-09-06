//
//  TransferMainVC.swift
//  indogo
//
//  Created by mac on 2020/9/2.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class TransferMainVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var boxV: UIView!
    @IBOutlet weak var upNameL: UILabel!
    @IBOutlet weak var upTextLineV: UIView!
    @IBOutlet weak var downNameL: UILabel!
    @IBOutlet weak var downTextLineV: UIView!
    @IBOutlet weak var upTextField: UITextField!
    @IBOutlet weak var downTextField: UITextField!
    @IBOutlet weak var kirimL: UILabel!
    @IBOutlet weak var valueL: UILabel!
    @IBOutlet weak var pointL: UILabel!
    @IBOutlet weak var pointLeftL: UILabel!
    @IBOutlet weak var totalNTDTitleL: UILabel!
    @IBOutlet weak var totalNTDL: UILabel!
    @IBOutlet weak var leftBgV: UIView!
    @IBOutlet weak var leftPL: UILabel!
    @IBOutlet weak var leftTotalPL: UILabel!
    @IBOutlet weak var leftDownL: UILabel!
    @IBOutlet weak var rightBgV: UIView!
    @IBOutlet weak var rightTitleL: UILabel!
    
    var loadOnce = false
    var kursValue:Double = 0
    var calculateStyle = 0 //0是以台幣為主計算，1是以印尼幣為主
    var coinTransferPercent = 1
    var serviceCharge = 0
    var decresedCharge = 0
    var decresedChargeUnit = 50
    var totalChage = 0
    
    //MARK: - Utility
    func checkAndCalculateValue(UseStyle style:Int, NweString newString:String) {
        kursValue = Double(AppDelegate.shared().memberData["kurs_value"]!)!
        serviceCharge = Int(AppDelegate.shared().memberData["service_charge"]!)!
        var string = newString
        
        var upValue = Int(upTextField.text!.replacingOccurrences(of: ",", with: ""))
        var downValue = Int(downTextField.text!.replacingOccurrences(of: ",", with: ""))
         
        if style == 0 {
            if upTextField.text == "" {
                upTextField.text = "1"
                upValue = 1
            }
            downValue = Int(Double(upValue!) * kursValue)
            if downValue! < 1 {
                downValue! = 1
            }
        } else if style == 1 {
            if downTextField.text == "" {
                downTextField.text = "1"
                downValue = 1
            }
            upValue = Int(Double(downValue!) / kursValue)
            if upValue! < 1 {
                upValue! = 1
            }
        } else if style == 2 {
            if string == "" {
                string = "1"
                //upTextField.text = "1"
            }
            
            upValue = Int(string)
            downValue = Int(Double(upValue!) * kursValue)
            downTextField.text = "\(downValue ?? 1)".stringToIntDecimalString()
        } else if style == 3 {
            if string == "" {
                string = "1"
                //downTextField.text = "1"
            }
            
            downValue = Int(string)
            upValue = Int(Double(downValue!) / kursValue)
            if upValue! < 1 {
                upValue! = 1
            }
            upTextField.text = "\(upValue ?? 1)".stringToIntDecimalString()
        }
        
        if style < 2 {
            upTextField.text = "\(upValue ?? 1)".stringToIntDecimalString()
            downTextField.text = "\(downValue ?? 1)".stringToIntDecimalString()
        }
        
        valueL.text = "\(serviceCharge)"
        if decresedCharge == 0 {
            pointLeftL.text = "\(decresedCharge)"
        } else {
            pointLeftL.text = "-\(decresedCharge)"
        }
        
        totalChage = upValue! + serviceCharge - decresedCharge
        totalNTDL.text = "\(totalChage)".stringToIntDecimalString()
    }
    
    //MARK: - Button Action
    @IBAction func leftBtnAction(_ sender: Any) {
        if decresedCharge == serviceCharge {
            decresedCharge = 0
        } else {
            decresedCharge += decresedChargeUnit
            if decresedCharge > serviceCharge {
                decresedCharge = serviceCharge
            }
        }
        
        checkAndCalculateValue(UseStyle: 0, NweString: "")
    }

    @IBAction func rightBtnAction(_ sender: Any) {
        AppDelegate.shared().transactionObj = TransactionObj()
        AppDelegate.shared().transactionObj.ntdValue = Int(upTextField.text!.replacingOccurrences(of: ",", with: ""))!
        AppDelegate.shared().transactionObj.targetValue = Int(downTextField.text!.replacingOccurrences(of: ",", with: ""))!
        AppDelegate.shared().transactionObj.feeValue = serviceCharge
        AppDelegate.shared().transactionObj.usePoint = decresedCharge
        AppDelegate.shared().transactionObj.totalNtdValue = totalChage
        
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "RecipientListVC") as? RecipientListVC
        nextVC!.canSelectForTransfer = true
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - Text Delegate
    func closeAll() {
        closeText()
    }
    
    func closeText() {
        upTextField.resignFirstResponder()
        downTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == upTextField {
            upTextField.text = upTextField.text!.replacingOccurrences(of: ",", with: "")
        } else if textField == downTextField {
            downTextField.text = downTextField.text!.replacingOccurrences(of: ",", with: "")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var mode = 0
        if textField == upTextField {
            mode = 0
        } else if textField == downTextField {
            mode = 1
        }
        checkAndCalculateValue(UseStyle: mode, NweString: "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if newString.contains(".") || newString.contains("-") {
            //let str = newString.replacingOccurrences(of: "..", with: ".")
            //textField.text = str
            return false
        }
        
        if textField==upTextField {
            if newString.count == 10 {
                return false
            }
            checkAndCalculateValue(UseStyle: 2, NweString: newString)
        } else if textField==downTextField {
            if newString.count == 10 {
                return false
            }
            checkAndCalculateValue(UseStyle: 3, NweString: newString)
        }
        
        return true
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        upTextLineV.isHidden = true
        downTextLineV.isHidden = true
        boxV.layer.borderWidth = 1
        boxV.layer.borderColor = UIColor.lightGray.cgColor
        
        leftBgV.layer.cornerRadius = leftBgV.frame.size.height/2
        leftBgV.layer.borderWidth = 1
        leftBgV.layer.borderColor = Color_Main_Red.cgColor
        leftPL.backgroundColor = .clear
        leftPL.layer.backgroundColor = Color_Main_Red.cgColor
        leftPL.layer.cornerRadius = leftPL.frame.size.height/2
        
        rightBgV.layer.cornerRadius = rightBgV.frame.size.height/2
        
        upTextField.keyboardType = .numberPad
        downTextField.keyboardType = .numberPad
        upTextField.delegate = self
        downTextField.delegate = self
        
        upNameL.text = NSLocalizedString("Transfer Main Box Up Title", comment: "")
        downNameL.text = NSLocalizedString("Transfer Main Box Down Title", comment: "")
        kirimL.text = NSLocalizedString("Transfer Main Charge Title", comment: "")
        pointL.text = NSLocalizedString("Transfer Main Use Point Title", comment: "")
        totalNTDTitleL.text = NSLocalizedString("Transfer Main Total Money", comment: "")
        leftDownL.text = NSLocalizedString("Transfer Main Total Point Title", comment: "")
        rightTitleL.text = NSLocalizedString("send", comment: "")
        
        checkAndCalculateValue(UseStyle:0, NweString: "")
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
        
        AppDelegate.shared().nowBottomMenuType = .transaction
        AppDelegate.shared().bottomMenu.paintMenu()
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
