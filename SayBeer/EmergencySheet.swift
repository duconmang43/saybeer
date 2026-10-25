import SwiftUI

// Mode khẩn cấp: mở khóa toàn bộ ngay, bỏ qua mọi kiểm tra.
// Rào cản duy nhất là giữ nút 5 giây — đủ chặn bấm nhầm, không cản việc khẩn thật.
struct EmergencySheet: View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var pressStart: Date?

    private static let holdSeconds: Double = 5

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "sos")
                    .font(.system(size: 56))
                    .foregroundStyle(.red)
                Text("Mở khóa khẩn cấp")
                    .font(.title2.bold())
                Text("Gỡ khóa toàn bộ app ngay lập tức, không kiểm tra, không giới hạn.\nChỉ dùng khi có việc khẩn thật sự — kết thúc luôn chế độ nhậu.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Spacer()

                TimelineView(.periodic(from: .now, by: 0.05)) { context in
                    let progress = pressStart.map {
                        min(1, context.date.timeIntervalSince($0) / Self.holdSeconds)
                    } ?? 0
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.red.opacity(0.25))
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red)
                                .frame(width: geo.size.width * progress)
                        }
                        Group {
                            if pressStart == nil {
                                Text("Giữ \(Int(Self.holdSeconds)) giây để mở khóa")
                            } else {
                                Text("Giữ tiếp… \(Int((Self.holdSeconds * (1 - progress)).rounded(.up)))s")
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                    }
                    .frame(height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .onLongPressGesture(minimumDuration: Self.holdSeconds, maximumDistance: 60) {
                    session.endSession(reason: "emergency")
                    dismiss()
                } onPressingChanged: { pressing in
                    pressStart = pressing ? Date() : nil
                }

                Text("Nhả tay là tính lại từ đầu.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Thôi, không khẩn") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
