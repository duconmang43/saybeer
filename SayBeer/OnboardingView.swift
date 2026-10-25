import SwiftUI
import FamilyControls

// 3 bước giới thiệu trước khi xin quyền Screen Time — tăng tỉ lệ cho phép.
struct OnboardingView: View {
    @EnvironmentObject var session: SessionStore
    @AppStorage("onboarded") private var onboarded = false
    @State private var page = 0
    @State private var requesting = false

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                pageView(
                    icon: "mug.fill", tint: .amber,
                    title: "SayBeer",
                    lines: [
                        String(localized: "Hãy say bia. Xin đừng “say” bậy."),
                        String(localized: "Khóa app nhắn tin trước khi đi, mở lại đúng giờ hẹn."),
                    ]
                ).tag(0)
                pageView(
                    icon: "lock.fill", tint: .amber,
                    title: String(localized: "Cách hoạt động"),
                    lines: [
                        String(localized: "Chọn app cần khóa, hẹn giờ mở — tới giờ tự gỡ."),
                        String(localized: "Cần nhắn việc? Mở tạm \(SessionStore.windowMinutes) phút, tối đa \(SessionStore.maxWindows) lần."),
                        String(localized: "Mở sớm phải gõ đúng câu líu lưỡi. Khẩn cấp thật thì giữ nút 5 giây."),
                    ]
                ).tag(1)
                pageView(
                    icon: "checkmark.shield.fill", tint: .green,
                    title: String(localized: "Quyền Screen Time"),
                    lines: [
                        String(localized: "SayBeer dùng Screen Time của Apple để khóa app bạn chọn."),
                        String(localized: "Không mạng, không tài khoản, không đọc tin nhắn hay dữ liệu — mọi thứ nằm trên máy."),
                    ]
                ).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                if page < 2 {
                    withAnimation { page += 1 }
                } else {
                    requesting = true
                    Task { await finish() }
                }
            } label: {
                Text(page < 2
                     ? String(localized: "Tiếp tục")
                     : (requesting ? String(localized: "Đang xin quyền…") : String(localized: "Cho phép Screen Time & bắt đầu")))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .disabled(requesting)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    private func pageView(icon: String, tint: Color, title: String, lines: [String]) -> some View {
        VStack(spacing: 18) {
            Spacer()
            ZStack {
                Circle().fill(tint.opacity(0.15)).frame(width: 110, height: 110)
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundStyle(tint)
            }
            Text(title)
                .font(.system(size: 30, weight: .heavy, design: .rounded))
            VStack(spacing: 10) {
                ForEach(lines, id: \.self) { line in
                    Text(line)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            Spacer()
            Spacer()
        }
    }

    private func finish() async {
        #if targetEnvironment(simulator)
        session.authorized = true
        #else
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            session.authorized = true
        } catch {
            session.authorized = false
        }
        #endif
        onboarded = true
    }
}
