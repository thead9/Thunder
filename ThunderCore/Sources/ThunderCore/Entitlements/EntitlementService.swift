import Observation
import RevenueCat

/// The single source of truth for subscription entitlement state across all Thunder apps.
///
/// No view, model, or service other than `EntitlementService` interacts with RevenueCat
/// directly. All entitlement state flows through this service and is observed via
/// SwiftUI's `@Environment`.
///
/// ## Setup
///
/// Call `EntitlementService.configure(apiKey:)` once at app startup before instantiating
/// the service. The recommended startup order is:
///
/// 1. Set up the SwiftData container (`ThunderContainer.production()`)
/// 2. Call `EntitlementService.configure(apiKey:)`
/// 3. Instantiate `EntitlementService` and inject via `.environment(entitlementService)`
///
/// ## Fallback behaviour
///
/// On network failure or RevenueCat error, the service retains the last-known entitlement
/// state rather than downgrading the user. A user who was `.pro` before a network failure
/// remains `.pro` until a successful refresh confirms otherwise.
@Observable
@MainActor
public final class EntitlementService {

    /// The RevenueCat entitlement identifier for the pro subscription.
    // Exposed as internal so CustomerInfo extension and tests can reference it.
    // Declared on the type for namespacing — value is a nonisolated constant.
    nonisolated static let proEntitlementID = "pro"

    /// The current entitlement tier. Observed reactively by SwiftUI views.
    public private(set) var entitlement: ThunderEntitlement = .free

    public init() {}

    // MARK: - Configuration

    /// Configures the RevenueCat SDK. Call once at app startup before instantiating
    /// `EntitlementService`.
    ///
    /// - Parameter apiKey: The RevenueCat API key from `ThunderConfiguration`.
    public static func configure(apiKey: String) {
        let config = Configuration.Builder(withAPIKey: apiKey)
            .with(diagnosticsEnabled: false)
            .build()
        Purchases.configure(with: config)
    }

    // MARK: - Purchase flow

    /// Purchases a RevenueCat `Package` and updates entitlement state on success.
    ///
    /// - Throws: A RevenueCat `ErrorCode` on failure. The entitlement state is not
    ///   changed if the purchase fails or is cancelled.
    public func purchase(_ package: Package) async throws {
        let result = try await Purchases.shared.purchase(package: package)
        updateEntitlement(from: result.customerInfo as any CustomerInfoProviding)
    }

    /// Restores previous purchases and updates entitlement state.
    ///
    /// - Throws: A RevenueCat `ErrorCode` on failure. The entitlement state is not
    ///   changed if restoration fails.
    public func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        updateEntitlement(from: customerInfo as any CustomerInfoProviding)
    }

    /// Refreshes entitlement state from RevenueCat. On error, retains last-known state.
    public func refresh() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            updateEntitlement(from: customerInfo as any CustomerInfoProviding)
        } catch {
            // Intentionally silent — retain last-known entitlement rather than
            // locking out a user due to a transient network failure.
        }
    }

    // MARK: - Internal

    /// Updates `entitlement` based on the active entitlements in `info`.
    ///
    /// Accepts `CustomerInfoProviding` so tests can pass a mock without instantiating
    /// RevenueCat's `CustomerInfo` directly.
    func updateEntitlement(from info: any CustomerInfoProviding) {
        entitlement = info.hasActiveProEntitlement ? .pro : .free
    }
}

// MARK: - CustomerInfoProviding

/// Internal protocol abstracting the entitlement query on RevenueCat's `CustomerInfo`.
///
/// Allows `EntitlementService` to be tested without a live RevenueCat session.
/// Not part of the public API — consumers use `EntitlementService` directly.
protocol CustomerInfoProviding: Sendable {
    var hasActiveProEntitlement: Bool { get }
}

extension CustomerInfo: CustomerInfoProviding {
    var hasActiveProEntitlement: Bool {
        entitlements[EntitlementService.proEntitlementID]?.isActive == true
    }
}
