import Testing
@testable import ThunderCore

@Suite("ThunderConfiguration")
struct ThunderConfigurationTests {

    @Test("CloudKit container identifier is non-empty")
    func cloudKitContainerIdentifierNonEmpty() {
        #expect(ThunderConfiguration.cloudKitContainerIdentifier.isEmpty == false)
    }

    @Test("CloudKit container identifier has correct iCloud prefix")
    func cloudKitContainerIdentifierPrefix() {
        #expect(ThunderConfiguration.cloudKitContainerIdentifier.hasPrefix("iCloud."))
    }

    @Test("CloudKit container identifier matches provisioned container")
    func cloudKitContainerIdentifierValue() {
        // This test is intentionally explicit.
        // If the container identifier ever changes, this test fails loudly
        // so the change is a conscious, reviewed decision — not a typo.
        #expect(ThunderConfiguration.cloudKitContainerIdentifier == "iCloud.com.thead9.thunder")
    }
}
