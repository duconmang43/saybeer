import SwiftUI

// Thống kê các phiên nhậu đã qua — lý do quay lại app.
struct StatsSheet: View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var shareImage: Image?

    var body: some View {
        NavigationStack {
            Group {
                if session.history.isEmpty {
                    emptyView
                } else {
                    listView
                }
            }
            .navigationTitle("Thống kê")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    if let img = shareImage {
                        ShareLink(
                            item: img,
                            preview: SharePreview(String(localized: "Thành tích SayBeer"), image: img)
                        ) {
                            Label("Khoe", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .onAppear { renderShareImage() }
        }
    }

    // Ảnh khoe thành tích 1080×1350 (tỉ lệ story) — mồi tăng trưởng chính.
    @MainActor private func renderShareImage() {
        guard !session.history.isEmpty else { return }
        let renderer = ImageRenderer(content: ShareCardView(
            survived: session.survivedCount,
            hours: session.totalLockedHours,
            streak: session.currentStreak
        ))
        renderer.scale = 2
        if let ui = renderer.uiImage {
            shareImage = Image(uiImage: ui)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("Chưa có phiên nào kết thúc.\nNhậu một trận là có số liệu ngay.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }

    private var listView: some View {
        List {
            Section {
                if let img = shareImage {
                    ShareLink(
                        item: img,
                        preview: SharePreview(String(localized: "Thành tích SayBeer"), image: img)
                    ) {
                        Label("Khoe thành tích với hội nhậu", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                }
                if session.currentStreak >= 2 {
                    Label("Chuỗi \(session.currentStreak) phiên an toàn liên tiếp", systemImage: "flame.fill")
                        .font(.headline)
                        .foregroundStyle(.amber)
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    tile(value: "\(session.survivedCount)", label: String(localized: "Phiên an toàn"), icon: "checkmark.seal.fill", tint: .green)
                    tile(value: String(format: String(localized: "%.0f giờ"), session.totalLockedHours), label: String(localized: "Tổng giờ khóa"), icon: "lock.fill", tint: .amber)
                    tile(value: "\(session.history.filter { $0.endReason == "test" }.count)", label: String(localized: "Mở bằng kiểm tra"), icon: "brain.head.profile", tint: .orange)
                    tile(value: "\(session.history.filter { $0.endReason == "emergency" }.count)", label: String(localized: "Khẩn cấp"), icon: "sos", tint: .red)
                }
                .padding(.vertical, 4)
            }
            Section("Các phiên gần đây") {
                ForEach(session.history.suffix(30).reversed()) { r in
                    row(r)
                }
            }
        }
    }

    private func tile(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(value)
                .font(.title3.bold().monospacedDigit())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.12)))
    }

    private func row(_ r: SessionRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(r.start.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                Text(duration(r) + (r.windowsUsed > 0 ? String(localized: " · \(r.windowsUsed) lần nhắn việc") : ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            badge(r.endReason)
        }
    }

    private func duration(_ r: SessionRecord) -> String {
        let mins = max(0, Int(r.actualEnd.timeIntervalSince(r.start)) / 60)
        if mins >= 60 {
            return String(localized: "\(mins / 60)g\(String(format: "%02d", mins % 60))p")
        }
        return String(localized: "\(mins) phút")
    }

    private func badge(_ reason: String) -> some View {
        let (text, color): (String, Color) = switch reason {
        case "done", "auto": (String(localized: "Trọn phiên"), .green)
        case "test": (String(localized: "Mở sớm"), .orange)
        default: (String(localized: "Khẩn cấp"), .red)
        }
        return Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Capsule().fill(color.opacity(0.18)))
            .foregroundStyle(color)
    }
}

// Thẻ ảnh chia sẻ — render offscreen bằng ImageRenderer, cỡ 540×675 @2x.
struct ShareCardView: View {
    let survived: Int
    let hours: Double
    let streak: Int

    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            Image(systemName: "mug.fill")
                .font(.system(size: 88))
                .foregroundStyle(Color(red: 0.96, green: 0.65, blue: 0.14))
            Text("SỐNG SÓT")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .tracking(8)
                .foregroundStyle(.white.opacity(0.75))
            Text("\(survived) trận nhậu")
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 0.96, green: 0.65, blue: 0.14))
            HStack(spacing: 28) {
                shareStat(String(format: String(localized: "%.0f giờ"), hours), String(localized: "đã khóa máy"))
                if streak >= 2 {
                    shareStat(String(localized: "chuỗi \(streak)"), String(localized: "trận an toàn"))
                }
            }
            Text("Hãy say bia.\nXin đừng “say” bậy.")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            Spacer()
            Text("saybeer.1labs.space")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(red: 0.96, green: 0.65, blue: 0.14))
                .padding(.bottom, 34)
        }
        .frame(width: 540, height: 675)
        .background(
            LinearGradient(
                colors: [Color(red: 0.14, green: 0.09, blue: 0.03), Color(red: 0.07, green: 0.05, blue: 0.03)],
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    private func shareStat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}
