//
//  ForgotPassChangeVC.swift
//  indogo
//
//  Created by mac on 2020/7/18.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ForgotPassChangeVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var warnL: UILabel!
    @IBOutlet weak var warn2L: UILabel!
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var showPassBtn: UIButton!
    @IBOutlet weak var repassBtn: UIButton!
    @IBOutlet weak var repassTextField: UITextField!
    @IBOutlet weak var showRePassBtn: UIButton!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showPassAction(_ sender: Any) {
        passTextField.isSecureTextEntry.toggle()
        
        if passTextField.isSecureTextEntry {
            showPassBtn.setBackgroundImage(UIImage.init(named: "noview_b"), for: .normal)
        } else {
            showPassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
    }
    
    @IBAction func showRePassAction(_ sender: Any) {
        repassTextField.isSecureTextEntry.toggle()
        
        if repassTextField.isSecureTextEntry {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "noview_b"), for: .normal)
        } else {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
    }
    
    //MARK: - Text Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == passTextField {
            passBtn.backgroundColor = Color_Main_LightGray
            warnL.isHidden = false
        } else if textField == repassTextField {
            repassBtn.backgroundColor = Color_Main_LightGray
            warn2L.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == passTextField {
            passBtn.backgroundColor = Color_Main_DarkGray
            warnL.isHidden = true
        } else if textField == repassTextField {
            repassBtn.backgroundColor = Color_Main_DarkGray
            warn2L.isHidden = true
        }
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("back", comment: "")
        passBtn.layer.cornerRadius = passBtn.frame.size.height/2
        repassBtn.layer.cornerRadius = repassBtn.frame.size.height/2
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        
        passTextField.placeholder = NSLocalizedString("passcode", comment: "")
        repassTextField.placeholder = NSLocalizedString("TFFRHP Change placehold2", comment: "")
        nextBtn.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
        
        passTextField.isSecureTextEntry = true
        repassTextField.isSecureTextEntry = true
        
        passTextField.delegate = self
        repassTextField.delegate = self
        
        warnL.text = NSLocalizedString("TFFRHP Change warn", comment: "")
        warn2L.text = NSLocalizedString("TFFRHP Change warn2", comment: "")
        warnL.isHidden = true
        warn2L.isHidden = true
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
