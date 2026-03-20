import Foundation
import SwiftData

/// A single logged workout session.
///
/// `Workout` is the core log entry in the Training domain. It is the most-written
/// and most-queried model in the suite. Every field is either optional or carries
/// a default value at the declaration site to satisfy CloudKit's requirement that
/// no non-optional attribute lacks a default on first sync.
///
/// ## HealthKit correlation
/// `healthKitID` stores the `UUID` of a matching `HKWorkout` when one exists.
/// The HealthKit service (BIZ-2) populates this field; the model itself has no
/// HealthKit dependency.
///
/// ## Relationships
/// `WorkoutSet` and `PlannedWorkout` hold the inverse relationships to `Workout`.
/// Delete rules on those relationships are declared in their respective model files
/// (TRAIN-2, TRAIN-4). Any `@Relationship` on this model that owns child objects
/// must declare an explicit delete rule — never rely on the default.
@Model
public final class Workout {
    public var id: UUID = UUID()
    public var date: Date = Date.now
    public var duration: TimeInterval?
    public var activityType: String = ""
    public var notes: String?
    public var source: WorkoutSource = WorkoutSource.manual

    /// The sets logged within this workout, in no guaranteed order.
    ///
    /// Sort by `setIndex` when displaying. Delete rule is `.cascade` — all
    /// associated `WorkoutSet` records are deleted when this workout is deleted.
    /// Declared as `[WorkoutSet]?` per CloudKit's requirement that all relationships
    /// be optional. Use `sets ?? []` when an empty array is needed.
    @Relationship(deleteRule: .cascade)
    public var sets: [WorkoutSet]?

    /// Plans that were completed as this workout, if any.
    ///
    /// Delete rule is `.nullify` — plans survive if the workout log is deleted.
    @Relationship(deleteRule: .nullify)
    public var plannedWorkouts: [PlannedWorkout]?

    // MARK: - SchemaV2 additions

    /// Total distance logged for this workout, in meters.
    ///
    /// Populated for cardio workouts. `nil` for strength-only sessions.
    public var distanceMeters: Double?

    /// Elevation gain for this workout, in meters.
    public var elevationGainMeters: Double?

    /// Average heart rate across the session, in beats per minute.
    public var averageHeartRateBPM: Double?

    /// Peak heart rate recorded during the session, in beats per minute.
    public var maxHeartRateBPM: Double?

    /// The template this workout was started from, if any.
    ///
    /// Set once on save when a workout is initiated via VIEW-6 (Log from Template).
    /// `nil` for all other workouts. Delete rule is `.nullify` — the template
    /// survives if the workout log is deleted.
    @Relationship(deleteRule: .nullify, inverse: \WorkoutTemplate.workouts)
    public var template: WorkoutTemplate?

    /// The structured cardio intervals logged within this workout.
    ///
    /// Sort by `intervalIndex` when displaying. Delete rule is `.cascade` —
    /// all associated `WorkoutInterval` records are deleted when this workout
    /// is deleted. Use `intervals ?? []` at call sites.
    @Relationship(deleteRule: .cascade)
    public var intervals: [WorkoutInterval]?

    /// The UUID of the correlated `HKWorkout`, if one exists.
    ///
    /// Populated by the HealthKit service (BIZ-2). `nil` for manually entered workouts
    /// until a correlation is established.
    public var healthKitID: UUID?
    public var createdAt: Date = Date.now
    public var modifiedAt: Date = Date.now

    public init(
        id: UUID = UUID(),
        date: Date = .now,
        duration: TimeInterval? = nil,
        activityType: String = "",
        notes: String? = nil,
        source: WorkoutSource = .manual,
        healthKitID: UUID? = nil,
        createdAt: Date = .now,
        modifiedAt: Date = .now
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.activityType = activityType
        self.notes = notes
        self.source = source
        self.healthKitID = healthKitID
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
