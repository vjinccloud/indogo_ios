//
//  AddRecipientVC.swift
//  indogo
//
//  Created by mac on 2020/8/29.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class AddRecipientVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backL: UILabel!
    
    @IBOutlet weak var codeBgV: UIView!
    @IBOutlet weak var accountBgV: UIView!
    @IBOutlet weak var accountTextfield: UITextField!
    @IBOutlet weak var bankCodeTextfield: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    //MARK: - Utility
    func checkBtnState() {
        if bankCodeTextfield.text! != "", accountTextfield.text! != "" {
            nextBtn.isEnabled = true
            nextBtn.backgroundColor = Color_Main_Red
        } else {
            nextBtn.isEnabled = false
            nextBtn.backgroundColor = .clear
        }
    }
    
    func closeAll() {
        closeText()
    }
    
    func closeText() {
        bankCodeTextfield.resignFirstResponder()
        accountTextfield.resignFirstResponder()
    }
    
    //MARK: - Text Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkBtnState()
    }
    
    //MARK: - API
    func addRecipient() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "bank_code":bankCodeTextfield.text!, "bank_acc":accountTextfield.text!]
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_AddRecipient;
        
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
                
                AppDelegate.shared().recipientListObjs = []
                AppDelegate.shared().recipientShownListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.navigationController?.popViewController(animated: true)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        addRecipient()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        accountTextfield.keyboardType = .numberPad
        bankCodeTextfield.keyboardType = .numberPad
        accountTextfield.delegate = self
        bankCodeTextfield.delegate = self
        backL.text = ""
        
        bankCodeTextfield.placeholder = NSLocalizedString("Point Transfer Add Recipient Code PlaceHolder", comment: "")
        accountTextfield.placeholder = NSLocalizedString("Point Transfer Add Recipient Accounnt PlaceHolder", comment: "")
        
        codeBgV.layer.cornerRadius = codeBgV.frame.size.height/2
        accountBgV.layer.cornerRadius = accountBgV.frame.size.height/2
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle(NSLocalizedString("Point Transfer Add Recipient Next", comment: ""), for: .normal)
        nextBtn.backgroundColor = .clear
        nextBtn.layer.borderWidth = 0.5
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        nextBtn.isEnabled = false
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
