# Research: hướng phát triển SayBeer — chặn nội dung xấu khi say trên iOS

Ngày: 2026-10-23. Câu hỏi gốc của user: "có cơ chế OCR để phát hiện nhắn thuật ngữ hay vấn đề không tốt, sau đó chặn nút gửi không?" + "nghiên cứu sâu hơn để phát triển cho phù hợp".

## Kết luận nhanh

1. **OCR màn hình + chặn nút gửi app khác: không khả thi trên iOS** — sandbox không cho đọc UI app khác; ReplayKit quay được màn hình nhưng chỉ xem, không can thiệp. Không có app nào trên App Store làm được điều này.
2. **Bàn phím tùy chỉnh là cơ chế duy nhất "nhìn thấy nội dung đang gõ" hợp lệ** — và phát hiện quan trọng: bàn phím **không cần Full Access** vẫn *đọc* được App Group (chỉ ghi mới cần) → SayBeer app ghi trạng thái "đang nhậu", bàn phím chỉ đọc → không phải xin Full Access, không mạng, không lo lộ keystroke.
3. Nên bổ sung **chống né khóa**: `ManagedSettingsStore.application.denyAppRemoval` chặn xóa app khi đang trong phiên (đây chính là "App Uninstall Protection" của Opal).

## Chi tiết từng cơ chế

### 1. Bàn phím SayBeer (khuyến nghị làm v1.1)
- Keyboard extension thấy mọi ký tự gõ ra ở app khác và **tự quyết định có chèn ký tự hay không** → chặn/trì hoãn được nội dung xấu *trước khi* nó vào ô chat — gần nhất với "chặn nút gửi" mà user muốn.
- **Không cần Full Access** nếu chỉ đọc App Group (read-only OK, ghi mới bị chặn — nguồn: Apple forum, cần verify trên máy thật). Không Full Access = iOS không hiện cảnh báo đáng sợ "keyboard có thể gửi mọi thứ bạn gõ".
- Giới hạn thật: user đổi về bàn phím mặc định được (iOS không cho ép); không thấy text dán vào / voice message; RAM cap ~30–60 MB; không hiện alert UIKit (nhưng tự vẽ UI trong keyboard view được).
- Phát hiện nội dung tiếng Việt, on-device:
  - **Wordlist**: repo `blue-eyes-vn/vietnamese-offensive-words` có sẵn cả biến thể không dấu + teencode — đủ cho v1.1 (match wordlist + chờ/cảnh báo).
  - **Nâng cấp sau (v2)**: train `MLTextClassifier` (CreateML → NLModel, chạy on-device, iOS 15+) bằng dataset ViHSD (~33K comment, nhãn HATE/OFFENSIVE/CLEAN, MIT) hoặc ViHOS (span-level). Sentiment có sẵn của NLTagger không chắc hỗ trợ tiếng Việt — không dựa vào.
  - Heuristic rẻ bổ sung: đang beer mode + tin dài bất thường / tỉ lệ xóa-sửa cao (gõ sai nhiều = say) → bắt chờ 30s trước khi cho gõ tiếp.
- Kết hợp đẹp với thiết kế hiện tại: trong **cửa sổ nhắn việc 15 phút**, bàn phím vẫn canh nội dung — đúng pain "cần nhắn việc nhưng sợ nhắn linh tinh".

### 2. Custom shield screen (ShieldConfiguration + ShieldAction) — v1.2
- Làm được: màn khóa mang giọng SayBeer ("Để mai nhắn, giờ đi uống nước đi 🍺") thay màn mặc định. Tạo target bằng Xcode template (tự viết Info.plist hay bị không fire).
- Giới hạn: nút trên shield chỉ trả về `.none/.defer/.close` — **không mở được app SayBeer trực tiếp** (workaround: bắn local notification, được báo là thiếu ổn định trên TestFlight; nhiều app dùng private API — không nên).
- Lưu ý: có báo cáo lỗi DeviceActivity trên iOS 26 (threshold fire sớm, token đổi bất thường) — giữ cơ chế fallback `tick()` hiện có.

### 3. Chống né khóa — nên thêm ngay (1–2 dòng)
- `store.application.denyAppRemoval = true` khi phiên bắt đầu → không xóa được app (kể cả SayBeer) để thoát khóa; tắt khi phiên kết thúc. Đây là cách Opal làm "App Uninstall Protection".
- Lỗ hổng còn lại (Apple chưa cho bịt): vào Settings tắt quyền Screen Time của SayBeer. Opal cũng chịu; iOS 26.4+ có "Screen Time Passcode" khóa quyền ở mức hệ thống — dùng tay nếu cần. Với app tự kỷ luật cá nhân, mức này chấp nhận được.

### 4. Shortcuts Automation (kiểu one sec) — không ưu tiên
- one sec dùng automation "khi mở app X → chạy can thiệp hít thở"; ta đã có shield thật nên cơ chế này chỉ bổ trợ. Có thể hướng dẫn user tự tạo automation "khi mở Zalo → mở SayBeer" nếu muốn, không cần code.

### 5. Các hướng đã loại
- OCR/ReplayKit: chỉ quay, không chặn, tốn pin, user tắt được — loại.
- Ẩn danh bạ (Drunk Mode 2015): không chặn được chat đã mở, iOS cấm chặn cuộc gọi — loại.
- Chặn theo người nhận cụ thể: không API nào cho phép — loại.

## Roadmap đề xuất
1. **v1.1 — SayBeer Keyboard**: lọc wordlist VN + bắt chờ khi dính từ xấu trong beer mode; đọc trạng thái qua App Group không Full Access. (Việc chính: UI keyboard tiếng Việt đủ dùng — đây là phần tốn công nhất, vì phải gõ được telex/VNI tử tế hoặc chấp nhận keyboard chỉ dùng tạm trong cửa sổ nhắn việc.)
2. **v1.1 kèm theo**: bật `denyAppRemoval` trong phiên nhậu.
3. **v1.2 — Custom shield** giọng SayBeer.
4. **v2 — CoreML classifier** (ViHSD) nếu wordlist bắt sót/bắt nhầm nhiều.

**Điểm cần quyết trước khi làm v1.1**: bàn phím tiếng Việt tự viết khó đạt trải nghiệm bằng bàn phím hệ thống (telex, sửa dấu, autocomplete). Hai mức scope: (a) keyboard tối giản chỉ dùng trong 15 phút nhắn việc — rẻ, chấp nhận gõ xấu hơn; (b) keyboard đầy đủ telex dùng cả ngày — đắt hơn nhiều. Khuyến nghị bắt đầu (a).

## Nguồn
- Keyboard & Full Access: [Apple — Configuring Open Access](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard.md), [Apple forum — write fails without Full Access, read OK](https://developer.apple.com/forums/thread/668743), [OWASP MASTG-TEST-0390](https://mas.owasp.org/MASTG/tests/ios/MASVS-PLATFORM/MASTG-TEST-0390/), [Fleksy — iOS keyboard limitations](https://fleksy.com/blog/limitations-of-custom-keyboards-on-ios)
- Shield: [Apple forum — ShieldAction chỉ có none/defer/close](https://developer.apple.com/forums/thread/719905), [shield không ẩn sau custom button trên TestFlight](https://developer.apple.com/forums/thread/807934), [customize cover shield](https://developer.apple.com/forums/thread/717858), [bug DeviceActivity iOS 26](https://developer.apple.com/forums/thread/819997)
- Chống gỡ app: [Opal — App Uninstall Protection](https://help.opalapp.com/v3/what-is-app-uninstall-protection), [Opal community — không chặn được tắt quyền Screen Time](https://community.opal.so/t/how-do-we-prevent-turning-off-screen-time-access-solved/488/41)
- one sec: [App Store listing](https://apps.apple.com/de/app/one-sec-screen-time-focus/id1532875441?l=en-GB), [customize intervention](https://tutorials.one-sec.app/interventions), [prevent deleting automations](https://feedback.one-sec.app/help/articles/0762381)
- App cùng loại: [Drunk Mode Locker](https://apps.apple.com/mk/app/drunk-mode-locker/id6478125185), [Drunk Mode Keyboard](https://apps.apple.com/us/app/-/id1003788209), [tổng quan apps chống drunk-texting](https://iol.co.za/technology/2015-12-28-apps-against-drunk-texting/)
- NLP tiếng Việt: [MLTextClassifier](https://developer.apple.com/documentation/createml/mltextclassifier.md), [NLModel](https://developer.apple.com/documentation/naturallanguage/nlmodel.md), [vietnamese-offensive-words](https://github.com/blue-eyes-vn/vietnamese-offensive-words), [ViHSD](https://huggingface.co/datasets/sonlam1102/vihsd/blob/main/README.md), [ViHOS](https://huggingface.co/datasets/visolex/ViHOS/blob/main/README.md)
