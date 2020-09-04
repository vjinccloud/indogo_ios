//
//  MemberEditVC.swift
//  indogo
//
//  Created by mac on 2020/8/18.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class MemberEditVC: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, CustomAlertDelegate {

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
    
    @IBOutlet weak var hasArcView: UIView!
    @IBOutlet weak var arcCodeL: UILabel!
    
    @IBOutlet weak var firstPhotoTitleL: UILabel!
    @IBOutlet weak var secPhotoTitleL: UILabel!
    @IBOutlet weak var thirdPhotoTitleL: UILabel!
    @IBOutlet weak var forthPhotoTitleL: UILabel!
    @IBOutlet weak var signTitleL: UILabel!
    
    @IBOutlet weak var firstImgV: UIImageView!
    @IBOutlet weak var secImgV: UIImageView!
    @IBOutlet weak var thirdImgV: UIImageView!
    @IBOutlet weak var forthImgV: UIImageView!
    @IBOutlet weak var signImgV: UIImageView!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secView: UIView!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var forthView: UIView!
    @IBOutlet weak var signView: UIView!
    
    var meImg:UIImage!
    
    var frontImage:UIImage!
    var backImage:UIImage!
    var faceImg:UIImage!
    var passportImg:UIImage!
    var signImage:UIImage!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func takeFirstPhoto(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDTakeIntroVC") as? RegisterIDTakeIntroVC
        nextVC?.takePhotoType = PhotoIDType.frontFromEdit
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
        hideTopAndBottom()
    }
    
    @IBAction func takeSecPhoto(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDTakeIntroVC") as? RegisterIDTakeIntroVC
        nextVC?.takePhotoType = PhotoIDType.backFromEdit
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
        hideTopAndBottom()
    }
    
    @IBAction func takeThirdPhoto(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDWithSelfIntroVC") as? RegisterIDWithSelfIntroVC
        nextVC?.takePhotoType = .faceAndIdFromEdit
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
        hideTopAndBottom()
    }
    
    @IBAction func takeForthPhoto(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDTakeIntroVC") as? RegisterIDTakeIntroVC
        nextVC?.takePhotoType = PhotoIDType.passportFromEdit
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
        hideTopAndBottom()
    }
    
    @IBAction func signAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterMakeSignVC") as? RegisterMakeSignVC
        nextVC?.takePhotoType = PhotoIDType.signFromEdit
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
        hideTopAndBottom()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        AppDelegate.shared().tempRegisterObj = RegisterDataObj()
        AppDelegate.shared().tempRegisterObj.meImg = meImg
        AppDelegate.shared().tempRegisterObj.account = accountTextfield.text
        AppDelegate.shared().tempRegisterObj.phoneNum = phoneTextfield.text
        AppDelegate.shared().tempRegisterObj.arcNum = arcCodeL.text
        
        AppDelegate.shared().tempRegisterObj.frontImg = frontImage
        AppDelegate.shared().tempRegisterObj.backImg = backImage
        
        AppDelegate.shared().tempRegisterObj.faceImg = faceImg
        AppDelegate.shared().tempRegisterObj.passportImg = passportImg
        AppDelegate.shared().tempRegisterObj.signImg = signImage
    }
    
    @IBAction func callCamActon(_ sender: Any) {
        let customAlert = CustomAlertView.init(frame: topScrollView.frame)
        customAlert.initTwoActionAlert(Title: NSLocalizedString("Register Input Foto Select Title" , comment: ""), Content: "", NextBtn1Str: NSLocalizedString("Register Input Foto Select Camera" , comment: ""), NextBtn2Str: NSLocalizedString("Register Input Foto Select Gallery" , comment: ""), CancelBtn1Str: NSLocalizedString("cancel" , comment: ""))
        self.view.addSubview(customAlert)
        customAlert.customDelegate = self
    }
    
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        ImagePicker.GetCameraStatus(view: self,completion: { (scuess)->Void in
            if(scuess){
                //拍照
                let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterSelfPhotoVC") as? RegisterSelfPhotoVC
                nextVC?.takePhotoType = .normalFromEdit
                self.navigationController?.pushViewController(nextVC!, animated: true)
            }
            else{
                print("無法使用相機")
            }
        })
    }
    
    func customAlertnextActionSecond(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        ImagePicker.GetPhotoStatus(view: self,completion: { (scuess)->Void in
            if(scuess){
                self.initPhotoPicker()
            }
            else{
                print("無法使用相簿")
            }
        })
    }
    
    //MARK: - Camera
    func initPhotoPicker(){
        DispatchQueue.main.async{
            let photoPicker =  UIImagePickerController()
            photoPicker.delegate = self
            photoPicker.allowsEditing = false
            photoPicker.sourceType = .photoLibrary
            //在需要的地方present出来
            self.present(photoPicker, animated: true, completion: nil)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //UIImagePickerControllerOriginalImage  原始圖像
        //UIImagePickerControllerEditedImage    編輯後的圖片(開啓編輯該對象才存在)
        
        self.dismiss(animated: true, completion: {
            var img:UIImage? = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            if picker.allowsEditing {
                img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            }
            
            let data = img!.ImgPress(LimitInBytes: ImageLimitInBytes)
            print("allcount = \(data.count)")
            //img!.jpegData(compressionQuality: 0.2)
            if(data.count>512000){
                AppDelegate.shared().showAlertWithWindow(self, Message: "圖片過大，請重新選擇")
                return
            }
            
            self.setImage(Image: UIImage.init(data: data)!)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        picker.dismiss(animated: true, completion: nil) // 退出相機介面
    }
    
    //MARK: - Text Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == accountTextfield {
            accountBtn.backgroundColor = Color_Main_LightGray
            accountTextfield.textColor = .black
        } else if textField == phoneTextfield {
            phoneBtn.backgroundColor = Color_Main_LightGray
            phoneTextfield.textColor = .black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == accountTextfield {
            if textField.text!.count == 0 {
                accountBtn.backgroundColor = Color_Main_DarkGray
                accountTextfield.textColor = .white
            } else {
                accountBtn.backgroundColor = Color_Main_LightGray
                accountTextfield.textColor = .black
            }
        } else if textField == phoneTextfield {
            if textField.text!.count == 0 {
                phoneBtn.backgroundColor = Color_Main_DarkGray
                phoneTextfield.textColor = .white
            } else {
                phoneBtn.backgroundColor = Color_Main_LightGray
                phoneTextfield.textColor = .black
            }
        }
    }
    
    //MARK: - Utility
    func setTakedPic(Type type:PhotoIDType, Img img:UIImage) {
        if type == PhotoIDType.frontFromEdit {
            frontImage = img
            firstImgV.image = img
        } else if type == PhotoIDType.backFromEdit {
            backImage = img
            secImgV.image = img
        } else if type == PhotoIDType.faceAndIdFromEdit {
            faceImg = img
            thirdImgV.image = img
        } else if type == PhotoIDType.passportFromEdit {
            passportImg = img
            forthImgV.image = img
        } else if type == PhotoIDType.signFromEdit {
            signImage = img
            signImgV.image = UIImage.init(named: "note.png")
        }
        
    }
    
    public func setImage(Image img:UIImage) {
        iconBtn.setImage(img, for: .normal)
        iconBtn.imageView?.contentMode = .scaleAspectFill
        iconBtn.layer.cornerRadius = iconBtn.frame.size.height/2
        iconBtn.clipsToBounds = true
        AppDelegate.shared().saveIconImageToFile(Image: img)
        meImg = img
    }
    
    public func setArcCodeString(Code code:String) {
        hasArcView.isHidden = false
        arcCodeL.text = code
    }
    
    //因為要跟註冊共用，如果使用共通元件，須先隱藏
    func hideTopAndBottom() {
        AppDelegate.shared().hideTopButton()
        AppDelegate.shared().hideBottomMenu()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
        
        nextBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.layer.backgroundColor = Color_Main_Red.cgColor
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.layer.borderWidth = 0.5
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        
        firstPhotoTitleL.text = NSLocalizedString("Register ID Photo First", comment: "")
        secPhotoTitleL.text = NSLocalizedString("Register ID Photo Sec", comment: "")
        thirdPhotoTitleL.text = NSLocalizedString("Register ID Self First", comment: "")
        forthPhotoTitleL.text = NSLocalizedString("Register ID Self Sec", comment: "")
        signTitleL.text = NSLocalizedString("Register ID Self Sign", comment: "")
        
        firstView.layer.borderWidth = 0.5
        firstView.layer.borderColor = UIColor.white.cgColor
        firstView.layer.cornerRadius = 5
        firstView.clipsToBounds = true
        
        secView.layer.borderWidth = 0.5
        secView.layer.borderColor = UIColor.white.cgColor
        secView.layer.cornerRadius = 5
        secView.clipsToBounds = true
        
        thirdView.layer.borderWidth = 0.5
        thirdView.layer.borderColor = UIColor.white.cgColor
        thirdView.layer.cornerRadius = 5
        thirdView.clipsToBounds = true
        
        thirdView.layer.borderWidth = 0.5
        thirdView.layer.borderColor = UIColor.white.cgColor
        thirdView.layer.cornerRadius = 5
        thirdView.clipsToBounds = true
        
        signView.layer.borderWidth = 0.5
        signView.layer.borderColor = UIColor.white.cgColor
        signView.layer.cornerRadius = 5
        signView.clipsToBounds = true
        
        accountBtn.layer.cornerRadius = accountBtn.frame.size.height/2
        phoneBtn.layer.cornerRadius = phoneBtn.frame.size.height/2
        
        accountTextfield.isEnabled = false
        phoneTextfield.isEnabled = false
        
        accountBtn.backgroundColor = Color_Main_LightGray
        accountTextfield.textColor = .black
        
        phoneBtn.backgroundColor = Color_Main_LightGray
        phoneTextfield.textColor = .black
        
        nameL.text = AppDelegate.shared().memberData["member_name"]!
        accountTextfield.text = AppDelegate.shared().memberData["member_name"]!
        phoneTextfield.text = AppDelegate.shared().memberData["app_phone_no"]!
        arcCodeL.text = AppDelegate.shared().memberData["member_id"]!
        
        accountTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Input Name", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        phoneTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Input Phone", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        //下載圖片
        var imgurl = ServerURL + AppDelegate.shared().memberData["arc_photo"]!
        var urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        firstImgV.kf.setImage(with: urlhaed)
        
        imgurl = ServerURL + AppDelegate.shared().memberData["arc_back_photo"]!
        urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        secImgV.kf.setImage(with: urlhaed)
        
        imgurl = ServerURL + AppDelegate.shared().memberData["self_photo"]!
        urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        thirdImgV.kf.setImage(with: urlhaed)
        
        imgurl = ServerURL + AppDelegate.shared().memberData["id_card_photo"]!
        urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        forthImgV.kf.setImage(with: urlhaed)
        
        signImgV.image = UIImage.init(named: "note.png")
        
        setImage(Image: AppDelegate.shared().getIconImage())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.shared().showTopButton()
        AppDelegate.shared().showBottomMenu()
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
