import SwiftUI

// Bài kiểm tra tỉnh táo để mở khóa hẳn trước giờ hẹn, trong 90 giây:
// gõ chính xác một câu líu lưỡi (bắt buộc) + tính nhẩm (bật/tắt trong cài đặt phiên).
// Sai 3 lần → khóa thêm 5 phút.
struct SobrietyTestView: View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    // Câu líu lưỡi theo ngôn ngữ app (gõ đúng tuyệt đối nên không qua String Catalog).
    private static var sentences: [String] {
        if (Bundle.main.preferredLocalizations.first ?? "vi").hasPrefix("vi") {
            return [
                "buổi trưa ăn bưởi chua đỡ say hơn hẳn",
                "nồi đồng nấu ốc nồi đất nấu ếch",
                "con lươn nó luồn qua lườn con lươn",
                "lúa nếp là lúa nếp làng lúa lên lớp lớp",
                "khi đi cưa ngọn khi về cũng cưa ngọn",
            ]
        }
        return [
            "she sells seashells by the seashore",
            "red lorry yellow lorry red leather yellow leather",
            "peter piper picked a peck of pickled peppers",
            "how much wood would a woodchuck chuck",
            "unique new york you know you need unique new york",
        ]
    }
    private static let totalSeconds: Double = 90

    @State private var sentence = Self.sentences.randomElement() ?? ""
    @State private var a = Int.random(in: 23...89)
    @State private var b = Int.random(in: 23...89)
    @State private var typed = ""
    @State private var answer = ""
    @State private var deadline = Date().addingTimeInterval(totalSeconds)
    @State private var failedAttempt = false

    private var sentenceOK: Bool { normalize(typed) == normalize(sentence) }
    private var answerOK: Bool { Int(answer.trimmingCharacters(in: .whitespaces)) == a + b }
    private var inputsFilled: Bool {
        !typed.isEmpty && (!session.mathInTest || !answer.isEmpty)
    }

    var body: some View {
        NavigationStack {
            Group {
                if session.isLockedOut, let until = session.lockoutUntil {
                    lockedOutView(until: until)
                } else {
                    testView
                }
            }
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Thôi, để khóa tiếp") { dismiss() }
                }
            }
        }
    }

    private var testView: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let left = max(0, Int(deadline.timeIntervalSince(context.date)))
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.amber.opacity(0.15))
                        .frame(width: 68, height: 68)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 30))
                        .foregroundStyle(.amber)
                }
                Text("Kiểm tra tỉnh táo")
                    .font(.title3.bold())

                timerBar(left: left)

                card {
                    Label("Gõ chính xác câu sau (đúng cả dấu)", systemImage: "character.cursor.ibeam")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("“\(sentence)”")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.amber)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack {
                        TextField("Gõ lại câu trên…", text: $typed)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        if !typed.isEmpty {
                            Image(systemName: sentenceOK ? "checkmark.circle.fill" : "circle.dotted")
                                .foregroundStyle(sentenceOK ? .green : .secondary)
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.18)))
                }

                if session.mathInTest {
                    card {
                        Label("Tính nhẩm", systemImage: "plus.forwardslash.minus")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 12) {
                            Text("\(a) + \(b) =")
                                .font(.title2.bold().monospacedDigit())
                            TextField("?", text: $answer)
                                .keyboardType(.numberPad)
                                .font(.title3.bold())
                                .multilineTextAlignment(.center)
                                .padding(10)
                                .frame(width: 96)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.18)))
                        }
                    }
                }

                if failedAttempt {
                    Label("Chưa đúng. Say thì đi ngủ đi.", systemImage: "xmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.12)))
                }

                Spacer(minLength: 0)

                Button {
                    submit(timeLeft: left)
                } label: {
                    Label("Mở khóa", systemImage: "lock.open.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.borderedProminent)
                .disabled(left == 0 || !inputsFilled)

                if left == 0 {
                    Text("Hết giờ — thử lại từ đầu.")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .onAppear { expire() }
                }
            }
        }
    }

    private func timerBar(left: Int) -> some View {
        HStack(spacing: 10) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2))
                    Capsule()
                        .fill(left <= 15 ? Color.red : Color.amber)
                        .frame(width: geo.size.width * CGFloat(left) / Self.totalSeconds)
                        .animation(.linear(duration: 1), value: left)
                }
            }
            .frame(height: 6)
            Text("\(left)s")
                .font(.subheadline.monospacedDigit().bold())
                .foregroundStyle(left <= 15 ? .red : .secondary)
                .frame(width: 42, alignment: .trailing)
        }
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.gray.opacity(0.1)))
    }

    private func lockedOutView(until: Date) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let left = max(0, Int(until.timeIntervalSince(context.date)))
            VStack(spacing: 16) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.indigo)
                Text("Sai 3 lần rồi")
                    .font(.title2.bold())
                Text("Nghỉ \(left / 60):\(String(format: "%02d", left % 60)) nữa rồi thử lại.\nHoặc cứ để khóa đến giờ hẹn cho lành.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func submit(timeLeft: Int) {
        let mathOK = !session.mathInTest || answerOK
        if timeLeft > 0 && sentenceOK && mathOK {
            session.endSession(reason: "test")
            dismiss()
        } else {
            session.registerFail()
            failedAttempt = true
            reset()
        }
    }

    private func expire() {
        session.registerFail()
        failedAttempt = true
        reset()
    }

    private func reset() {
        sentence = Self.sentences.randomElement() ?? ""
        a = Int.random(in: 23...89)
        b = Int.random(in: 23...89)
        typed = ""
        answer = ""
        deadline = Date().addingTimeInterval(Self.totalSeconds)
    }
}

private func normalize(_ s: String) -> String {
    s.precomposedStringWithCanonicalMapping
        .lowercased()
        .split(separator: " ")
        .joined(separator: " ")
}
