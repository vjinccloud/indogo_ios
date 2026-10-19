//
//  FraudMessageHelper.swift
//  indogo
//
//  防詐提醒（compliance-202610 需求 2）
//  所有進入「新增收款人」的入口都先呼叫 checkThenProceed：
//  1. 打 fraud_message，期間顯示 loading，並擋住重複觸發
//  2. 成功且有文字：跳提醒視窗（點外面關不掉），按確認後才執行 next
//  3. 成功但文字是空的：不跳窗，直接執行 next
//  4. 失敗（非 0、網路錯誤、404）：跳錯誤，不執行 next
//

import UIKit
import Alamofire

class FraudMessageHelper: CustomAlertDelegate {
    
    static let shared = FraudMessageHelper()
    
    //API 進行中或提醒視窗顯示中，避免連點疊出多個視窗
    private var isBusy = false
    private var pendingNext:(() -> Void)?
    
    private init() {}
    
    func checkThenProceed(From vc:UIViewController, Next next:@escaping () -> Void) {
        if isBusy {
            return
        }
        isBusy = true
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_FraudMessage;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { [weak vc] response in
                AppDelegate.shared().removeLoadingView()
                
                guard let vc = vc else {
                    self.isBusy = false
                    return
                }
                
                guard response.result.error == nil, let data = response.data, let responseStr = String.init(data: data, encoding: String.Encoding.utf8) else {
                    print("error calling on \(todoEndpoint)")
                    self.isBusy = false
                    AppDelegate.shared().showAlertWithWindow(vc, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                
                Dlog("responseStr = \(responseStr)")
                
                //成功但沒有文字（"remit_reply 0"），既有解析器處理不了這個長度，這裡先接住
                if responseStr.trimmingCharacters(in: .whitespacesAndNewlines) == "remit_reply 0" {
                    self.isBusy = false
                    next()
                    return
                }
                
                AppDelegate.shared().fraudMessageStr = ""
                AppDelegate.shared().apiBackContentStr = ""
                let result = APIHandle().getResponseState(ResponseStr: responseStr, APIStr: todoEndpoint, SubStr: "")
                
                if result == ResponseState.ok {
                    let msg = AppDelegate.shared().fraudMessageStr
                    if msg == "" {
                        self.isBusy = false
                        next()
                    } else {
                        self.showAlert(On: vc, Message: msg, Next: next)
                    }
                } else {
                    self.isBusy = false
                    //token 失效（9001 等）已由 getResponseState 登出並回首頁，不另外跳窗
                    if !AppDelegate.shared().hasLogin {
                        return
                    }
                    //非 remit_reply 格式（例如 404 頁面）沒有錯誤訊息，改顯示連線錯誤
                    var errMsg = AppDelegate.shared().apiBackContentStr
                    if errMsg == "" {
                        errMsg = NSLocalizedString("API Timeout", comment: "")
                    }
                    AppDelegate.shared().showAlertWithWindow(vc, Message: errMsg)
                }
            }
    }
    
    private func showAlert(On vc:UIViewController, Message msg:String, Next next:@escaping () -> Void) {
        pendingNext = next
        let container:UIView = UIApplication.shared.keyWindow ?? vc.view
        let customAlert = CustomAlertView.init(frame: container.bounds)
        customAlert.initNoticeAlert(Title: NSLocalizedString("Fraud Alert Title", comment: ""), Content: msg, NextBtn1Str: NSLocalizedString("Fraud Alert Confirm", comment: ""))
        customAlert.customDelegate = self
        container.addSubview(customAlert)
    }
    
    //MARK: - CustomAlertDelegate
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        isBusy = false
        let next = pendingNext
        pendingNext = nil
        next?()
    }
    
    func customAlertnextActionSecond(Ref obj: CustomAlertView) {
    }
}
