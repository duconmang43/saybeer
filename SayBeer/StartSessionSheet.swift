import SwiftUI
import FamilyControls

struct StartSessionSheet: View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss
    @State private var showPicker = false
    @State private var mode: EndMode = .morning6
    @State private var customEnd = Date().addingTimeInterval(6 * 3600)

    // FamilyActivityPicker không chọn được app trên simulator — cho bắt đầu phiên không cần chọn.
    #if targetEnvironment(simulator)
    private let requireSelection = false
    #else
    private let requireSelection = true
    #endif

    enum EndMode: String, CaseIterable, Identifiable {
        case morning6 = "6h sáng"
        case plus4 = "+4 giờ"
        case plus8 = "+8 giờ"
        case custom = "Tùy chọn"
        var id: String { rawValue }
        var label: String { String(localized: String.LocalizationValue(rawValue)) }
    }

    private var endDate: Date {
        switch mode {
        case .morning6:
            return Calendar.current.nextDate(
                after: Date(),
                matching: DateComponents(hour: 6, minute: 0),
                matchingPolicy: .nextTime
            ) ?? Date().addingTimeInterval(8 * 3600)
        case .plus4: return Date().addingTimeInterval(4 * 3600)
        case .plus8: return Date().addingTimeInterval(8 * 3600)
        case .custom: return customEnd
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        showPicker = true
                    } label: {
                        HStack {
                            Label("Chọn app / nhóm app", systemImage: "apps.iphone")
                            Spacer()
                            Group {
                                if session.blockedCount == 0 {
                                    Text("Chưa chọn")
                                } else {
                                    Text("\(session.blockedCount) mục")
                                }
                            }
                            .foregroundStyle(session.blockedCount == 0 ? .red : .secondary)
                        }
                    }
                } header: {
                    Text("App cần khóa")
                } footer: {
                    #if targetEnvironment(simulator)
                    Text("Simulator không chọn được app (giới hạn iOS). Cứ bấm Khóa ngay để xem flow — trên iPhone thật chọn bình thường.")
                    #endif
                }
                Section("Khóa đến") {
                    Picker("Khóa đến", selection: $mode) {
                        ForEach(EndMode.allCases) { m in
                            Text(m.label).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    if mode == .custom {
                        DatePicker("Giờ mở khóa", selection: $customEnd, in: Date().addingTimeInterval(30 * 60)...)
                    }
                    LabeledContent("Mở khóa lúc") {
                        Text(endDate.formatted(date: .abbreviated, time: .shortened))
                    }
                }
                Section {
                    Toggle("Kèm tính nhẩm", isOn: $session.mathInTest)
                        .onChange(of: session.mathInTest) { _, _ in
                            session.saveMathInTest()
                        }
                    Toggle("Chặn xóa app trong phiên", isOn: $session.denyRemoval)
                        .onChange(of: session.denyRemoval) { _, _ in
                            session.saveDenyRemoval()
                        }
                } header: {
                    Text("Tùy chọn phiên")
                } footer: {
                    Text("Gõ chính xác câu líu lưỡi luôn là bắt buộc khi mở khóa sớm; tắt \"Kèm tính nhẩm\" nếu muốn bài kiểm tra chỉ gồm gõ câu. \"Chặn xóa app\" ngăn xóa mọi app (kể cả SayBeer) trong lúc khóa để khỏi né.")
                }
                Section {
                    Button {
                        session.start(until: endDate)
                        dismiss()
                    } label: {
                        Label("Khóa ngay", systemImage: "lock.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled((requireSelection && session.blockedCount == 0) || endDate <= Date().addingTimeInterval(60))
                } footer: {
                    Text("Trong lúc khóa vẫn mở tạm được \(SessionStore.windowMinutes) phút để nhắn việc, tối đa \(SessionStore.maxWindows) lần.")
                }
            }
            .navigationTitle("Chế độ nhậu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
            }
            .familyActivityPicker(isPresented: $showPicker, selection: $session.selection)
            .onChange(of: session.selection) { _, _ in
                session.saveSelection()
            }
        }
    }
}
