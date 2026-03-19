import SwiftData

/// Factory for creating `ModelContainer` instances across all Thunder apps.
///
/// App targets never construct `ModelContainer` directly. All container
/// creation goes through this factory so that:
/// - The migration plan is always applied consistently
/// - The correct CloudKit container is used in production
/// - Tests always get a fresh, isolated in-memory store
///
/// ## Usage
///
/// **App entry point:**
/// ```swift
/// container = try ThunderContainer.production()
/// ```
///
/// **SwiftUI previews:**
/// ```swift
/// .modelContainer(try! ThunderContainer.preview())
/// ```
///
/// **Tests:**
/// ```swift
/// let context = try ThunderContainer.testing().mainContext
/// ```
public enum ThunderContainer {

    // MARK: - Production

    /// Creates the CloudKit-backed production `ModelContainer`.
    ///
    /// This container syncs through `ThunderConfiguration.cloudKitContainerIdentifier`
    /// and persists to disk. Pass it to the app entry point's `.modelContainer()` modifier.
    ///
    /// - Throws: If the container cannot be created or the migration fails.
    ///           A throw here is unrecoverable — the app cannot function without its store.
    public static func production() throws -> ModelContainer {
        let schema = Schema(SchemaV1.models, version: SchemaV1.versionIdentifier)
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private(ThunderConfiguration.cloudKitContainerIdentifier)
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: ThunderMigrationPlan.self,
            configurations: config
        )
    }

    // MARK: - Preview

    /// Creates an in-memory `ModelContainer` for SwiftUI previews.
    ///
    /// Not backed by CloudKit. Safe to call from `#Preview` blocks.
    /// May be pre-seeded with sample data by the caller.
    ///
    /// - Throws: If the container cannot be created.
    public static func preview() throws -> ModelContainer {
        let schema = Schema(SchemaV1.models, version: SchemaV1.versionIdentifier)
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: ThunderMigrationPlan.self,
            configurations: config
        )
    }

    // MARK: - Testing

    /// Creates a fresh, empty in-memory `ModelContainer` for tests.
    ///
    /// Each call returns an independent container with no shared state.
    /// No CloudKit involvement. Use `makeTestContext()` in test targets
    /// rather than calling this directly.
    ///
    /// - Throws: If the container cannot be created.
    public static func testing() throws -> ModelContainer {
        let schema = Schema(SchemaV1.models, version: SchemaV1.versionIdentifier)
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: ThunderMigrationPlan.self,
            configurations: config
        )
    }
}
