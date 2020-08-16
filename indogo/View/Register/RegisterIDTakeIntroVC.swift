//
//  RegisterIDTakeIntroVC.swift
//  indogo
//
//  Created by mac on 2020/8/4.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class RegisterIDTakeIntroVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var bottomL: UILabel!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var bottomImgV: UIImageView!
    
    var takePhotoType:PhotoIDType = PhotoIDType.front
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        ImagePicker.GetCameraStatus(view: self,completion: { (scuess)->Void in
            if(scuess){
                //拍照
                let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDCameraVC") as? RegisterIDCameraVC
                nextVC?.takePhotoType = self.takePhotoType
                self.navigationController?.pushViewController(nextVC!, animated: true)
            }
            else{
                print("無法使用相機")
            }
        })
        
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
        bottomL.text = NSLocalizedString("bottom for forgoet sec", comment: "")
        
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle(NSLocalizedString("Register ID Photo Intro", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if takePhotoType == PhotoIDType.front {
            bottomImgV.image = UIImage.init(named: "id_front.png")
            backL.text = NSLocalizedString("Register ID Photo Title Front", comment: "")
        } else if takePhotoType == PhotoIDType.back {
            bottomImgV.image = UIImage.init(named: "id_back.png")
            backL.text = NSLocalizedString("Register ID Photo Title Back", comment: "")
        } else if takePhotoType == PhotoIDType.passport {
            bottomImgV.image = UIImage.init(named: "visa.png")
            backL.text = NSLocalizedString("Register ID Photo Title Passport", comment: "")
        }
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
