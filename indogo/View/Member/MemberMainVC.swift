//
//  MemberMainVC.swift
//  indogo
//
//  Created by mac on 2020/8/10.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MemberMainVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var memberImgV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var phoneL: UILabel!
    @IBOutlet weak var pointL: UILabel!
    @IBOutlet weak var reciterL: UILabel!
    @IBOutlet weak var transactionL: UILabel!
    @IBOutlet weak var callL: UILabel!
    @IBOutlet weak var aboutL: UILabel!
    @IBOutlet weak var termsL: UILabel!
    @IBOutlet weak var faqL: UILabel!
    @IBOutlet weak var logoutL: UILabel!
    
    var loadOnce = false
    
    //MARK: - Button-Action
    @IBAction func editAction(_ sender: Any) {
        
    }
    
    @IBAction func pointAction(_ sender: Any) {
    }
    
    @IBAction func reciteAction(_ sender: Any) {
    }
    @IBAction func tansactionAction(_ sender: Any) {
    }
    
    @IBAction func callAction(_ sender: Any) {
        let phone = "0287928773"
        let cleanPhoneNumber = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        let urlString:String = "tel://\(cleanPhoneNumber)"

        if let phoneCallURL = URL(string: urlString) {
            if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
        /*
        let url = URL(string: "telprompt:0287928773")
        if UIApplication.shared.canOpenURL(url!) {
            //UIApplication.shared.open(url!)
            UIApplication.shared.open(url!, options: [:], completionHandler:
                 nil)
        }*/
    }
    
    @IBAction func aboutAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "PureWebVC") as? PureWebVC
        nextVC?.setTitleAndCallURL(URL: "https://prod.indogo.link/tomcat_images/REMIT_INFO.html", Title: NSLocalizedString("Profile Main About", comment: ""))
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func termsAction(_ sender: Any) {
        
    }
    
    @IBAction func faqAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "PureWebVC") as? PureWebVC
        nextVC?.setTitleAndCallURL(URL: "https://prod.indogo.link/tomcat_images/REMIT_INFO.html", Title: NSLocalizedString("Profile Main Faq", comment: ""))
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        AppDelegate.shared().userLogout()
        AppDelegate.shared().changeRootOfFunc(Type: .main)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameL.text = AppDelegate.shared().memberData["member_name"]
        phoneL.text = AppDelegate.shared().memberData["app_phone_no"]
        backL.text = NSLocalizedString("Profile Main Title", comment: "")
        pointL.text = NSLocalizedString("Profile Main Point", comment: "")
        reciterL.text = NSLocalizedString("Profile Main Reciter", comment: "")
        transactionL.text = NSLocalizedString("Profile Main Transaction", comment: "")
        callL.text = NSLocalizedString("Profile Main Call", comment: "")
        aboutL.text = NSLocalizedString("Profile Main About", comment: "")
        termsL.text = NSLocalizedString("Profile Main Terms", comment: "")
        faqL.text = NSLocalizedString("Profile Main Faq", comment: "")
        logoutL.text = NSLocalizedString("Profile Main Logout", comment: "")
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
