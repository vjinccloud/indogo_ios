#!/bin/bash
# TAGIHAN 第 0 期「共用匯款紀錄防呆」驗證腳本
#
# 用 swiftc 把下列「真的原始碼」編成命令列程式跑：
#   - indogo/View/Transfer/TransferStateObj.swift（整檔）
#   - indogo/View/Transfer/TransferOrderCheckObj.swift（整檔）
#   - indogo/Base/APIHandle.swift 的 checkTransferStateList / checkTransferOrderCheckList（用 awk 原文抽出，
#     只把 AppDelegate.shared() 換成本地 store）
#   - indogo/View/Transfer/TransferListVC.swift 的 orderCheckData(For:) / barColor(ForStatus:)（原文抽出，只有新版才有）
# 再餵混入繳費單的 remit_reply 資料，確認：
#   1. 匯款清單只剩 business_type != tagihan 的列，不閃退
#   2. orders_check 清單同上；order_status 空字串／非數字時 barColor 回預設色，不閃退
#   3. 正常資料（無 business_type、或 business_type=remittance）解析結果與改前 19／10 個欄位完全相同
#
# 用法：
#   scripts/verify-tagihan-phase0.sh                         # 只驗目前工作目錄
#   scripts/verify-tagihan-phase0.sh --baseline main         # 另抽 git ref 的舊版原始碼跑同一組資料，比對正常資料結果
set -u

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BASELINE_REF=""
if [ "${1:-}" = "--baseline" ]; then
  BASELINE_REF="${2:-main}"
fi

WORK="$(mktemp -d "${TMPDIR:-/tmp}/tagihan-phase0.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

STATE_OBJ="indogo/View/Transfer/TransferStateObj.swift"
ORDER_OBJ="indogo/View/Transfer/TransferOrderCheckObj.swift"
API_HANDLE="indogo/Base/APIHandle.swift"
LIST_VC="indogo/View/Transfer/TransferListVC.swift"

# 從 swift 檔抽出一個 4 空格縮排的 func（從包含 pattern 子字串的那行到下一個 "    }"）
extract_func() { # file pattern(純子字串，不是 regex)
  awk -v pat="$2" '
    index($0, pat) > 0 { on=1 }
    on { print }
    on && $0 ~ /^    }$/ { exit }
  ' "$1"
}

# 產生測試程式。$1 = 原始碼來源目錄，$2 = 輸出 swift 檔，$3 = 標籤（new/old）
gen_program() {
  local SRC="$1" OUT="$2" TAG="$3"
  local HAS_LISTVC_HELPERS=0
  if grep -q "func orderCheckData(For" "$SRC/$LIST_VC" && grep -q "func barColor(ForStatus" "$SRC/$LIST_VC"; then
    HAS_LISTVC_HELPERS=1
  fi

  {
    cat <<'EOF'
import Foundation

// ---- 專案裡的 Dlog / UIColor 用最小替身取代（只為了能在命令列編譯）----
var dlogLines:[String] = []
func Dlog(_ item: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    dlogLines.append("\(item())")
}
class UIColor: Equatable, CustomStringConvertible {
    let name:String
    init(_ name:String) { self.name = name }
    static let lightGray = UIColor("lightGray")
    static func == (a:UIColor, b:UIColor) -> Bool { return a.name == b.name }
    var description:String { return name }
}
EOF
    echo "// ---- $STATE_OBJ（原檔，import UIKit 換成 Foundation）----"
    sed 's/^import UIKit$/import Foundation/' "$SRC/$STATE_OBJ"
    echo "// ---- $ORDER_OBJ（原檔）----"
    sed 's/^import UIKit$/import Foundation/' "$SRC/$ORDER_OBJ"
    cat <<'EOF'

// ---- AppDelegate.shared() 的替身 ----
class Store {
    var seperatorStr:String = "\u{1F}"      // 對應 Localizable.strings "leading space"
    var subSeperatorStr:String = "\u{1E}"   // 對應 Localizable.strings "leading sub space"
    var transferStateListObjs:[TransferStateObj] = []
    var transferOrderCheckListObjs:[TransferOrderCheckObj] = []
}

// ---- APIHandle.swift 原文抽出的兩個解析函式 ----
class Parser {
    let store = Store()
EOF
    extract_func "$SRC/$API_HANDLE" 'private func checkTransferStateList(DataStr' | sed -e 's/AppDelegate\.shared()\./store./g' -e 's/private func/func/'
    extract_func "$SRC/$API_HANDLE" 'private func checkTransferOrderCheckList(DataStr' | sed -e 's/AppDelegate\.shared()\./store./g' -e 's/private func/func/'
    echo "}"

    if [ "$HAS_LISTVC_HELPERS" = "1" ]; then
      cat <<'EOF'

// ---- TransferListVC.swift 原文抽出的兩個 helper ----
class ListVC {
    var showOrderCheckDataList:[TransferOrderCheckObj] = []
    var cellBarColor:[UIColor] = [UIColor("#BD1621"), UIColor("#156784"), UIColor("#FDA11A"), UIColor("#2B712A"), UIColor("#706F6F")]
EOF
      extract_func "$SRC/$LIST_VC" 'func orderCheckData(For paymentInfo'
      extract_func "$SRC/$LIST_VC" 'func barColor(ForStatus statusStr'
      echo "}"
      echo "let hasListVCHelpers = true"
    else
      cat <<'EOF'
class ListVC {
    var showOrderCheckDataList:[TransferOrderCheckObj] = []
    var cellBarColor:[UIColor] = []
    func orderCheckData(For paymentInfo:String?) -> TransferOrderCheckObj { return TransferOrderCheckObj() }
    func barColor(ForStatus statusStr:String?) -> UIColor { return UIColor.lightGray }
}
let hasListVCHelpers = false
EOF
    fi

    cat <<EOF

let tag = "$TAG"
EOF
    cat <<'EOF'
let SEP = "\u{1F}", SUB = "\u{1E}"
func rows(_ r:[[String]]) -> String { return r.map { $0.joined(separator: SUB) }.joined(separator: SEP) }

// ---- 測試資料 ----
// 一列正常匯款（19 欄，10/21 前的舊格式，沒有 business_type）
func remit(_ no:String, status:String, name:String, idr:String, bt:String? = nil) -> [String] {
    var f = [no, status, "Status \(status)", name, "1000", "2026-10-21 10:00:00", idr, "1234567890", "0987654321",
             "2026-10-21 11:00:00", "480.5", "EX\(no)", "479", "1.5", "2026-10-21 10:30:00", "014", "R\(no)", "", ""]
    if let bt = bt { f.append(bt) }
    return f
}
func tagihanRow(_ no:String, bt:String = "tagihan") -> [String] {
    // 規格：recipient_name = Tagihan，transfer_amount_idr（index 6）等欄位空字串，index 19 = tagihan
    return [no, "2", "Status 2", "Tagihan", "", "2026-10-21 10:00:00", "", "", "", "", "", "", "", "", "", "", "", "", "", bt]
}
func orderRow(_ no:String, status:String, bt:String? = nil) -> [String] {
    var f = [no, status, "2026-10-21 10:00:00", "2026-10-21 10:30:00", "", "", "2026-10-21 12:00:00", "2026-10-21 13:00:00", "", ""]
    if let bt = bt { f.append(bt) }
    return f
}

// 舊格式正常資料（19 欄）
let normalOld = rows([remit("ERT001", status: "1", name: "Budi", idr: "1500000"),
                      remit("ERT002", status: "2", name: "Siti", idr: "2000000"),
                      remit("ERT003", status: "5", name: "Agus", idr: "500000")])
// 新格式正常資料（20 欄，全是 remittance）
let normalNew = rows([remit("ERT001", status: "1", name: "Budi", idr: "1500000", bt: "remittance"),
                      remit("ERT002", status: "2", name: "Siti", idr: "2000000", bt: "remittance"),
                      remit("ERT003", status: "5", name: "Agus", idr: "500000", bt: "remittance")])
// 混入繳費單 + 一列多到 25 欄（未知索引）
let mixed = rows([remit("ERT001", status: "1", name: "Budi", idr: "1500000", bt: "remittance"),
                  tagihanRow("ERT900"),
                  remit("ERT002", status: "2", name: "Siti", idr: "2000000", bt: "remittance"),
                  tagihanRow("ERT901"),
                  remit("ERT003", status: "5", name: "Agus", idr: "500000", bt: "remittance") + ["x1", "x2", "x3", "x4", "x5"],
                  tagihanRow("ERT902", bt: "Tagihan\n"),       // 結尾換行 + 大寫（CTO 10/22 要求的案例）
                  tagihanRow("ERT903", bt: " TAGIHAN "),       // 前後空白 + 全大寫
                  remit("ERT004", status: "2", name: "Dewi", idr: "750000", bt: "remittance\n")])  // 匯款列結尾換行，不能被誤擋

let ordersNormalOld = rows([orderRow("ERT001", status: "1"), orderRow("ERT002", status: "2"), orderRow("ERT003", status: "5")])
let ordersNormalNew = rows([orderRow("ERT001", status: "1", bt: "remittance"), orderRow("ERT002", status: "2", bt: "remittance"), orderRow("ERT003", status: "5", bt: "remittance")])
// 混入繳費單（index 10 = tagihan）、一列 order_status 空字串、一列非數字、一列超出 1~5
let ordersMixed = rows([orderRow("ERT001", status: "1", bt: "remittance"),
                        orderRow("ERT900", status: "2", bt: "tagihan"),
                        orderRow("ERT002", status: "", bt: "remittance"),
                        orderRow("ERT003", status: "abc", bt: "remittance"),
                        orderRow("ERT004", status: "9", bt: "remittance"),
                        orderRow("ERT901", status: "6", bt: "tagihan"),
                        orderRow("ERT902", status: "2", bt: "Tagihan\n"),     // 結尾換行 + 大寫
                        orderRow("ERT005", status: "3", bt: "remittance\n")])  // 匯款列結尾換行，要保留

func dumpState(_ o:TransferStateObj) -> String {
    // 只印改前就有的 19 欄，拿來跟舊版比對
    return [o.payment_info, o.transfer_status_id, o.transfer_status_name, o.recipient_name, o.total, o.lm_time_pending,
            o.transfer_amount_idr, o.to_acc, o.from_acc, o.lm_time_transfer, o.kurs_value, o.exchange_id, o.old_kurs_value,
            o.diff_kurs_value, o.lm_time_paid, o.bank_code, o.recipient_id, o.mini_mart_id, o.lm_time_fail].map { $0 ?? "nil" }.joined(separator: "|")
}
func dumpOrder(_ o:TransferOrderCheckObj) -> String {
    return [o.payment_info, o.order_status, o.lm_time_pending, o.lm_time_paid, o.lm_time_process, o.lm_time_transfer,
            o.server_time, o.lm_time_expire, o.mini_mart_id, o.lm_time_failed].map { $0 ?? "nil" }.joined(separator: "|")
}

var failures = 0
func check(_ cond:Bool, _ msg:String) {
    print((cond ? "  PASS  " : "  FAIL  ") + msg)
    if !cond { failures += 1 }
}

func parseState(_ s:String) -> [TransferStateObj] { let p = Parser(); p.checkTransferStateList(DataStr: s); return p.store.transferStateListObjs }
func parseOrders(_ s:String) -> [TransferOrderCheckObj] { let p = Parser(); p.checkTransferOrderCheckList(DataStr: s); return p.store.transferOrderCheckListObjs }

// ---- 比對用輸出（給 shell 做 old/new diff）----
print("### COMPARE-BEGIN \(tag)")
print("state normalOld:");  parseState(normalOld).forEach { print(dumpState($0)) }
print("state normalNew:");  parseState(normalNew).forEach { print(dumpState($0)) }
print("orders normalOld:"); parseOrders(ordersNormalOld).forEach { print(dumpOrder($0)) }
print("orders normalNew:"); parseOrders(ordersNormalNew).forEach { print(dumpOrder($0)) }
print("### COMPARE-END \(tag)")

// ---- 斷言 ----
print("[\(tag)] 匯款清單 money_transfer_today / before_today")
let sNormalOld = parseState(normalOld), sNormalNew = parseState(normalNew), sMixed = parseState(mixed)
check(sNormalOld.count == 3, "舊格式正常資料 3 列全保留（實際 \(sNormalOld.count)）")
check(sNormalNew.count == 3, "新格式正常資料 3 列全保留（實際 \(sNormalNew.count)）")
check(sNormalNew.map(dumpState) == sNormalOld.map(dumpState), "新格式與舊格式正常資料 19 欄解析相同")
let oNormalOld = parseOrders(ordersNormalOld), oNormalNew = parseOrders(ordersNormalNew), oMixed = parseOrders(ordersMixed)
EOF
    if [ "$TAG" = "new" ]; then
      cat <<'EOF'
check(sNormalNew.allSatisfy { $0.business_type == "remittance" }, "新格式：business_type 讀到 remittance")
check(sNormalOld.allSatisfy { $0.business_type == "" }, "舊格式：沒有 index 19 時 business_type 為空字串、不是 tagihan")
check(!sMixed.contains { $0.recipient_name == "Tagihan" }, "混入資料：清單裡沒有 recipient_name=Tagihan 的列（剩 \(sMixed.count) 列：\(sMixed.map { $0.payment_info ?? "" }))")
check(sMixed.map { $0.payment_info ?? "" } == ["ERT001", "ERT002", "ERT003", "ERT004"], "混入資料：剩下的正好是四筆匯款，順序不變")
check(!sMixed.contains { $0.payment_info == "ERT902" }, "business_type 為 \"Tagihan\\n\"（結尾換行、大寫）的列也被跳過")
check(!sMixed.contains { $0.payment_info == "ERT903" }, "business_type 為 \" TAGIHAN \"（前後空白、全大寫）的列也被跳過")
check(sMixed.contains { $0.payment_info == "ERT004" && $0.business_type == "remittance\n" }, "business_type 為 \"remittance\\n\" 的匯款列保留，欄位原值不動")
check(sMixed.allSatisfy { $0.transfer_amount_idr != "" }, "混入資料：剩下的列 transfer_amount_idr 都不是空字串")
check(sMixed.count == 4 && dumpState(sMixed[2]) == dumpState(sNormalNew[2]), "多到 25 欄的列：未知索引被忽略，前 19 欄不變")

print("[\(tag)] orders_check")
check(oNormalOld.count == 3 && oNormalNew.count == 3, "正常資料 3 列全保留（\(oNormalOld.count)/\(oNormalNew.count)）")
check(oNormalNew.map(dumpOrder) == oNormalOld.map(dumpOrder), "新格式與舊格式正常資料 10 欄解析相同")
check(oNormalNew.allSatisfy { $0.business_type == "remittance" }, "新格式：index 10 讀到 remittance")
check(!oMixed.contains { $0.payment_info == "ERT900" || $0.payment_info == "ERT901" }, "混入資料：business_type=tagihan 的兩列被跳過（剩 \(oMixed.map { $0.payment_info ?? "" }))")
check(!oMixed.contains { $0.payment_info == "ERT902" }, "business_type 為 \"Tagihan\\n\" 的 orders_check 列也被跳過")
check(oMixed.contains { $0.payment_info == "ERT005" }, "business_type 為 \"remittance\\n\" 的 orders_check 列保留")
check(oMixed.count == 5, "混入資料：剩 5 列匯款（含 order_status 空字串／abc／9 的列，解析層不丟）")
EOF
    else
      cat <<'EOF'
print("  INFO  舊版對同一份混入資料解析出 \(sMixed.count) 列匯款卡片（其中 \(sMixed.filter { $0.recipient_name == "Tagihan" }.count) 列是繳費單，金額空白）")
print("[\(tag)] orders_check")
check(oNormalOld.count == 3 && oNormalNew.count == 3, "正常資料 3 列全保留（\(oNormalOld.count)/\(oNormalNew.count)）")
check(oNormalNew.map(dumpOrder) == oNormalOld.map(dumpOrder), "新格式與舊格式正常資料 10 欄解析相同")
print("  INFO  舊版對混入資料解析出 \(oMixed.count) 列（含 \(oMixed.filter { $0.payment_info == "ERT900" || $0.payment_info == "ERT901" }.count) 列繳費單）")
EOF
    fi
    cat <<'EOF'

if hasListVCHelpers {
    print("[\(tag)] TransferListVC：payment_info 配對與 order_status 安全解析")
    let vc = ListVC()
    vc.showOrderCheckDataList = oMixed
    check(vc.orderCheckData(For: "ERT003").order_status == "abc", "orderCheckData 用 payment_info 配對，不是用 index（ERT003 在 orders 第 4 列、匯款清單第 3 列）")
    check(vc.orderCheckData(For: "ERT900").order_status == "", "找不到（被跳過的繳費單）回空物件，不閃退")
    check(vc.orderCheckData(For: nil).order_status == "" && vc.orderCheckData(For: "").order_status == "", "payment_info nil／空字串回空物件")
    vc.showOrderCheckDataList = [orderRow("ERT005", status: "3"), orderRow("ERT005", status: "4")].map { f in let o = TransferOrderCheckObj(); for (i, v) in f.enumerated() { o.setValueByOrder(Order: i, Value: v) }; return o }
    check(vc.orderCheckData(For: "ERT005").order_status == "3", "重複 payment_info 取第一個")
    let grey = UIColor("#706F6F")
    check(vc.barColor(ForStatus: "1") == UIColor("#BD1621") && vc.barColor(ForStatus: "5") == grey, "order_status 1~5 對應原本的五個顏色")
    check(vc.barColor(ForStatus: "") == grey, "order_status 空字串 → 預設灰色，不閃退（改前這裡 Int(\"\")! 會閃退）")
    check(vc.barColor(ForStatus: "abc") == grey, "order_status 非數字 → 預設灰色")
    check(vc.barColor(ForStatus: "0") == grey && vc.barColor(ForStatus: "9") == grey && vc.barColor(ForStatus: "-3") == grey, "order_status 0／9／-3 超出範圍 → 預設灰色")
    check(vc.barColor(ForStatus: nil) == grey, "order_status nil → 預設灰色")
}

print("[\(tag)] 結果：\(failures == 0 ? "全部通過" : "\(failures) 項失敗")")
exit(failures == 0 ? 0 : 1)
EOF
  } > "$OUT"
}

run_program() { # src_dir tag
  local SRC="$1" TAG="$2"
  local SWIFT="$WORK/verify-$TAG.swift" BIN="$WORK/verify-$TAG"
  gen_program "$SRC" "$SWIFT" "$TAG"
  if ! swiftc -suppress-warnings -o "$BIN" "$SWIFT" 2> "$WORK/compile-$TAG.log"; then
    echo "[$TAG] 編譯失敗："
    cat "$WORK/compile-$TAG.log"
    return 2
  fi
  "$BIN" | tee "$WORK/out-$TAG.txt"
  return "${PIPESTATUS[0]}"
}

echo "== 新版（工作目錄 $REPO_DIR）=="
run_program "$REPO_DIR" new
NEW_RC=$?

# 改前的 Int(order_status)! - 1 用空字串會閃退，獨立小程式示範（預期非 0 結束）
echo
echo "== 改前寫法 Int(\"\")! - 1 的行為（獨立小程式，預期閃退）=="
cat > "$WORK/crash.swift" <<'EOF'
import Foundation
let order_status:String! = ""   // orders_check 配不到或繳費列欄位對不上時的值
let colorIdx = Int(order_status)! - 1
print("colorIdx=\(colorIdx)")
EOF
if swiftc -suppress-warnings -o "$WORK/crash" "$WORK/crash.swift" 2>/dev/null; then
  "$WORK/crash" >/dev/null 2>&1
  CRASH_RC=$?
  if [ "$CRASH_RC" -ne 0 ]; then
    echo "  INFO  改前寫法以結束碼 $CRASH_RC 中止（閃退重現）；新版 barColor 對同樣輸入回預設色（見上方 PASS）"
  else
    echo "  WARN  改前寫法沒有中止，與預期不同"
  fi
fi

BASE_RC=0
if [ -n "$BASELINE_REF" ]; then
  echo
  echo "== 舊版（git ref: $BASELINE_REF）=="
  OLD="$WORK/old"
  mkdir -p "$OLD/indogo/View/Transfer" "$OLD/indogo/Base"
  for f in "$STATE_OBJ" "$ORDER_OBJ" "$API_HANDLE" "$LIST_VC"; do
    git -C "$REPO_DIR" show "$BASELINE_REF:$f" > "$OLD/$f" || { echo "抽不到 $BASELINE_REF:$f"; exit 2; }
  done
  run_program "$OLD" old
  BASE_RC=$?
  echo
  echo "== 正常資料：舊版 vs 新版 解析結果比對（19／10 欄）=="
  if [ ! -s "$WORK/out-old.txt" ] || [ ! -s "$WORK/out-new.txt" ]; then
    echo "  FAIL  缺少舊版或新版輸出，無法比對"
    BASE_RC=1
  else
    sed -n '/### COMPARE-BEGIN/,/### COMPARE-END/p' "$WORK/out-old.txt" | sed 's/ old$//' > "$WORK/cmp-old.txt"
    sed -n '/### COMPARE-BEGIN/,/### COMPARE-END/p' "$WORK/out-new.txt" | sed 's/ new$//' > "$WORK/cmp-new.txt"
    ROWS="$(grep -c '|' "$WORK/cmp-new.txt")"
    if [ "$ROWS" -lt 12 ]; then
      echo "  FAIL  比對輸出列數不足（$ROWS，預期 12）"
      BASE_RC=1
    elif diff "$WORK/cmp-old.txt" "$WORK/cmp-new.txt" > "$WORK/cmp.diff"; then
      echo "  PASS  正常資料（舊格式 19 欄、新格式 20 欄；匯款清單與 orders_check）解析結果與改前完全相同（$ROWS 列）"
    else
      echo "  FAIL  正常資料解析結果與改前不同："
      cat "$WORK/cmp.diff"
      BASE_RC=1
    fi
  fi
fi

echo
if [ "$NEW_RC" -eq 0 ] && [ "$BASE_RC" -eq 0 ]; then
  echo "== 全部通過 =="
  exit 0
else
  echo "== 有失敗項（new=$NEW_RC baseline=$BASE_RC）=="
  exit 1
fi
