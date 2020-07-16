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
}

class APIHandle {

    static let sharedInstance = APIHandle()
    
    init() {}
    
    //MARK: - Basic
    //取得回傳的狀態
    func getResponseState(ResponseStr resStr:String, APIStr apiStr:String) -> ResponseState {
        if !resStr.hasPrefix("remit_reply") || resStr.count < 13 {
            return ResponseState.failed
        }
        
        var startIndex = resStr.index(resStr.startIndex, offsetBy: 12)
        var endIndex = resStr.index(resStr.startIndex, offsetBy: 13)
        let stateStr = String(resStr[startIndex..<endIndex])
        if stateStr != "0" {
            //特殊狀況
            if apiStr == API_CheckMemExist && stateStr == "3" {
                return ResponseState.member_not_exist
            } else {
                return ResponseState.error
            }
        }
        
        startIndex = resStr.index(resStr.startIndex, offsetBy: 14)
        endIndex = resStr.endIndex
        let resultStr = String(resStr[startIndex..<endIndex]).trimmingCharacters(in: .whitespaces)
        Dlog("resultStr = \(resultStr)")
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
        default:
            break
        }
        
        return ResponseState.ok
    }
    
    //remit_reply 0 phone_no
    private func checkMemExist(DataStr dataStr:String) {
        AppDelegate.shared().forgotPassTempPhone = dataStr
    }
    
    //let API_Login = ServerURL + "/app/remit/login"    //token(31)member_name(31)kurs_value(31)kurs_lm_time(31)service_charge(31)remit_point(31)free_service_charge(31)share_id(31)app_phone_no(31)app_share_bonus(31)google_map_url(31)app_version(31)app_market(31)line_url(31)games_url
    private func login(DataStr dataStr:String) {
        //目前直接用zero width空格
        let startIndex = dataStr.index(dataStr.startIndex, offsetBy: 32)
        let endIndex = dataStr.index(dataStr.startIndex, offsetBy: 33)
        let separateStr = String(dataStr[startIndex..<endIndex])
       
        let ary = dataStr.components(separatedBy: separateStr)
        
        AppDelegate.shared().userLogin(TokenStr: ary[0])
        AppDelegate.shared().memberData = [:]
        let keyAry:[String] = ["member_name","kurs_value","kurs_lm_time","service_charge","remit_point","free_service_charge","share_id","app_phone_no","app_share_bonus","google_map_url","app_version","app_market","line_url","games_url"]
        for i in 0..<keyAry.count {
            var value = ""
            if (i+1) < ary.count {
                value = ary[i+1]
            } else {
                Dlog("over loop")
            }
            
            AppDelegate.shared().memberData[keyAry[i]] = value
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
