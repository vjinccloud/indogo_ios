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

class AddRecipientVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backL: UILabel!
    
    @IBOutlet weak var codeBgV: UIView!
    @IBOutlet weak var accountBgV: UIView!
    @IBOutlet weak var accountTextfield: UITextField!
    @IBOutlet weak var bankCodeTextfield: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var bankListTableView: UITableView!
    var showBankList:[BankObj] = []
    
    //MARK: - Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showBankList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BankListTableViewCell", for: indexPath) as! BankListTableViewCell
        let cellData = showBankList[indexPath.row]
        let serchBankobj = UtilityTool().searchBankObj(BankName: cellData.bank_name!)
        
        let imgurl = serchBankobj.bank_photo!
        let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        cell.bankIconImgV.kf.setImage(with: urlhaed)
        cell.bankL.text = cellData.bank_name
        
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = showBankList[indexPath.row]
        bankCodeTextfield.text = cellData.bank_name
        //bankCodeTextfield.resignFirstResponder()
        accountTextfield.becomeFirstResponder()
    }
    
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
    
    func reloadDataAndTable(Str str:String) {
        if str == "" {
            showBankList = AppDelegate.shared().bankList
        } else {
            showBankList = []
            
            for i in 0..<AppDelegate.shared().bankList.count {
                let obj = AppDelegate.shared().bankList[i]
                
                if obj.bank_name.lowercased().contains(str.lowercased()) {
                    showBankList.append(obj)
                }
            }
        }
        
        bankListTableView.reloadData()
    }
    
    //MARK: - Text Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == bankCodeTextfield {
            bankListTableView.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        bankListTableView.isHidden = true
        checkBtnState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        reloadDataAndTable(Str: newString)
        return true

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
    
    func generateToolBar() ->UIToolbar {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        
        let toolBar:UIToolbar = UIToolbar()
        toolBar.items = [flexibleSpace,done]
        toolBar.sizeToFit()
        
        return toolBar
    }
    
    @objc func doneAction() {
        closeText()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.setupHideKeyboardOnTap()
        bankCodeTextfield.inputAccessoryView = generateToolBar()
        accountTextfield.inputAccessoryView = generateToolBar()
        
        showBankList = AppDelegate.shared().bankList
        bankListTableView.separatorStyle = .none
        bankListTableView.delegate = self
        bankListTableView.dataSource = self
        bankListTableView.isHidden = true
        bankListTableView.backgroundColor = .white
        
        bankCodeTextfield.keyboardType = .default
        bankCodeTextfield.autocorrectionType = .no
        accountTextfield.keyboardType = .numberPad
        accountTextfield.delegate = self
        bankCodeTextfield.delegate = self
        
        accountTextfield.autocapitalizationType = .allCharacters
        bankCodeTextfield.autocapitalizationType = .allCharacters
        
        backL.text = ""
        
        bankCodeTextfield.becomeFirstResponder()
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
