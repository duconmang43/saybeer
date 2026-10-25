import Foundation
import FamilyControls
import DeviceActivity

@MainActor
final class SessionStore: ObservableObject {
    @Published var authorized: Bool?
    @Published var selection: FamilyActivitySelection
    @Published var sessionEnd: Date?
    @Published var windowEnd: Date?
    @Published var windowsUsed: Int
    @Published var lockoutUntil: Date?
    // Bài kiểm tra tỉnh táo: gõ câu là bắt buộc, tính nhẩm bật/tắt được.
    @Published var mathInTest: Bool
    // Chặn xóa app trong phiên (tắt được).
    @Published var denyRemoval: Bool
    @Published var history: [SessionRecord]
    @Published var autoSchedule: AutoSchedule
    private var failCount: Int

    static let maxWindows = 3
    // 15 phút = độ dài tối thiểu một DeviceActivitySchedule cho phép.
    static let windowMinutes = 15

    private let center = DeviceActivityCenter()

    init() {
        let d = Shared.defaults
        selection = Shared.loadSelection()
        sessionEnd = d.object(forKey: Shared.Key.sessionEnd) as? Date
        windowEnd = d.object(forKey: Shared.Key.windowEnd) as? Date
        windowsUsed = d.integer(forKey: Shared.Key.windowsUsed)
        failCount = d.integer(forKey: Shared.Key.failCount)
        lockoutUntil = d.object(forKey: Shared.Key.lockoutUntil) as? Date
        mathInTest = (d.object(forKey: Shared.Key.mathInTest) as? Bool) ?? true
        denyRemoval = (d.object(forKey: Shared.Key.denyRemoval) as? Bool) ?? true
        history = Shared.loadHistory()
        autoSchedule = Shared.loadAutoSchedule()
        tick()
    }

    var isActive: Bool { (sessionEnd ?? .distantPast) > Date() }
    var isWindowOpen: Bool { (windowEnd ?? .distantPast) > Date() }
    var windowsLeft: Int { max(0, Self.maxWindows - windowsUsed) }
    var isLockedOut: Bool { (lockoutUntil ?? .distantPast) > Date() }

    var blockedCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
    }

    // MARK: - Thống kê
    var survivedCount: Int { history.filter(\.survived).count }
    var totalLockedHours: Double {
        history.reduce(0) { $0 + $1.actualEnd.timeIntervalSince($1.start) } / 3600
    }
    var currentStreak: Int {
        var n = 0
        for r in history.reversed() {
            if r.survived { n += 1 } else { break }
        }
        return n
    }

    func saveSelection() {
        Shared.saveSelection(selection)
    }

    func saveMathInTest() {
        Shared.defaults.set(mathInTest, forKey: Shared.Key.mathInTest)
    }

    func saveDenyRemoval() {
        Shared.defaults.set(denyRemoval, forKey: Shared.Key.denyRemoval)
    }

    // MARK: - Phiên tay
    func start(until end: Date) {
        Shared.saveSelection(selection)
        let d = Shared.defaults
        d.set(Date(), forKey: Shared.Key.sessionStart)
        d.set(end, forKey: Shared.Key.sessionEnd)
        d.set(0, forKey: Shared.Key.windowsUsed)
        d.set(0, forKey: Shared.Key.failCount)
        d.removeObject(forKey: Shared.Key.windowEnd)
        d.removeObject(forKey: Shared.Key.lockoutUntil)
        sessionEnd = end
        windowsUsed = 0
        windowEnd = nil
        failCount = 0
        lockoutUntil = nil
        Shared.applyShield(selection)
        schedule(name: .saybeerSession, until: end)
    }

    func endSession(reason: String) {
        let d = Shared.defaults
        center.stopMonitoring([.saybeerSession, .saybeerWindow])
        Shared.clearAll()
        if let start = d.object(forKey: Shared.Key.sessionStart) as? Date,
           let planned = sessionEnd {
            Shared.appendHistory(SessionRecord(
                start: start, plannedEnd: planned, actualEnd: Date(),
                endReason: reason, windowsUsed: windowsUsed))
            history = Shared.loadHistory()
        }
        d.removeObject(forKey: Shared.Key.sessionEnd)
        d.removeObject(forKey: Shared.Key.sessionStart)
        d.removeObject(forKey: Shared.Key.windowEnd)
        sessionEnd = nil
        windowEnd = nil
    }

    // Cửa sổ nhắn việc: gỡ shield tạm thời, extension sẽ khóa lại khi hết giờ.
    func openWorkWindow() {
        guard windowsLeft > 0, let end = sessionEnd else { return }
        let wEnd = min(Date().addingTimeInterval(TimeInterval(Self.windowMinutes * 60)), end)
        windowsUsed += 1
        windowEnd = wEnd
        let d = Shared.defaults
        d.set(windowsUsed, forKey: Shared.Key.windowsUsed)
        d.set(wEnd, forKey: Shared.Key.windowEnd)
        Shared.openShieldWindow()
        schedule(name: .saybeerWindow, until: wEnd)
    }

    func registerFail() {
        failCount += 1
        Shared.defaults.set(failCount, forKey: Shared.Key.failCount)
        if failCount >= 3 {
            failCount = 0
            Shared.defaults.set(0, forKey: Shared.Key.failCount)
            let until = Date().addingTimeInterval(5 * 60)
            lockoutUntil = until
            Shared.defaults.set(until, forKey: Shared.Key.lockoutUntil)
        }
    }

    // Lưới an toàn khi app active: đọc lại trạng thái từ app group
    // (lịch tự động có thể đã bật phiên khi app đang đóng) rồi đồng bộ shield.
    func tick() {
        let d = Shared.defaults
        sessionEnd = d.object(forKey: Shared.Key.sessionEnd) as? Date
        windowEnd = d.object(forKey: Shared.Key.windowEnd) as? Date
        windowsUsed = d.integer(forKey: Shared.Key.windowsUsed)
        history = Shared.loadHistory()

        let now = Date()
        if let lo = lockoutUntil, lo <= now {
            lockoutUntil = nil
            d.removeObject(forKey: Shared.Key.lockoutUntil)
        }
        guard let end = sessionEnd else { return }
        if end <= now {
            endSession(reason: "done")
            return
        }
        if let we = windowEnd, we <= now {
            windowEnd = nil
            d.removeObject(forKey: Shared.Key.windowEnd)
            Shared.applyShield(Shared.loadSelection())
        }
    }

    // MARK: - Lịch tự khóa hàng tuần
    func saveAutoSchedule(_ cfg: AutoSchedule) {
        autoSchedule = cfg
        Shared.saveAutoSchedule(cfg)
        Shared.saveSelection(selection)
        rescheduleAuto()
    }

    private func rescheduleAuto() {
        let names = (1...7).map { DeviceActivityName("saybeer.auto.\($0)") }
        center.stopMonitoring(names)
        let cfg = autoSchedule
        guard cfg.enabled, !cfg.weekdays.isEmpty, cfg.durationMinutes >= 15, blockedCount > 0 else { return }
        for wd in cfg.weekdays {
            let startTotal = cfg.startHour * 60 + cfg.startMinute
            let endTotal = (startTotal + cfg.durationMinutes) % 1440
            let crossesMidnight = startTotal + cfg.durationMinutes >= 1440
            let endWd = crossesMidnight ? wd % 7 + 1 : wd
            let schedule = DeviceActivitySchedule(
                intervalStart: DateComponents(hour: cfg.startHour, minute: cfg.startMinute, weekday: wd),
                intervalEnd: DateComponents(hour: endTotal / 60, minute: endTotal % 60, weekday: endWd),
                repeats: true
            )
            try? center.startMonitoring(DeviceActivityName("saybeer.auto.\(wd)"), during: schedule)
        }
    }

    private func schedule(name: DeviceActivityName, until end: Date) {
        let cal = Calendar.current
        let comps: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        let schedule = DeviceActivitySchedule(
            intervalStart: cal.dateComponents(comps, from: Date()),
            intervalEnd: cal.dateComponents(comps, from: end),
            repeats: false
        )
        try? center.startMonitoring(name, during: schedule)
    }
}
