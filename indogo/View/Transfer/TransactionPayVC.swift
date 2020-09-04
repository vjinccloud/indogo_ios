//
//  TransactionPayVC.swift
//  indogo
//
//  Created by mac on 2020/9/4.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class TransactionPayVC: UIViewController {
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var paymentInfoL: UILabel!
    @IBOutlet weak var totalTWDL: UILabel!
    
    @IBOutlet weak var topScrollView: UIScrollView!
    
    @IBOutlet weak var upIntoL: UILabel!
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var minL: UILabel!
    @IBOutlet weak var minDownL: UILabel!
    @IBOutlet weak var secL: UILabel!
    @IBOutlet weak var secDownL: UILabel!
    
    @IBOutlet weak var barCodeBgV: UIView!
    @IBOutlet weak var barV1: UIView!
    @IBOutlet weak var barL1: UILabel!
    @IBOutlet weak var barV2: UIView!
    @IBOutlet weak var barL2: UILabel!
    @IBOutlet weak var barV3: UIView!
    @IBOutlet weak var barL3: UILabel!
    @IBOutlet weak var enlargeBtn: UIButton!
    
    @IBOutlet weak var reloadL: UILabel!
    @IBOutlet weak var warnL: UILabel!
    
    var loadOnce = false
    var transferStateObj:TransferStateObj!
    var orderCheckStateObj:TransferOrderCheckObj!
    var payment_info:String = ""
    
    //MARK: - API
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        AppDelegate.shared().showTopButton()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("Transfer PayStep Title", comment: "")
        upIntoL.text = NSLocalizedString("Transfer PayStep Up Intro", comment: "")
        warnL.text = NSLocalizedString("Transfer PayStep Warn", comment: "")
        paymentInfoL.text = payment_info
        totalTWDL.text = "Total TWD \(transferStateObj.total ?? "0")"
        minDownL.text = NSLocalizedString("Transfer PayStep Min Title", comment: "")
        secDownL.text = NSLocalizedString("Transfer PayStep Sec Title", comment: "")
        enlargeBtn.setTitle(NSLocalizedString("Transfer PayStep Btn Enlarge", comment: ""), for: .normal)
        reloadL.text = NSLocalizedString("Transfer PayStep Btn Reload", comment: "")
        barL1.isHidden = true
        barL2.isHidden = true
        barL3.isHidden = true
        
        let serchBankobj = UtilityTool().searchBankObj(BankCode: transferStateObj.bank_code!)
        
        let imgurl = serchBankobj.bank_photo!
        let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        iconImgV.kf.setImage(with: urlhaed)
        
        barCodeBgV.layer.borderColor = UIColor.black.cgColor
        barCodeBgV.layer.borderWidth = 0.5
        
        enlargeBtn.layer.cornerRadius = enlargeBtn.frame.size.height/2
        enlargeBtn.layer.borderColor = Color_Main_Red.cgColor
        enlargeBtn.layer.borderWidth = 0.5
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
