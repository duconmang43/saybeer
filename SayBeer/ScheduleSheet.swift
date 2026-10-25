import SwiftUI
import FamilyControls

// Hẹn lịch tự khóa hàng tuần: tới giờ, máy tự khóa danh sách app đã chọn
// (DeviceActivitySchedule repeats — chạy cả khi không mở SayBeer).
struct ScheduleSheet: View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var enabled = false
    @State private var weekdays: Set<Int> = []
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var showPicker = false
    @State private var loaded = false

    // (nhãn, Calendar weekday: 1 = CN)
    private let days: [(String, Int)] = [
        ("T2", 2), ("T3", 3), ("T4", 4), ("T5", 5), ("T6", 6), ("T7", 7), ("CN", 1),
    ]

    private var durationMinutes: Int {
        let cal = Calendar.current
        let s = cal.component(.hour, from: startTime) * 60 + cal.component(.minute, from: startTime)
        let e = cal.component(.hour, from: endTime) * 60 + cal.component(.minute, from: endTime)
        return (e - s + 1440) % 1440
    }

    private var durationText: String {
        guard durationMinutes >= 15 else { return String(localized: "tối thiểu 15 phút") }
        return String(localized: "\(durationMinutes / 60)g\(String(format: "%02d", durationMinutes % 60))p")
    }

    private var durationColor: Color {
        durationMinutes >= 15 ? Color.secondary : Color.red
    }

    private var valid: Bool {
        !enabled || (!weekdays.isEmpty && durationMinutes >= 15 && session.blockedCount > 0)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Tự khóa theo lịch", isOn: $enabled)
                } footer: {
                    Text("Tới giờ hẹn, máy tự khóa danh sách app bên dưới — kể cả khi không mở SayBeer. Mở khóa sớm, cửa sổ nhắn việc và khẩn cấp hoạt động như phiên thường.")
                }
                if enabled {
                    Section("Ngày trong tuần") {
                        HStack(spacing: 6) {
                            ForEach(days, id: \.1) { label, wd in
                                dayChip(label: label, weekday: wd)
                            }
                        }
                    }
                    Section("Khung giờ") {
                        DatePicker("Bắt đầu khóa", selection: $startTime, displayedComponents: .hourAndMinute)
                        DatePicker("Mở khóa", selection: $endTime, displayedComponents: .hourAndMinute)
                        LabeledContent("Thời lượng") {
                            Text(durationText)
                                .foregroundStyle(durationColor)
                        }
                    }
                    Section("App bị khóa") {
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
                    }
                }
                Section {
                    Button {
                        save()
                    } label: {
                        Label("Lưu lịch", systemImage: "calendar.badge.checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!valid)
                }
            }
            .navigationTitle("Hẹn lịch")
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
            .onAppear { loadOnce() }
        }
    }

    private func dayChip(label: String, weekday: Int) -> some View {
        let on = weekdays.contains(weekday)
        let fill: Color = on ? Color.amber.opacity(0.3) : Color.gray.opacity(0.15)
        let fg: Color = on ? .amber : .secondary
        return Button {
            if on { weekdays.remove(weekday) } else { weekdays.insert(weekday) }
        } label: {
            Text(String(localized: String.LocalizationValue(label)))
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(RoundedRectangle(cornerRadius: 8).fill(fill))
                .foregroundStyle(fg)
        }
        .buttonStyle(.plain)
    }

    private func loadOnce() {
        guard !loaded else { return }
        loaded = true
        let cfg = session.autoSchedule
        enabled = cfg.enabled
        weekdays = cfg.weekdays
        let cal = Calendar.current
        startTime = cal.date(bySettingHour: cfg.startHour, minute: cfg.startMinute, second: 0, of: Date()) ?? Date()
        let endTotal = (cfg.startHour * 60 + cfg.startMinute + cfg.durationMinutes) % 1440
        endTime = cal.date(bySettingHour: endTotal / 60, minute: endTotal % 60, second: 0, of: Date()) ?? Date()
    }

    private func save() {
        let cal = Calendar.current
        var cfg = AutoSchedule()
        cfg.enabled = enabled
        cfg.weekdays = weekdays
        cfg.startHour = cal.component(.hour, from: startTime)
        cfg.startMinute = cal.component(.minute, from: startTime)
        cfg.durationMinutes = durationMinutes
        session.saveAutoSchedule(cfg)
        dismiss()
    }
}
