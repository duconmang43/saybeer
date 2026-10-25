import SwiftUI
import FamilyControls

@main
struct SayBeerApp: App {
    @StateObject private var session = SessionStore()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("onboarded") private var onboarded = false

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(session)
                .preferredColorScheme(.dark)
                .tint(.amber)
                .task {
                    // Screen Time không hoạt động trên simulator — coi như đã cấp quyền để xem UI.
                    #if targetEnvironment(simulator)
                    session.authorized = true
                    #else
                    // Lần đầu: onboarding sẽ xin quyền. Các lần sau: xin lại nếu cần.
                    if AuthorizationCenter.shared.authorizationStatus == .approved {
                        session.authorized = true
                    } else if onboarded {
                        do {
                            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                            session.authorized = true
                        } catch {
                            session.authorized = false
                        }
                    }
                    #endif
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { session.tick() }
                }
        }
    }
}

extension ShapeStyle where Self == Color {
    static var amber: Color { Color(red: 0.96, green: 0.65, blue: 0.14) }
}
