import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

// Phần shield — chỉ compile vào app chính và monitor extension.
extension Shared {
    static func loadSelection() -> FamilyActivitySelection {
        guard let data = defaults.data(forKey: Key.selection),
              let sel = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return FamilyActivitySelection() }
        return sel
    }

    static func saveSelection(_ sel: FamilyActivitySelection) {
        if let data = try? JSONEncoder().encode(sel) {
            defaults.set(data, forKey: Key.selection)
        }
    }

    private static var store: ManagedSettingsStore { ManagedSettingsStore() }

    static func applyShield(_ sel: FamilyActivitySelection) {
        let s = store
        s.shield.applications = sel.applicationTokens.isEmpty ? nil : sel.applicationTokens
        s.shield.applicationCategories = sel.categoryTokens.isEmpty ? nil : .specific(sel.categoryTokens)
        s.shield.webDomains = sel.webDomainTokens.isEmpty ? nil : sel.webDomainTokens
        // Chặn xóa app trong phiên (tắt được trong màn bắt đầu phiên).
        let deny = (defaults.object(forKey: Key.denyRemoval) as? Bool) ?? true
        s.application.denyAppRemoval = deny ? true : nil
    }

    // Cửa sổ nhắn việc: gỡ shield tạm nhưng vẫn giữ chặn xóa app.
    static func openShieldWindow() {
        let s = store
        s.shield.applications = nil
        s.shield.applicationCategories = nil
        s.shield.webDomains = nil
    }

    static func clearAll() {
        store.clearAllSettings()
    }
}

extension DeviceActivityName {
    static let saybeerSession = Self("saybeer.session")
    static let saybeerWindow = Self("saybeer.window")
}
