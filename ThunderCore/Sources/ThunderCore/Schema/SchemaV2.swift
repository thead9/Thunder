import SwiftData

/// The second versioned schema for the Thunder shared data layer.
///
/// SchemaV2 extends SchemaV1 with:
/// - `CardioComponent` — cardio-specific detail (distance, elevation, heart rate,
///   structured intervals) attached optionally to a `Workout` via the component
///   pattern; keeps `Workout` general across all training modalities
/// - A `template` relationship on `Workout` linking logs to their source template
/// - `WorkoutInterval` — per-interval detail owned by `CardioComponent`
/// - `Equipment` — first-class model for equipment tracking across sets and intervals,
///   with `EquipmentCategory` enum replacing the previous free-text category field
/// - `equipment` optional relationships on `WorkoutSet` and `TemplateSet`
/// - `workouts` inverse relationship on `WorkoutTemplate`
///
/// All new attributes are optional or carry defaults, satisfying CloudKit's
/// requirement that every attribute have a value on first sync.
///
/// ## Migration
/// The v1→v2 migration is lightweight: all changes are additive (new optional
/// attributes and new model types). No data transformation is required.
///
/// ## Immutability
/// Like SchemaV1, this file must not be modified after it ships to production.
/// All future changes belong in SchemaV3+.
enum SchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

    /// All persistent model types in schema version 2.
    ///
    /// Includes all SchemaV1 types plus the two new models introduced in V2.
    /// Order is alphabetical.
    static var models: [any PersistentModel.Type] {
        [
            CardioComponent.self,
            Equipment.self,
            PlannedWorkout.self,
            TemplateSet.self,
            Workout.self,
            WorkoutInterval.self,
            WorkoutSet.self,
            WorkoutTemplate.self,
        ]
    }
}
