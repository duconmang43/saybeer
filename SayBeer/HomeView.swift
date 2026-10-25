import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: SessionStore
    @AppStorage("onboarded") private var onboarded = false
    @State private var showStart = false
    @State private var showWorkWindow = false
    @State private var showSobrietyTest = false
    @State private var showEmergency = false
    @State private var showStats = false
    @State private var showSchedule = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.09, green: 0.07, blue: 0.04), Color(red: 0.16, green: 0.10, blue: 0.03)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            Group {
                if !onboarded {
                    OnboardingView()
                } else if session.authorized == false {
                    deniedView
                } else if session.isActive {
                    activeView
                } else {
                    idleView
                }
            }
            .padding(24)
        }
        .sheet(isPresented: $showStart) { StartSessionSheet() }
        .sheet(isPresented: $showWorkWindow) { WorkWindowSheet() }
        .sheet(isPresented: $showSobrietyTest) { SobrietyTestView() }
        .sheet(isPresented: $showEmergency) { EmergencySheet() }
        .sheet(isPresented: $showStats) { StatsSheet() }
        .sheet(isPresented: $showSchedule) { ScheduleSheet() }
    }

    private var idleView: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "mug.fill")
                .font(.system(size: 64))
                .foregroundStyle(.amber)
            Text("SayBeer")
                .font(.system(size: 38, weight: .heavy, design: .rounded))
            Text("Hãy say bia.\nXin đừng “say” bậy.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if !session.history.isEmpty {
                Button {
                    showStats = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: session.currentStreak >= 2 ? "flame.fill" : "checkmark.seal.fill")
                            .foregroundStyle(.amber)
                        Text("\(session.survivedCount) phiên an toàn · \(String(format: "%.0f", session.totalLockedHours)) giờ đã khóa")
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
                }
                .buttonStyle(.plain)
                .padding(.top, 6)
            }

            if session.autoSchedule.enabled {
                Label(autoScheduleSummary, systemImage: "calendar.badge.clock")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                showStart = true
            } label: {
                Text("Bắt đầu chế độ nhậu")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .disabled(session.authorized != true)

            HStack(spacing: 8) {
                smallButton("Hẹn lịch", icon: "calendar.badge.clock") { showSchedule = true }
                smallButton("Thống kê", icon: "chart.bar.fill") { showStats = true }
            }

            if session.authorized == nil {
                Text("Đang kiểm tra quyền Screen Time…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var autoScheduleSummary: String {
        let names: [Int: String] = [1: "CN", 2: "T2", 3: "T3", 4: "T4", 5: "T5", 6: "T6", 7: "T7"]
        let order = [2, 3, 4, 5, 6, 7, 1]
        let days = order.filter { session.autoSchedule.weekdays.contains($0) }
            .compactMap { names[$0].map { String(localized: String.LocalizationValue($0)) } }
            .joined(separator: ", ")
        let time = String(format: "%02d:%02d", session.autoSchedule.startHour, session.autoSchedule.startMinute)
        return String(localized: "Tự khóa \(days) lúc \(time)")
    }

    private func smallButton(_ title: LocalizedStringKey, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                Text(title).font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
    }

    private var activeView: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: session.isWindowOpen ? "briefcase.fill" : "lock.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.amber)
                Group {
                    if session.isWindowOpen {
                        Text("Cửa sổ nhắn việc đang mở")
                    } else {
                        Text("Đang khóa \(session.blockedCount) mục")
                    }
                }
                .font(.title2.bold())

                if session.isWindowOpen, let we = session.windowEnd {
                    Text("Khóa lại sau \(remaining(to: we, now: context.date))")
                        .font(.system(.largeTitle, design: .monospaced).bold())
                        .foregroundStyle(.amber)
                    Text("Nhắn việc xong thì thôi nhé. Không tâm sự.")
                        .foregroundStyle(.secondary)
                } else if let end = session.sessionEnd {
                    Text(remaining(to: end, now: context.date))
                        .font(.system(size: 56, design: .monospaced).bold())
                        .foregroundStyle(.amber)
                    Text("Tự mở khóa lúc \(end.formatted(date: .omitted, time: .shortened))")
                        .foregroundStyle(.secondary)
                    Text("Thông báo của app bị khóa vẫn hiện trên màn hình khóa — đọc thoải mái.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                if !session.isWindowOpen {
                    Button {
                        showWorkWindow = true
                    } label: {
                        Label("Cần nhắn việc — mở \(SessionStore.windowMinutes) phút (còn \(session.windowsLeft) lần)", systemImage: "briefcase")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .disabled(session.windowsLeft == 0)
                }

                Button {
                    showSobrietyTest = true
                } label: {
                    Text("Tỉnh rồi — mở khóa hẳn")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .foregroundStyle(.secondary)

                Button {
                    showEmergency = true
                } label: {
                    Label("Khẩn cấp", systemImage: "sos")
                        .font(.footnote)
                }
                .foregroundStyle(.red.opacity(0.8))
                .padding(.top, 4)
            }
        }
    }

    private var deniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.yellow)
            Text("Chưa có quyền Screen Time")
                .font(.title2.bold())
            Text("SayBeer cần quyền Screen Time để khóa app.\nVào Cài đặt → SayBeer để cấp quyền, hoặc mở lại app.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }

    private func remaining(to end: Date, now: Date) -> String {
        let s = max(0, Int(end.timeIntervalSince(now)))
        if s >= 3600 {
            return String(format: "%d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
        }
        return String(format: "%02d:%02d", s / 60, s % 60)
    }
}
