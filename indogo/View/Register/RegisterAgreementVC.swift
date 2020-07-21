//
//  RegisterAgreementVC.swift
//  indogo
//
//  Created by mac on 2020/7/18.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class RegisterAgreementVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var agreementBackV: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIntroVC") as? RegisterIntroVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("Register Agreement Title", comment: "")
        agreementBackV.layer.cornerRadius = 20
        agreementBackV.clipsToBounds = true
        
        nextBtn.layer.cornerRadius = nextBtn.frame.height/2
        cancelBtn.layer.cornerRadius = nextBtn.frame.height/2
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = Color_Main_Red.cgColor
        
        nextBtn.setTitle(NSLocalizedString("agree", comment: ""), for: .normal)
        cancelBtn.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
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
