import Testing
@testable import ThunderCore

@Suite("ThunderCore Package")
struct ThunderCoreTests {

    @Test("Package compiles and exports public symbols")
    func packageExportsVersion() {
        #expect(ThunderCore.version.isEmpty == false)
    }
}
