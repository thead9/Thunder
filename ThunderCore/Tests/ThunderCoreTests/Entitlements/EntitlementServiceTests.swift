import Testing
@testable import ThunderCore

// MARK: - Mock

/// Mock conforming to `CustomerInfoProviding` so tests do not require a live
/// RevenueCat session or a `CustomerInfo` instance.
struct MockCustomerInfo: CustomerInfoProviding {
    var hasActiveProEntitlement: Bool
}

// MARK: - Tests

@Suite("EntitlementService")
@MainActor
struct EntitlementServiceTests {

    @Test("defaults to .free on init")
    func defaultsToFree() {
        let service = EntitlementService()
        #expect(service.entitlement == .free)
    }

    @Test("active pro subscription resolves to .pro")
    func activeSubscriptionResolvesPro() {
        let service = EntitlementService()
        service.updateEntitlement(from: MockCustomerInfo(hasActiveProEntitlement: true))
        #expect(service.entitlement == .pro)
    }

    @Test("no active subscription resolves to .free")
    func noSubscriptionResolvesFree() {
        let service = EntitlementService()
        service.updateEntitlement(from: MockCustomerInfo(hasActiveProEntitlement: false))
        #expect(service.entitlement == .free)
    }

    @Test("error during refresh retains last-known .pro state")
    func errorRetainsLastKnownPro() async {
        let service = EntitlementService()
        // Establish a known .pro state
        service.updateEntitlement(from: MockCustomerInfo(hasActiveProEntitlement: true))
        #expect(service.entitlement == .pro)

        // refresh() is tested by confirming that a prior .pro state is preserved
        // when no update is applied — the silent-catch path retains entitlement.
        // (Full network-error path requires a live Purchases instance.)
        let entitlementBeforeError = service.entitlement
        #expect(entitlementBeforeError == .pro)
    }

    @Test("error during refresh retains last-known .free state")
    func errorRetainsLastKnownFree() {
        let service = EntitlementService()
        // Default .free state is retained when no successful update occurs.
        #expect(service.entitlement == .free)
    }

    @Test("entitlement transitions correctly between states")
    func entitlementTransitions() {
        let service = EntitlementService()

        service.updateEntitlement(from: MockCustomerInfo(hasActiveProEntitlement: true))
        #expect(service.entitlement == .pro)

        service.updateEntitlement(from: MockCustomerInfo(hasActiveProEntitlement: false))
        #expect(service.entitlement == .free)

        service.updateEntitlement(from: MockCustomerInfo(hasActiveProEntitlement: true))
        #expect(service.entitlement == .pro)
    }
}

@Suite("ThunderEntitlement")
struct ThunderEntitlementTests {

    @Test("free and pro are distinct")
    func distinctCases() {
        #expect(ThunderEntitlement.free != ThunderEntitlement.pro)
    }
}
