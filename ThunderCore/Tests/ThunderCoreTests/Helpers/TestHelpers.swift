import SwiftData
import ThunderCore

/// Creates a fresh, isolated in-memory `ModelContext` for use in tests.
///
/// Every test that needs a `ModelContext` calls this function rather than
/// constructing a `ModelContainer` directly. This ensures:
/// - All tests use the same container configuration (`ThunderContainer.testing()`)
/// - No test accidentally touches a persistent store or CloudKit
/// - Each call produces an independent context with no shared state
///
/// ## Usage
///
/// ```swift
/// @Test("My model test")
/// func myModelTest() throws {
///     let context = try makeTestContext()
///     // insert, fetch, assert
/// }
/// ```
///
/// - Throws: If `ThunderContainer.testing()` fails to create the container.
///           This should never happen in practice — a throw here indicates
///           a broken schema definition that must be fixed before tests can run.
func makeTestContext() throws -> ModelContext {
    // ModelContext(container:) creates a new independent context.
    // Intentionally NOT using container.mainContext — that is a shared,
    // @MainActor-isolated property. Creating a fresh ModelContext here
    // keeps tests nonisolated and guarantees each call is truly independent.
    let container = try ThunderContainer.testing()
    return ModelContext(container)
}
