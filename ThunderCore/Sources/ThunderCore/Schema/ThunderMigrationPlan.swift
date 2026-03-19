import SwiftData

/// The migration plan for the Thunder shared data layer.
///
/// This plan is the authoritative sequence of schema versions.
/// It is passed to every `ModelContainer` created by `ThunderContainer`
/// and ensures that all stores — production, preview, and test — migrate
/// through the same path.
///
/// ## Adding a new schema version
///
/// 1. Create `SchemaV(n+1)` alongside the existing schema files.
/// 2. Add the new version to `schemas` in chronological order.
/// 3. Add a `MigrationStage` to `stages` describing the transition.
/// 4. Write a migration test before merging (QA requirement).
///
/// Lightweight migrations use `MigrationStage.lightweight`.
/// Migrations that require data transformation use `MigrationStage.custom`.
enum ThunderMigrationPlan: SchemaMigrationPlan {

    /// All schema versions in chronological order.
    /// The first element is the oldest version; the last is current.
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self]
    }

    /// Migration stages between consecutive schema versions.
    /// Empty until a second schema version is introduced.
    static var stages: [MigrationStage] {
        []
    }
}
