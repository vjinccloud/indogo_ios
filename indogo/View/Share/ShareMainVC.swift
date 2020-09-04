//
//  ShareMainVC.swift
//  indogo
//
//  Created by mac on 2020/8/19.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ShareMainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
        @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var pointBtn: UIButton!
    @IBOutlet weak var qrCodeImgV: UIImageView!
    @IBOutlet weak var midL: UILabel!
    @IBOutlet weak var addPointL: UILabel!
    @IBOutlet weak var transferPointL: UILabel!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var hostoryTableView: UITableView!
    
    @IBOutlet weak var tableBackV: UIView!
    
    var loadOnce = false
    var loadMemberOnce = false
    
    //MARK: - API
    public func getShareContent() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "doc_name":"分享文案"]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_GetDoc;
        
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
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "分享文案")
                if result == ResponseState.ok {
                    self.shareStep2()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: Lang_APIDecodeFail)
                }
        }
    }
    
    func shareStep2() {
        //let activityVC = UIActivityViewController(activityItems: [userImage.image!,userName.text!,userBlog.text!], applicationActivities: nil)
        let activityVC = UIActivityViewController(activityItems: [AppDelegate.shared().shareContent], applicationActivities: nil)
        // 顯示出我們的 activityVC。
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    //MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        view.backgroundColor = .black
        
        for i in 0..<4 {
            let startX:CGFloat = CGFloat(i) * 0.25 * view.frame.size.width
            let label = UILabel.init(frame: CGRect.init(x: startX, y: 0, width: 0.25 * view.frame.size.width, height: view.frame.size.height))
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.text = NSLocalizedString("History Point Cell \(i+1)", comment: "")
            view.addSubview(label)
            label.textAlignment = .center
            
            if i>0, i<4 {
                let line = UIView.init(frame: CGRect.init(x: startX, y: 0, width: 0.5, height: view.frame.size.height))
                line.backgroundColor = .white
                view.addSubview(line)
            }
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDelegate.shared().historyListObj.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pointhistorycell", for: indexPath) as! PointHistoryTableViewCell
        
        let obj = AppDelegate.shared().historyListObj[indexPath.row]
        cell.cell1L.text = obj.show_time
        cell.cell2L.text = obj.reason_show
        let pointValue = Int(obj.remit_point)!
        if pointValue >= 0 {
            cell.cell3L.text = "+ \(pointValue)"
            cell.contentView.backgroundColor = .clear
            cell.backgroundColor = .clear
        } else {
            cell.cell3L.text = "- \(abs(pointValue))"
            cell.contentView.backgroundColor = Color_Main_LightGray
            cell.backgroundColor = Color_Main_LightGray
        }
        cell.cell4L.text = "\(obj.show_point)"
        
        cell.selectionStyle = .none
        return cell
    }
    
    //MARK: - Utility
    public func callPointHistory() {
        historyView.isHidden = false
        historyView.alpha = 1
        AppDelegate.shared().pointRootShowHistory = false
        
        //重算一次點數
        var all = Int(AppDelegate.shared().memberData["remit_point"]!)
        for i in 0..<AppDelegate.shared().historyListObj.count {
            AppDelegate.shared().historyListObj[i].show_point = all!
            all = all! - Int(AppDelegate.shared().historyListObj[i].remit_point)!
        }
        
        hostoryTableView.delegate = self
        hostoryTableView.dataSource = self
        hostoryTableView.separatorStyle = .none
        //hostoryTableView.setContentOffset(CGPoint.init(x: 0, y: 0.5), animated: true)
        hostoryTableView.reloadData()
        
        tableBackV.layer.cornerRadius = 4
        tableBackV.clipsToBounds = true
    }
    
    func initData() {
        nameL.text = AppDelegate.shared().memberData["member_name"]
        pointBtn.setTitle(" " + AppDelegate.shared().memberData["remit_point"]!, for: .normal)
        midL.text = "MID : " + AppDelegate.shared().memberData["member_id"]!
        
        let image = generateQRCode(from: AppDelegate.shared().memberData["member_id"]!)
        qrCodeImgV.image = image
    }
    
    public func callMemberData() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_CheckLogin;
        
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
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.initData()
                    if AppDelegate.shared().pointRootShowHistory {
                        self.callPointHistory()
                    }
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: Lang_APIDecodeFail)
                }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    //MARK: - Button Action
    @IBAction func closeHistoryAction(_ sender: Any) {
        historyView.isHidden = true
        historyView.alpha = 0
    }
    
    @IBAction func addPointAction(_ sender: Any) {
        getShareContent()
    }
    
    @IBAction func transferPointAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransferPointVC") as? TransferPointVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        historyView.isHidden = true
        historyView.alpha = 0
        
        iconView.layer.cornerRadius = iconView.frame.size.height/2
        
        addPointL.layer.cornerRadius = 5
        addPointL.layer.borderColor = UIColor.white.cgColor
        addPointL.layer.borderWidth = 0.5
        
        transferPointL.layer.cornerRadius = 5
        transferPointL.layer.borderColor = UIColor.white.cgColor
        transferPointL.layer.borderWidth = 0.5
        
        iconImgV.image = AppDelegate.shared().getIconImage()
        iconImgV.contentMode = .scaleAspectFill
        iconImgV.layer.cornerRadius = iconImgV.frame.size.height/2
        iconImgV.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if loadMemberOnce {
            callMemberData()
            return
        }
        
        loadMemberOnce = true
        initData()
        callMemberData()
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
        
        AppDelegate.shared().nowBottomMenuType = .sharing
        AppDelegate.shared().bottomMenu.paintMenu()
        
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
