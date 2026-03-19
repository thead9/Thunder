import SwiftUI
import ThunderCore
import RevenueCat

@main
struct TrainingApp: App {

    init() {
        Self.configureRevenueCat()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
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
            // This means Secrets.xcconfig is missing or REVENUECAT_API_KEY is unset.
            // Copy Secrets.xcconfig.template → Secrets.xcconfig and rebuild.
            assertionFailure("RevenueCat API key not found. See Secrets.xcconfig.template.")
            return
        }
        Purchases.configure(withAPIKey: apiKey)
    }
}
