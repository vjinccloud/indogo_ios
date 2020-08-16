//
//  AppDefine.swift
//  GISWork
//
//  Created by askAir on 2018/10/7.
//  Copyright © 2018年 TrendGo. All rights reserved.
//

import Foundation
import UIKit

//尺寸
var AppWidth:CGFloat = 320.0
var AppTotalHeight:CGFloat = 960.0
var AppTopBarHeight:CGFloat = 50.0
var AppEmptyHeight:CGFloat = 800.0
var FirebaseToken = ""

var ImageLimitInBytes:Int = 80000

//顏色
public let Color_Main_Bule = UtilityTool().hexStringToUIColor(hex: "#2a65ec")
public let Color_Main_Red = UtilityTool().hexStringToUIColor(hex: "#b20808")
public let Color_Main_LightGray = UtilityTool().hexStringToUIColor(hex: "#d6d7d8")
public let Color_Main_DarkGray = UtilityTool().hexStringToUIColor(hex: "#3b3f47")

//開發階段
let DevMode = true
let Lang_APIDecodeFail = NSLocalizedString("API DecodeFail", comment: "伺服器忙線中，請稍候再試")

let AppVersion = "1.0"
let AppId = 1
//正式
//let ServerURL = "https://prod.indogo.link"
//測試機
let ServerURL = "https://prod.indogo.link"

//訂票時限
let orderTicketTimeLimitSecs:Double = 300

//API後續網址設定
let API_Promo = ServerURL + "/app/remit/app_photos"
let API_Login = ServerURL + "/app/remit/login"
let API_CheckLogin = ServerURL + "/app/remit/check_token"
let API_CheckMemExist = ServerURL + "/app/remit/check_mem_exists"
let API_SendSMS = ServerURL + "/app/remit/password_forget_sms"
let API_Register = ServerURL + "/app/remit/register"
let API_ResendRegisterSMS = ServerURL + "/app/remit/request_sms_code"
let API_VerifyRegisterSMS = ServerURL + "/app/remit/verify_sms_code"
let API_NoticeRecordList = ServerURL + "/app/remit/notification_record"

let API_ForgetPass = ServerURL + "/Account/forgotPassword"
let API_ConfirmCodePass = ServerURL + "/Account/verifyConfirmCode"
let API_CoutryCode = ServerURL + "/App/supportPhoneCountry"
let API_ResetPass = ServerURL + "/Account/resetPassword"
let API_PayQR = ServerURL + "/App/payqr"
let API_ScanQR = ServerURL + "/App/scanqr"
let API_Send = ServerURL + "/App/send"
let API_Balance = ServerURL + "/App/Balance"
let API_BalanceDetail = ServerURL + "/App/Detail"
let API_Colllect = ServerURL + "/App/collect"
let API_Price = ServerURL + "/App/Price"
let API_ExchangeCoin = ServerURL + "/App/ExchangeCoin"
let API_Sell = ServerURL + "/App/Sell"
let API_SetCollect = ServerURL + "/App/setCollect"
let API_Me = ServerURL + "/App/me"
let API_MeDetail = ServerURL + "/App/mydetail"
let API_UploadMyImage = ServerURL + "/App/UploadMyImage"
//let API_UploadMyImage = ServerURL + "/Account/uploadmyimage"
let API_ChangeName = ServerURL + "/App/changealias"
let API_MyQR = ServerURL + "/App/myQR"
let API_MyBankList = ServerURL + "/App/mybanklist"
let API_GetBankList = ServerURL + "/App/BankList"
let API_DelBank = ServerURL + "/App/removemybank"
let API_AddBank = ServerURL + "/App/addmybank"
let API_SendConfirmCode = ServerURL + "/Account/sendConfirmCode"
let API_ChangePass = ServerURL + "/Account/changePassword"
let API_SetTransactionPassword = ServerURL + "/Account/setTransactionPassword"
let API_CheckTransactionPassword = ServerURL + "/Account/checkTransactionPassword"

let API_OrderPayment = ServerURL + "/OrderPayment/Post"
let API_SingleBookingSearch = ServerURL + "/SingleBookingSearch/Post"
let API_BookingSearch = ServerURL + "/BookingSearch/Post"
let API_BookingCancel = ServerURL + "/BookingCancel/Post"
let API_CityDistrict = ServerURL + "/CityDistrict/Post"
let API_MemberData = ServerURL + "/MemberData/Post"
let API_MemberEdit = ServerURL + "/MemberEdit/Post"
let API_ForgetPassword = ServerURL + "/ForgetPassword/Post"
let API_Report = ServerURL + "/ProblemReport/Post"
let API_TicketEntry = ServerURL + "/TicketEntry/Post"
let API_OrderCancel = ServerURL + "/OrderCancel/Post"

enum ScanParentType {
    case forgotPass
    case register
}

enum PhotoIDType {
    case normal
    case front
    case back
    case faceAndId
    case passport
    case sign
}

enum LoginFuncType {
    case main
    case member
    case notice
}

enum BottomMenuType {
    case transaction
    case transState
    case sharing
    case notice
    case profile
}
