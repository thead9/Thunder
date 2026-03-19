import Testing
import SwiftData
@testable import ThunderCore

/// Tests for the `makeTestContext()` helper itself.
///
/// These tests verify the helper's contract: each call returns a fresh,
/// independent, in-memory context. The isolation guarantee is currently
/// demonstrated through container identity. Once models are registered
/// in `SchemaV1` (beginning with TRAIN-1), the full insert-based isolation
/// test should be added here to verify that data inserted in one context
/// does not appear when fetching from another.
@Suite("makeTestContext()")
struct TestHelpersTests {

    @Test("Returns a valid ModelContext without throwing")
    func returnsValidContext() throws {
        let context = try makeTestContext()
        // Verify the context has a container — if makeTestContext() returned
        // a context in an undefined state this would surface it.
        #expect(context.container.configurations.isEmpty == false)
    }

    @Test("Context is backed by an in-memory store")
    func contextIsInMemory() throws {
        let context = try makeTestContext()
        let config = try #require(context.container.configurations.first)
        #expect(config.isStoredInMemoryOnly)
    }

    @Test("Each call returns a context from an independent container")
    func contextsAreIndependent() throws {
        let context1 = try makeTestContext()
        let context2 = try makeTestContext()
        // Independent containers means data inserted via context1 cannot
        // appear when fetching via context2. Container identity is the
        // structural guarantee; insert-based verification is added in
        // TRAIN-1 once Workout is registered in SchemaV1.
        #expect(context1.container !== context2.container)
    }
}
