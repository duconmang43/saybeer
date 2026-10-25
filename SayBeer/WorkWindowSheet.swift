import SwiftUI

// Cam kết nhẹ trước khi mở cửa sổ nhắn việc: gõ đúng câu + chờ 15 giây.
// Đủ cản hành vi bốc đồng nhưng không chặn việc gấp.
struct WorkWindowSheet: View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var typed = ""
    @State private var secondsLeft = 15

    private let commitment = String(localized: "chỉ nhắn việc, không tâm sự")

    private var matched: Bool {
        normalize(typed) == normalize(commitment)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.amber)
                Text("Mở \(SessionStore.windowMinutes) phút để nhắn việc")
                    .font(.title3.bold())
                Text("Gõ đúng câu dưới đây để cam kết:")
                    .foregroundStyle(.secondary)
                Text("“\(commitment)”")
                    .font(.headline)
                    .foregroundStyle(.amber)

                TextField("Gõ lại câu trên…", text: $typed)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                if matched {
                    TimelineView(.periodic(from: .now, by: 1)) { _ in
                        Button {
                            session.openWorkWindow()
                            dismiss()
                        } label: {
                            Group {
                                if secondsLeft > 0 {
                                    Text("Hít thở đã… \(secondsLeft)s")
                                } else {
                                    Text("Mở cửa sổ nhắn việc")
                                }
                            }
                            .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(secondsLeft > 0)
                        .onAppear {}
                        .task(id: secondsLeft) {
                            guard secondsLeft > 0 else { return }
                            try? await Task.sleep(for: .seconds(1))
                            secondsLeft -= 1
                        }
                    }
                }

                Spacer()
                Text("Còn \(session.windowsLeft) lần mở trong cuộc nhậu này")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Thôi") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func normalize(_ s: String) -> String {
        s.precomposedStringWithCanonicalMapping
            .lowercased()
            .replacingOccurrences(of: ",", with: "")
            .split(separator: " ")
            .joined(separator: " ")
    }
}
