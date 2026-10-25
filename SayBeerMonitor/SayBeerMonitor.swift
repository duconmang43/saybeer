import Foundation
import DeviceActivity
import ManagedSettings

// Chạy nền theo DeviceActivitySchedule:
// - phiên tay: gỡ khóa khi hết giờ, khóa lại khi hết cửa sổ nhắn việc;
// - lịch tự động (saybeer.auto.<weekday>): tự bật khóa đúng giờ hẹn hàng tuần.
class SayBeerMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        guard activity.rawValue.hasPrefix("saybeer.auto.") else { return }
        let d = Shared.defaults
        // Phiên tay đang chạy thì không đè.
        if let end = d.object(forKey: Shared.Key.sessionEnd) as? Date, end > Date() { return }
        let cfg = Shared.loadAutoSchedule()
        guard cfg.enabled, cfg.durationMinutes >= 15 else { return }
        d.set(Date(), forKey: Shared.Key.sessionStart)
        d.set(Date().addingTimeInterval(TimeInterval(cfg.durationMinutes * 60)), forKey: Shared.Key.sessionEnd)
        d.set(0, forKey: Shared.Key.windowsUsed)
        d.removeObject(forKey: Shared.Key.windowEnd)
        Shared.applyShield(Shared.loadSelection())
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        switch activity {
        case .saybeerSession:
            finishSession(reason: "done")
        case .saybeerWindow:
            Shared.defaults.removeObject(forKey: Shared.Key.windowEnd)
            if let end = Shared.defaults.object(forKey: Shared.Key.sessionEnd) as? Date, end > Date() {
                Shared.applyShield(Shared.loadSelection())
            }
        default:
            if activity.rawValue.hasPrefix("saybeer.auto.") {
                finishSession(reason: "auto")
            }
        }
    }

    private func finishSession(reason: String) {
        let d = Shared.defaults
        // Chỉ kết thúc phiên đã tới hạn — không giết phiên tay còn hiệu lực.
        guard let end = d.object(forKey: Shared.Key.sessionEnd) as? Date,
              end <= Date().addingTimeInterval(120) else { return }
        if let start = d.object(forKey: Shared.Key.sessionStart) as? Date {
            Shared.appendHistory(SessionRecord(
                start: start, plannedEnd: end, actualEnd: Date(),
                endReason: reason, windowsUsed: d.integer(forKey: Shared.Key.windowsUsed)))
        }
        Shared.clearAll()
        d.removeObject(forKey: Shared.Key.sessionEnd)
        d.removeObject(forKey: Shared.Key.sessionStart)
        d.removeObject(forKey: Shared.Key.windowEnd)
    }
}
