//
//  AppIconManager.swift
//  indogo
//
//  後台控制 App icon。
//  後台 API：POST https://prod.indogo.com.tw/app/getLauncherIcon.php （免參數）
//  回傳格式：remit_reply 0 <icon 名稱>     例如：remit_reply 0 Chinese New Year
//
//  注意：iOS 只能在「編譯時打包進 App 的替代圖示」之間切換，
//  圖檔已放在 Assets.xcassets 內的各個 *.appiconset，
//  並在 Info.plist 的 CFBundleAlternateIcons 註冊。
//

import UIKit
import Alamofire

class AppIconManager {

    static let shared = AppIconManager()
    private init() {}

    /// 後台回傳名稱(可含空白) -> Assets/Info.plist 註冊的 alternate icon 名稱
    /// nil = 切回主圖示(Normal)
    private let iconMap: [String: String?] = [
        "Normal":            nil,
        "1010":              "AltIcon1010",
        "Batik":             "Batik",
        "Chinese New Year":  "ChineseNewYear",
        "Dragon Boat":       "DragonBoat",
        "Halloween":         "Halloween",
        "Halloween2":        "Halloween2",
        "Idul Adha":         "IdulAdha",
        "Kartini":           "Kartini",
        "Kemerdekaan":       "Kemerdekaan",
        "Mooncake":          "Mooncake",
        "Natal":             "Natal",
        "Natal1":            "Natal1",
        "New Year":          "NewYear",
        "Olimpiade":         "Olimpiade",
        "Ramadan":           "Ramadan",
        "Valentine":         "Valentine"
    ]

    // MARK: - 對外入口

    /// 向後台查詢目前該使用哪個 App icon，並自動切換
    func fetchAndApplyIcon() {
        let todoEndpoint: String = API_LauncherIcon
        let parameters: Parameters = [:]      // 不需任何參數
        let headers: HTTPHeaders = [:]

        Dlog("fetchLauncherIcon todoEndpoint=\(todoEndpoint)")

        AppDelegate.shared().alamofireManagerWithTimeout
            .requestWithoutCache(todoEndpoint, method: .post,
                                 parameters: parameters,
                                 encoding: URLEncoding.default, headers: headers)
            .responseString(encoding: String.Encoding.utf8) { [weak self] response in

                guard response.result.error == nil, let data = response.data else {
                    Dlog("fetchLauncherIcon error on \(todoEndpoint)")
                    return
                }

                let responseStr = (String(data: data, encoding: .utf8) ?? "")
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.controlCharacters))
                Dlog("fetchLauncherIcon responseStr = \(responseStr)")
                // 例：remit_reply 0 Chinese New Year

                // 解析格式：remit_reply <state> <icon 名稱(可含空白)>
                let parts = responseStr.components(separatedBy: " ")
                guard parts.count >= 3, parts[0] == "remit_reply", parts[1] == "0" else {
                    Dlog("fetchLauncherIcon 格式不符或狀態非 0")
                    return
                }
                // 第 2 個空白之後全部是名稱（保留中間空白）
                let iconName = parts[2...].joined(separator: " ")

                self?.changeIcon(to: iconName)
            }
    }

    /// 依名稱直接切換 App icon（可單獨呼叫）
    func changeIcon(to backendName: String) {
        // 後台回傳結尾可能夾帶控制字元(如 0x1F)，需一併清除，否則對不到表
        let trimSet = CharacterSet.whitespacesAndNewlines.union(.controlCharacters)
        let key = backendName.trimmingCharacters(in: trimSet)

        guard UIApplication.shared.supportsAlternateIcons else {
            Dlog("此裝置不支援替代圖示")
            return
        }
        guard let iconName = iconMap[key] else {
            Dlog("找不到對應的 icon = \(key)")
            return
        }
        // 已是目前 icon 就不重設（避免重複彈出系統提示）
        if UIApplication.shared.alternateIconName == iconName {
            Dlog("App icon 已經是 \(key)，略過")
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.setAlternateIconName(iconName) { error in
                if let error = error {
                    Dlog("切換 App icon 失敗：\(error.localizedDescription)")
                } else {
                    Dlog("App icon 已切換為 \(key)")
                }
            }
        }
    }
}
