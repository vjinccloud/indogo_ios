//
//  APIHandle.swift
//  indogo
//
//  Created by mac on 2020/7/11.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public enum ResponseState {
    case failed
    case ok
    case error
    case member_not_exist
    case lack_point
}

class APIHandle {

    static let sharedInstance = APIHandle()
    
    init() {}
    
    //MARK: - Basic
    //取得回傳的狀態
    func getResponseState(ResponseStr resStr:String, APIStr apiStr:String, SubStr subStr:String) -> ResponseState {
        if !resStr.hasPrefix("remit_reply") || resStr.count < 13 {
            return ResponseState.failed
        }
        
        AppDelegate.shared().apiBackContentStr = ""
        
        var resultStr = ""
        var stateStr = ""
        
        //改成自動判斷
        let endIdx = findSecondSpaceIndex(AllStr: resStr)
        if endIdx != -1 {
            var startIndex = resStr.index(resStr.startIndex, offsetBy: 12)
            var endIndex = resStr.index(resStr.startIndex, offsetBy: endIdx-1)
            stateStr = String(resStr[startIndex..<endIndex])
            
            startIndex = resStr.index(resStr.startIndex, offsetBy: endIdx)
            endIndex = resStr.endIndex
            resultStr = String(resStr[startIndex..<endIndex]).trimmingCharacters(in: .whitespaces)
        } else {
            var startIndex = resStr.index(resStr.startIndex, offsetBy: 12)
            var endIndex = resStr.index(resStr.startIndex, offsetBy: 13)
            stateStr = String(resStr[startIndex..<endIndex])
            
            startIndex = resStr.index(resStr.startIndex, offsetBy: 14)
            endIndex = resStr.endIndex
            resultStr = String(resStr[startIndex..<endIndex]).trimmingCharacters(in: .whitespaces)
        }
        
        Dlog("resultStr = \(resultStr), stateStr = -\(stateStr)-")
        
        if stateStr != "0" {
            AppDelegate.shared().apiBackContentStr = resultStr
            
            if stateStr == "15" || stateStr == "9001" || stateStr == "503" || stateStr == "702" || stateStr == "15001" || stateStr == "16001" {
                if AppDelegate.shared().hasLogin {
                    AppDelegate.shared().userLogout()
                    AppDelegate.shared().changeRootOfFunc(Type: .main)
                }
            }
            
            //特殊狀況
            if apiStr == API_CheckMemExist && stateStr == "3" {
                return ResponseState.member_not_exist
            } else if apiStr == API_BankList {
                return ResponseState.failed
            } else {
                //取得最後訊息並顯示
                if apiStr == API_TransferPointFirstStep {
                    if resultStr.contains("no member") || resultStr.contains("not have this member") {
                        return ResponseState.ok
                    } else {
                        return ResponseState.error
                    }
                    
                } else {
                    //AppDelegate.shared().showAlertWithWindow(vc, Message: resultStr)
                    return ResponseState.failed
                }
                
            }
        }
        
        //根據 API 字串處理後續
        switch apiStr {
        case API_Promo:
            promo(DataStr: resultStr)
            break
        case API_Login:
            login(DataStr: resultStr)
            break
        case API_CheckLogin:
            login(DataStr: resultStr)
            break
        case API_CheckMemExist:
            checkMemExist(DataStr: resultStr)
            break
        case API_SendSMS:
            sendSMS(DataStr: resultStr)
            break
        case API_NoticeRecordList:
            checkNoticeList(DataStr: resultStr)
            break
        case API_PointHistoryList:
            checkPointHistoryList(DataStr: resultStr)
            break
        case API_GetDoc:
            checkDocContent(DataStr: resultStr, SubStr: subStr)
            break
        case API_TransferPointFirstStep:
            checkPointTransferFirstStep(DataStr: resultStr, SubStr: subStr)
            break
        case API_MemberRecipents:
            checkRecipientList(DataStr: resultStr)
            break
        case API_BankList:
            checkBankList(DataStr: resultStr)
            break
        case API_TransferHistory:
            checkTransferStateList(DataStr: resultStr)
            break
        case API_OrderCheckMuilti:
            checkTransferOrderCheckList(DataStr: resultStr)
            break
        case API_TransactionCreate:
            checkTransactionResult(DataStr: resultStr)
            break
        case API_AddRecipient:
            checkAddRecipientResult(DataStr: resultStr)
            break
        case API_BarCode_711, API_BarCode_fami, API_BarCode_ok, API_BarCode_hilife:
            checkBarCode(DataStr: resultStr)
            break
        default:
            break
        }
        
        return ResponseState.ok
    }
    
    //找到第二個空白
    func findSecondSpaceIndex(AllStr str:String) -> Int {
        var ans = -1
        var spaceCount = 0
        for i in 1..<str.count {
            let startIndex = str.index(str.startIndex, offsetBy: i-1)
            let endIndex = str.index(str.startIndex, offsetBy: i)
            let stateStr = String(str[startIndex..<endIndex])
            //Dlog("stateStr = \(stateStr)")
            if stateStr == " " {
                spaceCount += 1
                if spaceCount == 2 {
                    ans = i
                    break
                }
            }
        }
        
        return ans
    }
    
    private func checkAddRecipientResult(DataStr dataStr:String) {
        AppDelegate.shared().tempRecipientObj = RecipientObj()
        
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for j in 0..<ary.count {
            if j==0 {
                AppDelegate.shared().tempRecipientObj.recipient_id = ary[0]
            } else if j==1 {
                AppDelegate.shared().tempRecipientObj.recipient_name = ary[1]
            }
        }
        
    }
    
    private func checkTransactionResult(DataStr dataStr:String) {
        let obj:TransactionResultObj = TransactionResultObj()
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for j in 0..<ary.count {
            obj.setValueByOrder(Order: j, Value: ary[j])
        }
        
        if obj.payment_info != "" {
            obj.printSelf()
            AppDelegate.shared().tempTransactionResultObj = obj
        } else {
            AppDelegate.shared().tempTransactionResultObj = TransactionResultObj()
        }
    }
    
    private func checkBarCode(DataStr dataStr:String) {
        let obj:BarCodeInfoObj = BarCodeInfoObj()
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for j in 0..<ary.count {
            obj.setValueByOrder(Order: j, Value: ary[j])
        }
        
        if obj.lm_time_expire != "" {
            obj.printSelf()
            AppDelegate.shared().tempBarCodeInfoObj = obj
        } else {
            AppDelegate.shared().tempBarCodeInfoObj = BarCodeInfoObj()
        }
    }
    
    private func checkDocContent(DataStr dataStr:String, SubStr subStr:String) {
        if subStr == "會員服務條款" || subStr == "外籍勞工薪資結匯申報委託書" {
            let content = "<html><header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header><body>\(dataStr)</body></html>"
            AppDelegate.shared().tempAgreementHtmlContent = content
        } else if subStr == "使用者條款" {
            let content = "<html><header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header><body>\(dataStr)</body></html>"
            AppDelegate.shared().tempAgreementHtmlContent = content
        } else if subStr == "分享文案" {
            AppDelegate.shared().shareContent = dataStr
        } else if subStr == "點數轉移規則" {
            let content = "<html><header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header><body>\(dataStr)</body></html>"
            AppDelegate.shared().tempTransferAgreementHtmlContent = content
        }
        
    }
    
    private func checkBankList(DataStr dataStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            if ary[i].count < 2 { //沒東西
                continue
            }
            
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:BankObj = BankObj()
            for j in 0..<subAry.count {
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            obj.printSelf()
            AppDelegate.shared().bankList.append(obj)
        }
    }
    
    private func checkTransferStateList(DataStr dataStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:TransferStateObj = TransferStateObj()
            for j in 0..<subAry.count {
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            
            if obj.payment_info != "" {
                Dlog("== \(i) =========")
                obj.printSelf()
                AppDelegate.shared().transferStateListObjs.append(obj)
            }
        }
    }
    
    private func checkTransferOrderCheckList(DataStr dataStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:TransferOrderCheckObj = TransferOrderCheckObj()
            for j in 0..<subAry.count {
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            
            if obj.payment_info != "" {
                Dlog("== \(i) =========")
                obj.printSelf()
                AppDelegate.shared().transferOrderCheckListObjs.append(obj)
            }
        }
    }
    
    private func checkRecipientList(DataStr dataStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            if ary[i].count < 2 { //沒東西
                continue
            }
            
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:RecipientObj = RecipientObj()
            for j in 0..<subAry.count {
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            obj.printSelf()
            AppDelegate.shared().recipientListObjs.append(obj)
            
            if obj.is_hidden != "1" {
                AppDelegate.shared().recipientShownListObjs.append(obj)
            }
        }
    }
    
    private func sendSMS(DataStr dataStr:String) {
        AppDelegate.shared().forgotPassTempSMS = dataStr
    }
    
    private func checkMemExist(DataStr dataStr:String) {
        AppDelegate.shared().forgotPassTempPhone = dataStr
    }
    
    private func checkPointHistoryList(DataStr dataStr:String) {
        AppDelegate.shared().historyListObj = []
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            if i<2 { //第一個與第二個是其他東西
                continue
            }
            
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:PointHistorySingleObj = PointHistorySingleObj()
            for j in 0..<subAry.count {
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            obj.printSelf()
            AppDelegate.shared().historyListObj.append(obj)
        }
    }
    
    private func checkPointTransferFirstStep(DataStr dataStr:String, SubStr subStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            Dlog("===\(ary[i])")
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:TransferMemberObj = TransferMemberObj()
            for j in 0..<subAry.count {
                if subStr == "1" { //系統會員
                    if j==0 {
                        obj.idStr = subAry[j]
                    } else if j==1 {
                        obj.name = subAry[j]
                    }
                } else if subStr == "2" { //Sho[會員
                    if j==0 {
                        obj.name = subAry[j]
                    } else if j==1 {
                        obj.phone = subAry[j]
                    }
                }
                Dlog("---\(subAry[j])")
            }
            
            if subStr == "1" { //系統會員
                obj.memberStyle = .normal
            } else if subStr == "2" { //Sho[會員
                obj.memberStyle = .shop
            }
            AppDelegate.shared().transferFriendListObj.append(obj)
            //obj.printSelf()
            //AppDelegate.shared().historyListObj.append(obj)
        }
    }
    
    private func checkNoticeList(DataStr dataStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            //Dlog("(\(i))=====")
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            if subAry.count < 7 {
                continue
            }
            let obj:NoticeObj = NoticeObj()
            for j in 0..<subAry.count {
                //Dlog("---\(subAry[j])")
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            AppDelegate.shared().noteListObjs.append(obj)
        }
    }
    
    //let API_Login = ServerURL + "/app/remit/login"    //token(31)member_name(31)kurs_value(31)kurs_lm_time(31)service_charge(31)remit_point(31)free_service_charge(31)share_id(31)app_phone_no(31)app_share_bonus(31)google_map_url(31)app_version(31)app_market(31)line_url(31)games_url
    private func login(DataStr dataStr:String) {
        /*
        //目前直接用zero width空格
        let startIndex = dataStr.index(dataStr.startIndex, offsetBy: 32)
        let endIndex = dataStr.index(dataStr.startIndex, offsetBy: 33)
        let separateStr = String(dataStr[startIndex..<endIndex])
        //AppDelegate.shared().seperatorStr = separateStr
        */
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        
        AppDelegate.shared().userLogin(TokenStr: ary[0])
        let keyAry:[String] = ["member_name","kurs_value","kurs_lm_time","service_charge","remit_point","free_service_charge","share_id","app_phone_no","app_share_bonus","google_map_url","app_version","app_market","line_url","games_url","member_id","arc_photo","arc_back_photo","signature_photo","id_card_photo","self_photo"]
        for i in 0..<keyAry.count {
            var value = ""
            if (i+1) < ary.count {
                value = ary[i+1]
                AppDelegate.shared().memberData[keyAry[i]] = value
            } else {
                Dlog("over loop")
            }
            Dlog("key(\(keyAry[i])) = \(value)")
        }
    }
    
    //let API_Promo = ServerURL + "/app/remit/app_photos"
    //remit_reply 0 圖片的url(31)圖片的url(31)圖片的url(31)
    private func promo(DataStr dataStr:String) {
        AppDelegate.shared().promoUrlAry = []
        
        var idx = 0
        let spaceCount = 62
        while (idx+spaceCount) <= dataStr.count {
            let startIndex = dataStr.index(dataStr.startIndex, offsetBy: idx)
            let endIndex = dataStr.index(dataStr.startIndex, offsetBy: idx+spaceCount)
            
            var str = String(dataStr[startIndex..<endIndex])
            str = str.trimmingCharacters(in: .whitespaces)
            AppDelegate.shared().promoUrlAry.append(str)
            idx += spaceCount
        }
        Dlog("promoUrlAry = \(AppDelegate.shared().promoUrlAry.count)")
    }
    
}
