import Foundation

// Phần dùng chung tối thiểu cho app + monitor extension — chỉ Foundation.
enum Shared {
    static let appGroup = "group.com.jedix.saybeer"
    static var defaults: UserDefaults { UserDefaults(suiteName: appGroup) ?? .standard }

    enum Key {
        static let selection = "selection"
        static let sessionStart = "sessionStart"
        static let sessionEnd = "sessionEnd"
        static let windowEnd = "windowEnd"
        static let windowsUsed = "windowsUsed"
        static let failCount = "failCount"
        static let lockoutUntil = "lockoutUntil"
        static let mathInTest = "mathInTest"
        static let denyRemoval = "denyRemoval"
        static let history = "history"
        static let autoSchedule = "autoSchedule"
    }

    static var isBeerModeOn: Bool {
        (defaults.object(forKey: Key.sessionEnd) as? Date).map { $0 > Date() } ?? false
    }
}

// Một phiên nhậu đã kết thúc — nguồn cho thống kê.
struct SessionRecord: Codable, Identifiable {
    var id = UUID()
    var start: Date
    var plannedEnd: Date
    var actualEnd: Date
    var endReason: String // done | auto | test | emergency
    var windowsUsed: Int

    var survived: Bool { endReason == "done" || endReason == "auto" }
}

// Lịch tự khóa hàng tuần.
struct AutoSchedule: Codable, Equatable {
    var enabled = false
    var weekdays: Set<Int> = [] // Calendar weekday: 1 = CN … 7 = T7
    var startHour = 18
    var startMinute = 0
    var durationMinutes = 12 * 60
}

extension Shared {
    static func loadHistory() -> [SessionRecord] {
        guard let data = defaults.data(forKey: Key.history),
              let h = try? JSONDecoder().decode([SessionRecord].self, from: data) else { return [] }
        return h
    }

    static func appendHistory(_ record: SessionRecord) {
        var h = loadHistory()
        h.append(record)
        if h.count > 200 { h.removeFirst(h.count - 200) }
        if let data = try? JSONEncoder().encode(h) {
            defaults.set(data, forKey: Key.history)
        }
    }

    static func loadAutoSchedule() -> AutoSchedule {
        guard let data = defaults.data(forKey: Key.autoSchedule),
              let s = try? JSONDecoder().decode(AutoSchedule.self, from: data) else { return AutoSchedule() }
        return s
    }

    static func saveAutoSchedule(_ s: AutoSchedule) {
        if let data = try? JSONEncoder().encode(s) {
            defaults.set(data, forKey: Key.autoSchedule)
        }
    }
}
