# CLAUDE.md — IndoGO iOS（工程師 Session）

你是 **IndoGO 的工程師**。這個 repo 是三款白牌匯款 App 的母本（另兩款在 `../govn_ios`、`../gopadala_ios`，**不要改它們**）。
流程、分支、交付格式在 `../docs/工作流程.md`，需求規格在 `../docs/spec/`。先讀這兩個再動手。

## 目前任務

需求代號 `compliance-202610`，規格：`../docs/spec/三國合規更新.md`。IndoGO 要做需求 1（ARC 發證日期）與需求 2（防詐提醒）。需求 3 IndoGO 已有，只做規格第 3 節的「既有實作檢查」。

分支 `feature/compliance-202610` 已開好，直接在上面 commit。不 push、不合 main。**commit 訊息用中文，不可出現 Claude、AI、Co-Authored-By 等署名。**

## 專案結構

- 開 `indogo.xcworkspace`，scheme `indogo`。CocoaPods 的 `Pods/` 已進版控，**不要跑 `pod install`**。
- 程式碼在 `indogo/`。`Base/` 是共用層：`AppDefine.swift`（所有 API 端點常數與 ServerURL）、`APIHandle.swift`（回傳解析，一個大 switch，每個端點一個 case）、`CustomAlertView.swift`（彈窗）、`UtilityTool.swift`。
- 畫面在 `View/<功能>/`，storyboard 是 `Main`、`Member`、`Register` 等，部分畫面用 xib。
- 語系：`en.lproj`、`id.lproj` 的 `Localizable.strings`。新字串兩邊都要加，key 是英文短句。
- 全域狀態都掛在 `AppDelegate.shared()`（sessionToken、memberData、gpsCode、ipAddr、transactionObj……）。

## 後端協定（改 API 時必守）

- `POST {ServerURL}/app/remit/<action>`，`URLEncoding.default`。每支都帶 `token`、`gps_code`、`mobile_type: "iphone"`、`ip_addr`、`req_timestamp`（`Date.giveCurrentDateString()`），照既有呼叫抄。
- 回傳是純文字 `remit_reply <code> <payload>`，不是 JSON。`code` 0 成功。
- 多筆資料：列用 `AppDelegate.shared().seperatorStr`（U+001F）分，列內欄位用 `subSeperatorStr`（U+001E）分。這兩個值從 `Localizable.strings` 的 `"leading space"` / `"leading sub space"` 讀進來，不要寫死。
- 新端點一律：`AppDefine.swift` 加常數 → `APIHandle.swift` 加 case → 畫面呼叫。照 `API_GetPurpose` 的寫法。

## 環境

`Base/AppDefine.swift` 已改成 Debug 打 `TestServerURL`、Release 打 `ProdServerURL`。開發用 Debug。**`ProdServerURL` 不准改**；`TestServerURL` 由 CTO 填，不對就回報，不要自己改。

## 交付

做完寫 `../_handoff/indogo-compliance-202610.md`（格式見工作流程），附模擬器截圖，然後告訴使用者可以叫 QA 驗。QA 回 FAIL 時修完再交付一次。
規格看不懂或後端行為不明，**問使用者轉 CTO**，不要猜。
