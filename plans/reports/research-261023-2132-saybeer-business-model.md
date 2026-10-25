# Business model SayBeer

Ngày: 2026-10-23. Bối cảnh: app đã WAITING_FOR_REVIEW, miễn phí, chưa có backend, chi phí vận hành ≈ 0.

## 1. Bài toán kinh doanh

SayBeer bán một thứ không app nào trong nhóm screen-time bán: **bảo hiểm danh dự cho người đi nhậu**. Khách không mua "giảm thời gian dùng máy" (mơ hồ, dài hạn) — họ mua "sáng mai không phải xin lỗi ai" (cụ thể, cảm xúc, tính theo từng trận nhậu). Nỗi đau lặp lại hàng tuần, hậu quả đo được (mất mặt với sếp/khách/crush), và khoảnh khắc cần app rất rõ: 30 giây trước khi cụng ly đầu tiên.

Thị trường: người Việt 18–40 có văn hóa nhậu thường xuyên — tập khách rất lớn, chưa ai phục vụ đúng ngách này bằng tiếng Việt (các app "Drunk Mode" quốc tế đều chết hoặc generic; Opal/one sec bán "focus", không bán "nhậu").

## 2. Mốc giá thị trường (đã verify 2026)

| App | Model | Giá |
|---|---|---|
| Opal | Freemium + subscription | $99.99/năm, $19.99/tháng, $399 lifetime |
| one sec | Freemium + subscription | ~$19.99/năm, $99.99 lifetime (trước đây one-time, đã chuyển subscription) |

Hai điểm rút ra: (1) ngành này nuôi được subscription giá cao ở thị trường Tây; (2) Việt Nam không trả nổi mức đó — nhưng mức bia hơi (30–50k/lần) thì trả không cần nghĩ.

## 3. Mô hình đề xuất: 3 giai đoạn

### Giai đoạn 1 — NGAY BÂY GIỜ: Free + "Mời tôi một ly" (tip jar)
- App miễn phí 100%, đủ tính năng. Mục tiêu duy nhất: **user base + word of mouth**.
- Thêm 1 IAP consumable dạng tip, đặt ở màn thống kê sau một phiên an toàn — đúng lúc user biết ơn nhất: *"SayBeer vừa cứu bạn một trận. Mời tôi một ly?"* — 3 mức: ly bia hơi **29k**, ly bia tươi **49k**, két bia **199k**.
- Vì sao hợp: đúng giọng thương hiệu, không chặn ai, không nợ tính năng, triển khai 1 buổi (StoreKit consumable, không backend). Kỳ vọng thấp về tiền (1–3% tip) nhưng là phép đo willingness-to-pay thật.

### Giai đoạn 2 — KHI CÓ ~5–10k MAU: SayBeer Pro, MUA MỘT LẦN
- **Không subscription ở VN** — tỉ lệ hủy/ghét sub cao, app lại không có chi phí server để biện minh. Mua một lần **99k VND** (anchor: "giá 2 ly bia, xài cả đời") / tier quốc tế $4.99.
- Free giữ nguyên lõi (khóa thủ công, cửa sổ nhắn việc, kiểm tra, khẩn cấp — chặn ai cũng phải đủ, vì sản phẩm chỉ có giá trị khi nó thật sự chặn). Pro bán phần "nghiện rồi mới cần":
  - Hẹn lịch tự khóa (tính năng ăn tiền nhất — người nhậu đều đặn mới cần)
  - Thống kê đầy đủ + chuỗi + share ảnh "sống sót N trận"
  - Tùy chỉnh: câu líu lưỡi riêng, số cửa sổ nhắn việc, thời lượng, câu cam kết
  - Nhiều hồ sơ khóa (nhậu sếp / nhậu bạn / về quê)
- Apple Small Business Program: phí 15% → 99k thu về ~84k/giao dịch.

### Giai đoạn 3 — KHI CÓ TRACTION (>30k users hoặc viral): B2B "Uống có trách nhiệm"
- Các hãng bia tại VN có ngân sách CSR "drink responsibly" (Heineken 0.0, Sabeco, Tiger) — SayBeer là case PR hoàn hảo: app Việt, vui, đúng thông điệp. Bán: chiến dịch đồng thương hiệu, sponsor "mùa Tết an toàn".
- Affiliate gọi xe: nút "Đặt xe về" (Grab/Be/Xanh SM) ngay màn đang khóa — tự nhiên tới mức gần như là tính năng. Hoa hồng affiliate hoặc deal API.
- Tuyệt đối KHÔNG bán dữ liệu/quảng cáo tracking — "không mạng, không thu thập" là moat thương hiệu, phá nó là chết ngách.

## 4. Vòng tăng trưởng (chi phí 0đ)

1. **Share ảnh thống kê**: "🍺 Sống sót 12 trận, 0 tin nhắn hối hận" — ảnh đẹp, tự khoe lên story/nhóm nhậu → mỗi user kéo bạn nhậu (chính là tập khách). Cần làm trước khi đẩy mạnh.
2. **Content TikTok/Threads**: thể loại "drunk text hối hận" vốn viral sẵn ở VN; SayBeer là punchline tự nhiên. Làm 10–15 clip ngắn kịch bản tình huống (chi phí: thời gian).
3. **Mùa vụ**: Tết (đỉnh nhậu năm), World Cup/SEA Games, 20/10–8/3. Lịch content + ASO theo mùa.
4. **ASO tiếng Việt**: từ khóa "nhậu", "say", "khóa app" gần như không có đối thủ.

## 5. Unit economics phác

- Chi phí cố định: $99/năm dev account + VPS dùng chung (đã có) ≈ **~3 triệu VND/năm**. Biên lợi nhuận gộp ≈ 100%.
- Kịch bản khiêm tốn giai đoạn 2: 10.000 lượt tải → 30% kích hoạt đều (3.000) → 4% mua Pro 99k = **~12 triệu VND** + tip. Kịch bản viral 1 clip (100k lượt tải): **~120 triệu**. Không phải startup scale — là **sản phẩm indie lãi ròng từ ngày đầu**, và là lead-gen uy tín cho 1labs.
- Số cần theo dõi: retention theo **tuần nhậu** (W1/W4 có mở phiên không — không phải DAU), tỉ lệ phiên "sống sót", conversion tip → định giá Pro.

## 6. Rủi ro chính

- **Apple**: đổi chính sách Screen Time / review chặt — không tránh được, giảm thiểu bằng dùng API đúng tài liệu (đang vậy).
- **Dễ nhái tính năng**: moat không nằm ở code mà ở **giọng điệu Việt + thương hiệu vui + cộng đồng** — đầu tư vào content hơn là thêm tính năng.
- **Mùa vụ/tần suất thấp**: app mở 1–3 lần/tuần → đừng đo DAU kẻo tự lừa; hẹn lịch tự khóa chính là tính năng chống quên app.
- **Nhạy cảm xã hội**: app "phục vụ dân nhậu" có thể bị đọc ngược — thông điệp luôn là *uống có trách nhiệm*, không cổ vũ nhậu.

## 7. Việc làm ngay (theo thứ tự)

1. Qua review → ship. Gắn link App Store vào landing (TODO có sẵn).
2. Làm **share ảnh thống kê** (1 buổi code) — mồi tăng trưởng quan trọng nhất.
3. Thêm tip jar IAP (1 buổi, cần tạo IAP trong ASC + bật Small Business Program).
4. 5 clip TikTok test giọng điệu trước Tết.
5. Đạt 5k MAU → build Pro một-lần 99k theo danh sách ở giai đoạn 2.

## Nguồn
- [Opal pricing review 2026](https://www.autonomous.ai/en-VN/ourblog/opal-app-review) — $99.99/yr, $19.99/mo, $399 lifetime, free tier 1 Rule.
- [one sec IAP tracking](https://apppricinglab.com/iap/apple/1532875441) — $19.99/yr Pro, $99.99 lifetime; [chuyển từ one-time sang subscription](https://www.starterstory.com/businesses/one-sec/monetization) (nguồn yếu).
- [RevenueCat 2025 monetization trends](https://www.revenuecat.com/blog/growth/2025-app-monetization-trends) — giá premium tăng ~5%/năm ở quartile trên.
