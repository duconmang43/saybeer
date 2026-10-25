# SayBeer — app iOS chặn nhắn tin khi say

## Outcome
App iOS cá nhân (sideload, team MH385VJBCB): trước khi đi nhậu bật "Chế độ nhậu" → khóa các app nhắn tin tự chọn bằng Screen Time API đến giờ hẹn; mở khóa sớm phải vượt bài kiểm tra tỉnh táo.

## Ràng buộc
- Chỉ Screen Time API (FamilyControls + ManagedSettings) mới chặn được app khác trên iOS — không có đường vòng.
- Entitlement `com.apple.developer.family-controls` (development) → **phải cài qua Xcode với dev signing**; ESign nhiều khả năng làm mất entitlement này.
- Chạy trên máy thật, iOS 17+. FamilyActivityPicker không hoạt động trên simulator.

## Yêu cầu bổ sung (user, 2026-10-23)
Vẫn cần nhắn tin công việc khi đang nhậu → thêm **cửa sổ nhắn việc**: mở tạm 15 phút/lần (tối đa 3 lần/phiên), qua bước cam kết nhẹ (gõ đúng câu cam kết + chờ 15s); hết giờ tự khóa lại bằng DeviceActivityMonitor extension (15 phút là mức tối thiểu của DeviceActivitySchedule).

## Non-goals (v1)
- Không custom shield screen (dùng màn hình chặn mặc định của iOS).
- Không App Store / không analytics.

## Acceptance criteria
- Build sạch cho generic iOS device.
- Chọn app cần khóa (FamilyActivityPicker), chọn giờ kết thúc (preset "6h sáng mai", +4h, +8h, tùy chọn).
- Đang khóa: countdown; mở sớm phải gõ đúng câu líu lưỡi tiếng Việt + giải 1 phép tính trong 90s; sai 3 lần khóa thêm 5 phút.
- Hết giờ: mở SayBeer → tự gỡ shield.

## Cấu trúc
- `project.yml` (xcodegen) — 1 target duy nhất.
- `SayBeer/`: App, SessionStore (UserDefaults), ShieldController (ManagedSettingsStore), HomeView, StartSessionSheet, SobrietyTestView.
