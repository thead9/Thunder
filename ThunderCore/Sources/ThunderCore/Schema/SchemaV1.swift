import SwiftData

/// The first versioned schema for the Thunder shared data layer.
///
/// Every `@Model` type in ThunderCore must be registered here.
/// `SchemaV1.models` is the single source of truth — if a model type
/// is not in this array, it does not exist as far as the schema is concerned.
///
/// When a new schema version is required, a `SchemaV2` is added alongside
/// this file and `ThunderMigrationPlan` is updated to describe the migration.
/// This file is never modified after it ships to production.
enum SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    /// All persistent model types in schema version 1.
    ///
    /// Order is alphabetical.
    static var models: [any PersistentModel.Type] {
        [
            Equipment.self,
            PlannedWorkout.self,
            TemplateEntry.self,
            Workout.self,
            WorkoutEntry.self,
            WorkoutTemplate.self,
        ]
    }
}
