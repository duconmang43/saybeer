# Hồ sơ nộp SayBeer lên Apple

Cập nhật 2026-10-23. Thứ tự bắt buộc: **xin entitlement trước** (chờ vài tuần), mọi thứ khác làm song song trong lúc chờ.

TODO (điền trước khi nộp):
- `SUPPORT_URL` = https://saybeer.1labs.space/ (đã set vào ASC qua API 2026-10-23)
- `PRIVACY_POLICY_URL` = https://saybeer.1labs.space/privacy.html (đã set vào ASC qua API 2026-10-23)

## 1. Xin entitlement Family Controls (Distribution) — LÀM NGAY

- Form chính thức (đăng nhập Apple Developer của team MH385VJBCB): **https://developer.apple.com/contact/request/family-controls-distribution**
- Bản development đang dùng không cần duyệt, nhưng **mọi kênh cần distribution profile (TestFlight, App Store) đều cần entitlement được duyệt**.
- Báo cáo từ cộng đồng: có người được duyệt sau vài ngày, có người 2 tuần–vài tháng; nhiều người không nhận được case ID — cứ chờ rồi check mục Identifiers. Không thấy phản hồi sau ~3 tuần thì mở ticket Developer Support.
- Có tranh cãi 1 form cho cả app hay mỗi bundle ID một form → **liệt kê cả 3 bundle ID trong phần mô tả** cho chắc:
  - `com.jedix.saybeer` (app)
  - `com.jedix.saybeer.monitor` (DeviceActivityMonitor extension)
  - `com.jedix.saybeer.shield` (ShieldConfiguration extension)
- Sau khi được duyệt: developer.apple.com → Certificates, Identifiers & Profiles → Identifiers → từng identifier → **Additional Capabilities** → bật Family Controls — làm cho **cả 3 identifier**, rồi tạo lại distribution provisioning profiles.

### Nội dung điền form (tiếng Anh, copy/chỉnh)

> **App name:** SayBeer
> **Bundle IDs:** com.jedix.saybeer (app), com.jedix.saybeer.monitor (DeviceActivityMonitor extension), com.jedix.saybeer.shield (ShieldConfiguration extension)
>
> **How does your app use Family Controls?**
> SayBeer is a self-control app that helps adults avoid sending regrettable messages while drinking. Before a night out, the user voluntarily selects messaging/social apps with FamilyActivityPicker and sets an unlock time. The app uses ManagedSettingsStore shields to block the selected apps until that time, a DeviceActivityMonitor extension to lift the shield on schedule (and to re-apply it after a temporary 15-minute "work message" window the user can open up to 3 times per session), and a ShieldConfiguration extension to show a custom shield screen. Authorization is requested with AuthorizationCenter for the individual (.individual) — this is a self-restriction app, not a parental-control app. All data stays on device; the app has no network features, no accounts, and no analytics.

## 2. App Store Connect — tạo app record

- My Apps → "+" → New App: platform iOS, name **SayBeer**, bundle ID `com.jedix.saybeer`, SKU `saybeer-001`, ngôn ngữ chính **Vietnamese**.
- **Category**: Primary = Lifestyle; Secondary = Productivity.
- **Price**: Free (quyết định sau nếu muốn thu phí — đổi sau được).

### Age rating (trả lời questionnaire)
- "Alcohol, Tobacco, or Drug Use or References" → **Frequent/Intense** (app xoay quanh chuyện nhậu) → kết quả **17+**. Khai thấp hơn dễ bị reject vì metadata toàn bia rượu.
- Các mục khác: None.

### Metadata tiếng Việt (chính)
- **Tên**: SayBeer
- **Subtitle** (≤30 ký tự): `Khóa app nhắn tin khi nhậu`
- **Keywords** (≤100 ký tự): `nhậu,say,khóa app,screen time,tự chủ,drunk,block,tin nhắn,bia,cai điện thoại`
- **Promotional text**: `Hãy say bia. Xin đừng "say" bậy.`
- **Description**:

> Nhậu say rồi nhắn tin linh tinh — sáng mai xấu hổ với bạn bè, phiền chuyện công việc? SayBeer khóa giùm bạn.
>
> TRƯỚC KHI ĐI NHẬU
> • Chọn app nhắn tin cần khóa (Zalo, Messenger, Messages…), hẹn giờ mở — mặc định 6h sáng.
> • Hoặc hẹn lịch sẵn: tối thứ 6, thứ 7 tự khóa, không cần nhớ.
>
> TRONG CUỘC NHẬU
> • App bị khóa, nhưng thông báo vẫn hiện — bạn vẫn đọc được tin đến.
> • Cần nhắn việc? Mở tạm 15 phút (tối đa 3 lần), hết giờ tự khóa lại.
> • Muốn mở hẳn sớm? Gõ đúng câu líu lưỡi tiếng Việt + tính nhẩm trong 90 giây. Say thì chịu.
> • Khẩn cấp thật sự: giữ nút 5 giây — mở ngay, không hỏi.
>
> SÁNG HÔM SAU
> • Tự mở khóa đúng giờ. Xem thống kê: bao nhiêu phiên an toàn, chuỗi bao nhiêu trận không "tai nạn".
>
> RIÊNG TƯ TUYỆT ĐỐI
> • Dùng Screen Time của Apple. Không mạng, không tài khoản, không đọc tin nhắn, không thu thập gì — mọi thứ nằm trên máy bạn.

### Metadata tiếng Anh (localization thêm, làm sau cũng được)
- Subtitle: `Block texting while drinking` — description dịch từ bản Việt.

## 3. App Privacy (bắt buộc khai trước khi submit)
- **Data Not Collected** — khai không thu thập bất kỳ loại dữ liệu nào (đúng thực tế: không network, không analytics, lịch sử phiên chỉ nằm trong App Group trên máy).
- Privacy Policy URL: `PRIVACY_POLICY_URL` (mục 5).

## 4. Review Notes (dán vào App Review Information — tiếng Anh)

> SayBeer is a SELF-control drinking companion app (not parental control). It uses the Screen Time API exactly as documented:
> - FamilyControls: AuthorizationCenter.requestAuthorization(for: .individual); FamilyActivityPicker for the user to choose which of THEIR OWN apps to block.
> - ManagedSettings: shield.applications/applicationCategories to block chosen apps for a user-chosen period; application.denyAppRemoval (optional toggle, clearly explained in-app) so the block can't be bypassed by deleting apps mid-session.
> - DeviceActivity: schedules to auto-lift the shield at the chosen time, re-apply it after a temporary 15-minute window, and run user-created weekly schedules.
> - ManagedSettingsUI: custom shield screen.
>
> HOW TO TEST: Complete onboarding and grant Screen Time permission. Tap "Bắt đầu chế độ nhậu" (Start beer mode), pick any app (e.g. Messages) with the picker, choose "+4 giờ" and tap "Khóa ngay" (Lock now). The picked app now shows our custom shield. To unlock early: "Tỉnh rồi — mở khóa hẳn" requires retyping a Vietnamese tongue-twister (+ optional mental math) within 90s; or hold the red "Khẩn cấp" (Emergency) button for 5 seconds to unlock instantly. "Cần nhắn việc" opens a temporary 15-minute window. The app needs no account and no network.

Lưu ý né reject 2.5.1: app chỉ dùng shield để **chặn mở app** đúng tài liệu — không "ẩn app" (blockedApplications để hide từng bị reject), không VPN/MDM. Không đổi cơ chế này khi chưa đọc lại guideline.

## 5. Privacy Policy (nội dung để host — VN + EN)

> **SayBeer — Chính sách quyền riêng tư / Privacy Policy**
> SayBeer không thu thập, lưu trữ hay chia sẻ bất kỳ dữ liệu cá nhân nào. App không kết nối mạng, không có tài khoản, không chứa analytics hay quảng cáo. Danh sách app bạn chọn khóa và lịch sử phiên chỉ được lưu trên thiết bị của bạn (App Group của app) và bị xóa khi bạn xóa app. Quyền Screen Time chỉ dùng để khóa các app do chính bạn chọn, trên thiết bị của bạn.
> SayBeer does not collect, store, or share any personal data. The app has no network connection, no accounts, no analytics, and no ads. Your selected apps and session history are stored only on your device (in the app's App Group container) and are deleted when you delete the app. The Screen Time permission is used solely to block apps you yourself choose, on your own device.
> Liên hệ / Contact: feedback@1labs.space

## 6. Build & nộp

1. Entitlement được duyệt + bật Additional Capabilities cho 3 identifier (mục 1).
2. Tăng version nếu cần (`project.yml`: MARKETING_VERSION), `xcodegen generate`.
3. Xcode → Product → Archive (scheme SayBeer, Any iOS Device) → Organizer → Distribute App → App Store Connect. Signing automatic sẽ lấy profile distribution mới.
4. **Screenshots** (chụp trên iPhone 16 Pro Max — đủ cỡ 6.9"; cỡ 6.5" Apple tự scale): màn chính, màn bắt đầu phiên, màn đang khóa (countdown), custom shield (chụp màn hình app bị chặn), bài kiểm tra tỉnh táo, thống kê. 3–10 ảnh.
5. TestFlight nội bộ trước (chính máy TN + vài bạn nhậu) ít nhất 1 tuần — vừa test extension chạy đêm thật, vừa có số liệu thống kê thật để chụp screenshot.
6. Submit for Review với Review Notes ở mục 4.

## 7. Checklist tổng

- [ ] Nộp form entitlement (mục 1) — **làm hôm nay**
- [ ] Host privacy policy → điền `PRIVACY_POLICY_URL`
- [ ] Support URL → điền `SUPPORT_URL`
- [ ] Tạo app record + metadata VN (mục 2)
- [ ] Khai App Privacy = Data Not Collected (mục 3)
- [ ] Entitlement duyệt → bật capability 3 identifier → archive + upload
- [ ] TestFlight 1 tuần
- [ ] Screenshots + submit
