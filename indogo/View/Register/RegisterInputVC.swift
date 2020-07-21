//
//  RegisterInputVC.swift
//  indogo
//
//  Created by mac on 2020/7/21.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterInputVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputMoreSpaceView: UIView!
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var camBtn: UIButton!
    
    @IBOutlet weak var topScrollView: UIScrollView!
    
    @IBOutlet weak var nameL: UILabel!
    
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var accountBtn: UIButton!
    @IBOutlet weak var accountTextfield: UITextField!
    
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var phoneTextfield: UITextField!
    
    @IBOutlet weak var passView: UIView!
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var showPassBtn: UIButton!
    
    @IBOutlet weak var rePassView: UIView!
    @IBOutlet weak var rePassBtn: UIButton!
    @IBOutlet weak var rePassTextField: UITextField!
    @IBOutlet weak var showRePassBtn: UIButton!
    
    @IBOutlet weak var noArcView: UIView!
    @IBOutlet weak var inputArcView: UIView!
    @IBOutlet weak var arcTextfield: UITextField!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
    }
    @IBAction func callCamActon(_ sender: Any) {
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
        rePassTextField.isSecureTextEntry.toggle()
        
        if rePassTextField.isSecureTextEntry {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "noview_b"), for: .normal)
        } else {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
    }
    
    //MARK: - Text Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        inputMoreSpaceView.isHidden = false
        if textField == accountTextfield {
            //topScrollView.contentOffset = CGPoint(x: 0, y: 1200)
            accountBtn.backgroundColor = Color_Main_LightGray
            accountTextfield.textColor = .black
        } else if textField == phoneTextfield {
            //topScrollView.contentOffset = CGPoint(x: 0, y: 1262)
            phoneBtn.backgroundColor = Color_Main_LightGray
            phoneTextfield.textColor = .black
        } else if textField == passTextField {
            //topScrollView.contentOffset = CGPoint(x: 0, y: 1324)
            passBtn.backgroundColor = Color_Main_LightGray
            passTextField.textColor = .black
        } else if textField == rePassTextField {
            //topScrollView.contentOffset = CGPoint(x: 0, y: 1386)
            rePassBtn.backgroundColor = Color_Main_LightGray
            rePassTextField.textColor = .black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputMoreSpaceView.isHidden = true
        if textField == accountTextfield {
            accountBtn.backgroundColor = Color_Main_DarkGray
            accountTextfield.textColor = .white
        } else if textField == phoneTextfield {
            phoneBtn.backgroundColor = Color_Main_DarkGray
            phoneTextfield.textColor = .white
        } else if textField == passTextField {
            passBtn.backgroundColor = Color_Main_DarkGray
            passTextField.textColor = .white
        } else if textField == rePassTextField {
            rePassBtn.backgroundColor = Color_Main_DarkGray
            rePassTextField.textColor = .white
        }
    }
    
    /*
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if !accountTextfield.isFirstResponder, !phoneTextfield.isFirstResponder, !passTextField.isFirstResponder, !rePassTextField.isFirstResponder, !arcTextfield.isFirstResponder {
            topScrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
        return true
    }*/
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("back", comment: "")
        accountBtn.layer.cornerRadius = accountBtn.frame.size.height/2
        phoneBtn.layer.cornerRadius = phoneBtn.frame.size.height/2
        passBtn.layer.cornerRadius = passBtn.frame.size.height/2
        rePassBtn.layer.cornerRadius = rePassBtn.frame.size.height/2
        registerBtn.layer.cornerRadius = registerBtn.frame.size.height/2
        
        passTextField.placeholder = NSLocalizedString("passcode", comment: "")
        rePassTextField.placeholder = NSLocalizedString("TFFRHP Change placehold2", comment: "")
        registerBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        
        passTextField.isSecureTextEntry = true
        rePassTextField.isSecureTextEntry = true
        
        accountTextfield.delegate = self
        phoneTextfield.delegate = self
        passTextField.delegate = self
        rePassTextField.delegate = self
        arcTextfield.isEnabled = false
        
        accountTextfield.placeholder = NSLocalizedString("Register Input Name", comment: "")
        phoneTextfield.placeholder = NSLocalizedString("Register Input Phone", comment: "")
        passTextField.placeholder = NSLocalizedString("Register Input Pass", comment: "")
        rePassTextField.placeholder = NSLocalizedString("Register Input rePass", comment: "")
        
        inputArcView.isHidden = true
        inputMoreSpaceView.isHidden = true
        nameL.text = NSLocalizedString("Register Input Foto", comment: "")
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
