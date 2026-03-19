import SwiftUI
import SwiftData
import ThunderCore
import RevenueCat

@main
struct TrainingApp: App {

    private let container: ModelContainer

    init() {
        Self.configureRevenueCat()
        // ModelContainer creation failing is unrecoverable — the app cannot
        // function without its data store. A throw here indicates schema
        // corruption or a migration failure that must be resolved before launch.
        do {
            container = try ThunderContainer.production()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}

// MARK: - RevenueCat

private extension TrainingApp {

    /// Configures the RevenueCat SDK using the API key embedded in the bundle
    /// at build time from Secrets.xcconfig.
    ///
    /// This is the only place RevenueCat is initialised. All subsequent
    /// interaction with RevenueCat goes through `EntitlementService`.
    static func configureRevenueCat() {
        guard let apiKey = Bundle.main.infoDictionary?["RevenueCatAPIKey"] as? String,
              !apiKey.isEmpty else {
            assertionFailure("RevenueCat API key not found. See Secrets.xcconfig.template.")
            return
        }
        Purchases.configure(withAPIKey: apiKey)
    }
}
