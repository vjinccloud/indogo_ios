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
            return ResponseState.error
        }
        
        startIndex = resStr.index(resStr.startIndex, offsetBy: 14)
        endIndex = resStr.endIndex
        let resultStr = String(resStr[startIndex..<endIndex])
        Dlog("resultStr = \(resultStr)")
        //根據 API 字串處理後續
        switch apiStr {
        case API_Promo:
            promo(DataStr: resultStr)
            break
        default:
            break
        }
        
        return ResponseState.ok
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
