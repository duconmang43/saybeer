import ManagedSettings
import ManagedSettingsUI
import UIKit

// Màn chặn mang giọng SayBeer thay cho shield xám mặc định của iOS.
class SayBeerShield: ShieldConfigurationDataSource {
    private func config() -> ShieldConfiguration {
        let vi = Locale.preferredLanguages.first?.hasPrefix("vi") ?? true
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor(red: 0.10, green: 0.07, blue: 0.04, alpha: 1),
            icon: UIImage(systemName: "mug.fill"),
            title: .init(text: vi ? "SayBeer đang khóa" : "Locked by SayBeer", color: .white),
            subtitle: .init(
                text: vi
                    ? "Để mai nhắn. Việc gấp thật thì mở SayBeer → Cần nhắn việc."
                    : "Text tomorrow. Real emergency? Open SayBeer → work window.",
                color: UIColor(white: 0.82, alpha: 1)),
            primaryButtonLabel: .init(text: vi ? "OK, để mai" : "OK, tomorrow", color: .black),
            primaryButtonBackgroundColor: UIColor(red: 0.96, green: 0.65, blue: 0.14, alpha: 1)
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        config()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        config()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        config()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        config()
    }
}
