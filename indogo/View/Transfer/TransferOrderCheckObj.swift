//
//  TransferOrderCheckObj.swift
//  indogo
//
//  Created by mac on 2020/8/31.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class TransferOrderCheckObj: NSObject {
    var payment_info:String! = ""
    var order_status:String! = ""
    var lm_time_process:String! = ""
    var server_time:String! = ""
    var lm_time_pending:String! = ""
    var lm_time_transfer:String! = ""
    var lm_time_paid:String! = ""
    var mini_mart_id:String! = ""
    var lm_time_failed:String! = ""
    var lm_time_expire:String! = ""
    /// 後端 10/21 起多的欄位（orders_check 多筆在 index 10）：remittance／tagihan；舊回傳沒有這欄時為空字串
    var business_type:String! = ""

    /// 繳費單（tagihan）列，共用匯款清單要跳過
    /// 比對前先去頭尾空白／換行再轉小寫，避免回傳結尾帶換行或大小寫不同漏擋
    var isTagihan:Bool {
        return (business_type ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "tagihan"
    }

    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        
        if orderNum == 0 {
            payment_info = valueStr
        } else if orderNum == 1 {
            order_status = valueStr
        } else if orderNum == 2 {
            lm_time_pending = valueStr
        } else if orderNum == 3 {
            lm_time_paid = valueStr
        } else if orderNum == 4 {
            lm_time_process = valueStr
        } else if orderNum == 5 {
            lm_time_transfer = valueStr
        } else if orderNum == 6 {
            server_time = valueStr
        } else if orderNum == 7 {
            lm_time_expire = valueStr
        } else if orderNum == 8 {
            mini_mart_id = valueStr
        } else if orderNum == 9 {
            lm_time_failed = valueStr
        } else if orderNum == 10 {
            business_type = valueStr
        }
        // 其他索引：後端日後再加欄位時忽略，不出錯
    }

    public func printSelf() {
        Dlog("payment_info(\(payment_info ?? "")), order_status(\(order_status ?? "")), lm_time_pending(\(lm_time_pending ?? "")), lm_time_paid(\(lm_time_paid ?? "")), lm_time_process(\(lm_time_process ?? "")), lm_time_transfer(\(lm_time_transfer ?? "")), server_time(\(server_time ?? "")), lm_time_expire(\(lm_time_expire ?? "")), mini_mart_id(\(mini_mart_id ?? "")), lm_time_failed(\(lm_time_failed ?? "")), business_type(\(business_type ?? ""))")
    }
}
