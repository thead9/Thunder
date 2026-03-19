import Testing
import SwiftData
@testable import ThunderCore

@Suite("ThunderContainer")
struct ThunderContainerTests {

    // MARK: - preview()

    @Test("preview() creates a valid container without throwing")
    func previewContainerCreates() throws {
        let container = try ThunderContainer.preview()
        #expect(container.configurations.isEmpty == false)
    }

    @Test("preview() container is in-memory only")
    func previewContainerIsInMemory() throws {
        let container = try ThunderContainer.preview()
        let config = try #require(container.configurations.first)
        #expect(config.isStoredInMemoryOnly)
    }

    // MARK: - testing()

    @Test("testing() creates a valid container without throwing")
    func testingContainerCreates() throws {
        let container = try ThunderContainer.testing()
        #expect(container.configurations.isEmpty == false)
    }

    @Test("testing() container is in-memory only")
    func testingContainerIsInMemory() throws {
        let container = try ThunderContainer.testing()
        let config = try #require(container.configurations.first)
        #expect(config.isStoredInMemoryOnly)
    }

    @Test("testing() returns independent containers on each call")
    func testingContainersAreIndependent() throws {
        let container1 = try ThunderContainer.testing()
        let container2 = try ThunderContainer.testing()
        // Each call must produce a distinct container instance.
        // This test becomes more meaningful once models are registered —
        // an insert into container1's context must not appear in container2's.
        #expect(container1 !== container2)
    }

    // Note: production() is not unit tested here — it requires a live CloudKit
    // container and a signed-in iCloud account. It is validated on-device.
}
