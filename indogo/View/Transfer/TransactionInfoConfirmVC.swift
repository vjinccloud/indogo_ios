//
//  TransactionInfoConfirmVC.swift
//  indogo
//
//  Created by mac on 2020/9/3.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class TransactionInfoConfirmVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    
    @IBOutlet weak var backgV: UIView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var accountL: UILabel!
    @IBOutlet weak var accountNameL: UILabel!
    @IBOutlet weak var twdL: UILabel!
    @IBOutlet weak var twdVL: UILabel!
    @IBOutlet weak var feeL: UILabel!
    @IBOutlet weak var feeVL: UILabel!
    @IBOutlet weak var usePointL: UILabel!
    @IBOutlet weak var usePointVL: UILabel!
    @IBOutlet weak var totalL: UILabel!
    @IBOutlet weak var totalVL: UILabel!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    //MARK: - API
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionAgreeMentVC") as? TransactionAgreeMentVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameL.text = NSLocalizedString("Transfer Confirm Title", comment: "")
        twdL.text = NSLocalizedString("Transfer Confirm TWD Title", comment: "")
        feeL.text = NSLocalizedString("Transfer Confirm Fee Title", comment: "")
        usePointL.text = NSLocalizedString("Transfer Confirm UsePoint Title", comment: "")
        totalL.text = NSLocalizedString("Transfer Confirm Total Title", comment: "")
        nameL.adjustsFontSizeToFitWidth = true
        nameL.textAlignment = .center
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
        
        backgV.layer.cornerRadius = 5
        
        let obj = AppDelegate.shared().transactionObj
        var valueStr = "\(obj.ntdValue)".stringToIntDecimalString()
        twdVL.text = "NTD \(valueStr)"
        feeVL.text = "\(obj.feeValue)"
        if obj.usePoint > 0 {
            usePointVL.text = "-\(obj.usePoint)"
        } else {
            usePointVL.text = "\(obj.usePoint)"
        }
        
        valueStr = "\(obj.totalNtdValue)".stringToIntDecimalString()
        totalVL.text = "\(valueStr)"
        
        accountL.text = obj.recipientObj.bank_acc
        accountNameL.text = obj.recipientObj.recipient_name
        accountNameL.adjustsFontSizeToFitWidth = true
        
        let serchBankobj = UtilityTool().searchBankObj(BankName: obj.recipientObj.bank_name!)
        let imgurl = serchBankobj.bank_photo!
        let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        iconImgV.kf.setImage(with: urlhaed)
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
