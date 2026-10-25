# Kế hoạch tăng trưởng 0 đồng — share ảnh, TikTok, mùa Tết

Ngày: 2026-10-23. Gắn với business model (research-261023-2132). Phần share ảnh ĐÃ CODE XONG cùng ngày.

## 1. Share ảnh thành tích — ĐÃ SHIP ✅

- Màn Thống kê có nút "Khoe thành tích với hội nhậu" + nút share trên toolbar → sinh ảnh 1080×1350 (tỉ lệ story): "SỐNG SÓT N trận nhậu", giờ đã khóa, chuỗi an toàn, tagline + saybeer.1labs.space. Render on-device bằng ImageRenderer, không mạng.
- Vòng lặp: người nhận ảnh trong nhóm nhậu chính là khách hàng mục tiêu → URL ở đáy ảnh là kênh acquisition.
- Đo: sau này thêm đếm số lần bấm share (local) để biết mồi có chạy không.

## 2. Content TikTok — thể loại & 12 kịch bản

Cơ sở (nguồn quốc tế, VN chưa có số liệu công khai — phải test): [nghiên cứu nội dung alcohol trên TikTok](https://pmc.ncbi.nlm.nih.gov/articles/PMC9798380) — **55% video viral có yếu tố hài, 45% gắn với tình anh em/bạn nhậu**. Đúng công thức SayBeer: hài tình huống + hội nhậu, KHÔNG cổ vũ uống (tránh nhóm nội dung bị siết như trend borg/drunk-driving).

Format chủ lực: **POV skit 15–30s** (1 người quay cũng làm được), đọc màn hình tin nhắn giả lập, và stitch/duet các clip "hối hận sau nhậu" có sẵn. Luôn kết bằng 1 frame app (màn khóa hoặc màn shield "Để mai nhắn") — không kêu gọi tải lộ liễu.

12 kịch bản test (4 nhóm × 3):
1. **Nhóm "suýt chết"** — (a) POV: 1h sáng gõ "em ngủ chưa" cho crush, bấm gửi thì màn hình hiện "SayBeer đang khóa — Để mai nhắn" → thở phào; (b) POV: định voice 3 phút tỏ tình với ex, app chặn, sáng dậy xem lại draft mà rùng mình; (c) gõ "sếp ơi em nói thật nhé" vào nhóm công ty → shield chặn → thứ 2 đi làm bình thường, đồng nghiệp không biết gì.
2. **Nhóm "đã quá muộn" (đau thật, không có app)** — (a) đọc lại đoạn chat tối qua gửi nhầm nhóm gia đình; (b) compilation "những tin nhắn 2h sáng" (do bạn bè gửi về, xin phép + che tên); (c) sáng dậy nhắn từng người "tối qua mình có nói gì không".
3. **Nhóm "hội nhậu"** — (a) cả bàn cùng bật chế độ nhậu trước khi cụng ly đầu — nghi thức mới; (b) thằng bạn duy nhất không bật app, sáng hôm sau…; (c) thách nhau qua bài kiểm tra tỉnh táo lúc đã 5 chai — quay cảnh gõ "lúa nếp là lúa nếp làng" sai liên tục (humor tự nhiên nhất của app).
4. **Nhóm tính năng-là-punchline** — (a) "app gì mà muốn mở phải gõ câu líu lưỡi"; (b) cửa sổ nhắn việc: "chỉ nhắn việc, không tâm sự" — gõ xong lại nhắn tâm sự với sếp(?); (c) nút Khẩn cấp giữ 5 giây — "khẩn cấp thật hay nhớ người yêu cũ?".

Nhịp đăng: 3 clip/tuần × 4 tuần = hết 12 kịch bản → giữ lại 2–3 format có view tốt nhất, bỏ phần còn lại. Kênh: TikTok chính, cắt đăng lại Reels + Shorts. Hashtag: #nhậu #saybeer #drunktext #uongcotrachnhiem.

Ranh giới nội dung (bắt buộc): không quay cảnh uống thực sự quá đà, không lái xe, không chế giễu người say cụ thể, luôn thông điệp nền "uống có trách nhiệm" — vừa đạo đức vừa tránh TikTok gỡ video ([TikTok đang bị soi mạnh về alcohol content](https://www.rollingstone.com/culture/culture-news/tiktok-drunk-driving-booze-cruise-gang-alcohol-1234588210)).

## 3. Mùa vụ Tết — timeline ngược

Tết Âm lịch 2027 rơi vào đầu tháng 2/2027 → mùa nhậu cao điểm chạy từ giữa tháng 12/2026 (tất niên công ty) đến hết tháng 2 (tân niên, khai xuân).

| Mốc | Việc |
|---|---|
| Ngay khi app qua review (T10–11) | Gắn link App Store vào landing + ảnh share; bắt đầu 12 clip test |
| 01/12/2026 | Chốt 2–3 format clip thắng; chuẩn bị bộ clip chủ đề "tất niên" |
| 15/12/2026 → Tết | Cao điểm: 4–5 clip/tuần chủ đề tất niên/liên hoan công ty — đây là lúc "nhắn nhầm nhóm có sếp" đau nhất |
| 2 tuần trước Tết | Cập nhật ASO: thêm "tất niên, tân niên, chúc Tết" vào keywords; promotional text đổi theo Tết ("Chúc Tết tỉnh táo") |
| Trong Tết | Clip "chúc Tết họ hàng lúc 1h sáng" + ảnh share phiên bản Tết (nếu kịp: thêm khung Tết cho ShareCardView — việc nhỏ) |
| Sau Tết | Tổng kết số liệu, quyết định thời điểm ship Pro 99k (business model giai đoạn 2) |

## 4. Việc code còn lại trong kế hoạch này

- [ ] Đếm local số lần share (thêm 1 key UserDefaults, hiện trong Thống kê) — đo mồi tăng trưởng.
- [ ] Khung Tết cho ảnh share (đổi màu/câu chúc theo mùa) — làm trước 15/12.
- [ ] Gắn APP_STORE_URL vào landing khi app qua review.

## Nguồn
- [PMC — phân tích video alcohol trên TikTok: 55% hài, 45% camaraderie](https://pmc.ncbi.nlm.nih.gov/articles/PMC9798380)
- [Movendi — alcohol portrayal trên TikTok](https://movendi.ngo/science-digest/alcohol-portrayals-of-alcohol-in-top-videos-on-tiktok/)
- [Rolling Stone — TikTok siết nội dung say xỉn/lái xe](https://www.rollingstone.com/culture/culture-news/tiktok-drunk-driving-booze-cruise-gang-alcohol-1234588210)
- Lưu ý: không tìm được số liệu công khai về trend "drunk text" TikTok Việt Nam — 12 kịch bản trên là giả thuyết cần test bằng chính nhịp đăng 4 tuần đầu.
