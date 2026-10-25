# SayBeer — cài đặt & sử dụng

## Cài lên iPhone (bắt buộc qua Xcode, KHÔNG dùng ESign)
App dùng entitlement `com.apple.developer.family-controls` (Screen Time) + App Group — ESign resign gần như chắc chắn làm mất entitlement, app sẽ không khóa được gì. Cài dev signing trực tiếp:

1. `xcodegen generate` (nếu chưa có `SayBeer.xcodeproj` — project generate từ `project.yml`).
2. Mở `SayBeer.xcodeproj`, cắm iPhone, chọn device, Run. Team đã đặt sẵn `MH385VJBCB`, signing Automatic — Xcode tự tạo App ID với capability Family Controls (development) và App Group `group.com.jedix.saybeer`.
3. Lần đầu mở app: iOS hỏi quyền Screen Time → **Allow**.
4. Dev signing hết hạn sau 7 ngày (account free) hoặc 1 năm (paid) — hết hạn thì Run lại từ Xcode.

Yêu cầu: iOS 17+, máy thật (FamilyActivityPicker không chạy trên simulator).

## Cách dùng
- **Trước khi nhậu**: mở app → "Bắt đầu chế độ nhậu" → chọn app cần khóa (Messages, Zalo, Messenger… hoặc cả nhóm Social) → chọn giờ mở (mặc định 6h sáng) → Khóa ngay.
- **Cần nhắn việc giữa chừng**: mở SayBeer → "Cần nhắn việc" → gõ đúng câu cam kết + chờ 15s → app được mở 15 phút rồi tự khóa lại. Tối đa 3 lần/cuộc nhậu.
- **Mở hẳn trước giờ**: "Tỉnh rồi — mở khóa hẳn" → gõ chính xác 1 câu líu lưỡi tiếng Việt (đúng cả dấu, tắt autocorrect, luôn bắt buộc) + tính nhẩm 2 số có nhớ (bật/tắt bằng công tắc "Kèm tính nhẩm" trong màn bắt đầu phiên), trong 90 giây. Sai 3 lần → khóa thêm 5 phút.
- **Khẩn cấp**: nút "Khẩn cấp" (đỏ, dưới cùng màn hình đang khóa) → giữ nút 5 giây liên tục → gỡ khóa toàn bộ ngay, không kiểm tra gì, kết thúc luôn chế độ nhậu. Nhả tay giữa chừng là tính lại từ đầu.
- **Hết giờ hẹn**: extension tự gỡ khóa nền, không cần mở app.
- **Hẹn lịch tự khóa**: màn chính → "Hẹn lịch" → chọn thứ trong tuần + khung giờ (vd T6, T7 từ 18:00 đến 06:00). Tới giờ máy tự khóa danh sách app đã chọn, kể cả khi không mở SayBeer; hết giờ tự mở. Phiên tay đang chạy thì lịch không đè lên.
- **Thống kê**: màn chính → "Thống kê" (hoặc bấm thẻ tóm tắt) — số phiên an toàn, tổng giờ khóa, số lần mở bằng kiểm tra/khẩn cấp, chuỗi phiên an toàn liên tiếp, danh sách 30 phiên gần nhất. Lịch sử lưu on-device trong App Group (tối đa 200 phiên).
- **Lần đầu mở app**: 3 màn onboarding giải thích trước khi iOS hỏi quyền Screen Time.
- **Màn chặn**: app bị khóa hiện màn chặn riêng của SayBeer (cốc bia + "Để mai nhắn") thay màn xám mặc định iOS.

## Chống né khóa
- Trong phiên nhậu, `denyAppRemoval` được bật → **không xóa được app nào** (kể cả SayBeer) để thoát khóa. Hết phiên hoặc mở khóa thì gỡ.
- Lỗ hổng còn lại (Apple không cho bịt): vào Cài đặt tắt quyền Screen Time của SayBeer.

## Kiến trúc (3 target)
- `SayBeer` (app): UI SwiftUI, `SessionStore` giữ trạng thái + lịch sử phiên + lịch tự khóa trong App Group UserDefaults, shield bằng `ManagedSettingsStore`.
- `SayBeerMonitor` (DeviceActivityMonitor extension): chạy nền theo `DeviceActivitySchedule` — gỡ shield khi hết phiên, khóa lại khi hết cửa sổ nhắn việc, bật phiên theo lịch tự động (`saybeer.auto.<weekday>`, repeats hàng tuần), ghi lịch sử phiên khi kết thúc nền. Lưu ý: schedule tối thiểu 15 phút → cửa sổ nhắn việc là 15 phút.
- `SayBeerShield` (ShieldConfiguration extension): màn chặn tùy biến thay shield mặc định.
- `Shared/SharedCore.swift` (Foundation-only) + `Shared/SharedStore.swift` (FamilyControls) dùng chung cho cả 2 target.
- Lưới an toàn: mỗi lần app active, `SessionStore.tick()` đồng bộ lại shield theo giờ thực (phòng extension không chạy).
- Tính năng đã gỡ (2026-10-23, theo yêu cầu): bàn phím lọc nội dung và triage "Có gấp không?" — code nằm trong Thùng rác (`~/.Trash/saybeer-removed-*`) nếu cần khôi phục.

## Build kiểm tra nhanh
```sh
xcodebuild -project SayBeer.xcodeproj -scheme SayBeer \
  -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```