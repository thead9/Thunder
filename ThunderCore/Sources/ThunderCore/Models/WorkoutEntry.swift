import Foundation
import SwiftData

/// A single logged effort within a workout session.
///
/// `WorkoutEntry` is the universal unit of workout detail. It replaces
/// separate `WorkoutSet` and `WorkoutInterval` models with a single composable
/// type. A workout is an ordered sequence of entries — each entry records what
/// actually happened during one discrete effort.
///
/// ## Composability
/// Any training modality is represented by the same model. A CrossFit workout
/// mixing barbell sets, rowing intervals, and box jumps is a flat sequence of
/// entries with mixed `entryType` values. Triathlon segments, circuit rounds,
/// and yoga poses all use the same model with different fields populated.
///
/// ## Field population
/// Fields are populated based on what was tracked — `nil` means "not recorded
/// for this effort," not "zero." Consumers must not assume a nil numeric field
/// is zero.
///
/// ## Grouping
/// `groupIndex` groups related entries in display. All entries with the same
/// `groupIndex` represent one logical exercise block (e.g. five sets of squat
/// share a `groupIndex`). `nil` means the entry stands alone.
///
/// ## Single source of truth
/// Session-level summaries (total distance, total volume, average HR) are
/// computed from entries at the call site — never stored. The only session-level
/// summary stored on `Workout` is `duration`, which captures total elapsed time
/// including warmup and transitions that entries do not cover.
///
/// ## Target fields
/// For structured sessions where a plan existed, both target and actual values
/// can be stored on the same entry. This enables per-effort comparison without
/// a separate template lookup.
///
/// ## CloudKit
/// All attributes are optional or carry declaration-site defaults.
@Model
public final class WorkoutEntry {
    public var id: UUID = UUID()
    public var entryIndex: Int = 0
    public var groupIndex: Int?
    public var exerciseName: String = ""
    public var entryType: WorkoutEntryType = WorkoutEntryType.set
    public var notes: String?

    // MARK: Actuals

    /// Repetitions completed.
    public var reps: Int?

    /// Load lifted, in kilograms.
    public var weightKg: Double?

    /// Distance covered, in metres.
    public var distanceMeters: Double?

    /// Active duration of this effort, in seconds.
    public var durationSeconds: Double?

    /// Rest taken after this effort, in seconds.
    public var restDurationSeconds: Double?

    /// Heart rate during this effort, in beats per minute.
    public var heartRateBPM: Double?

    /// Elevation gained during this effort, in metres.
    public var elevationMeters: Double?

    // MARK: Targets

    /// Target repetitions for this effort.
    public var targetReps: Int?

    /// Target load for this effort, in kilograms.
    public var targetWeightKg: Double?

    /// Target distance for this effort, in metres.
    public var targetDistanceMeters: Double?

    /// Target duration for this effort, in seconds.
    public var targetDurationSeconds: Double?

    public var createdAt: Date = Date.now

    /// The workout this entry belongs to.
    ///
    /// Delete rule is `.nullify` — the reference becomes `nil` rather than
    /// dangling if the parent is removed without triggering the cascade.
    /// The cascade that deletes entries when a workout is deleted is declared
    /// on `Workout.entries`.
    @Relationship(deleteRule: .nullify, inverse: \Workout.entries)
    public var workout: Workout?

    /// The equipment used for this effort, if any.
    ///
    /// Delete rule is `.nullify` — removing equipment does not remove the entry.
    @Relationship(deleteRule: .nullify, inverse: \Equipment.workoutEntries)
    public var equipment: Equipment?

    public init(
        id: UUID = UUID(),
        entryIndex: Int = 0,
        groupIndex: Int? = nil,
        exerciseName: String = "",
        entryType: WorkoutEntryType = .set,
        notes: String? = nil,
        reps: Int? = nil,
        weightKg: Double? = nil,
        distanceMeters: Double? = nil,
        durationSeconds: Double? = nil,
        restDurationSeconds: Double? = nil,
        heartRateBPM: Double? = nil,
        elevationMeters: Double? = nil,
        targetReps: Int? = nil,
        targetWeightKg: Double? = nil,
        targetDistanceMeters: Double? = nil,
        targetDurationSeconds: Double? = nil,
        createdAt: Date = .now,
        workout: Workout? = nil,
        equipment: Equipment? = nil
    ) {
        self.id = id
        self.entryIndex = entryIndex
        self.groupIndex = groupIndex
        self.exerciseName = exerciseName
        self.entryType = entryType
        self.notes = notes
        self.reps = reps
        self.weightKg = weightKg
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.restDurationSeconds = restDurationSeconds
        self.heartRateBPM = heartRateBPM
        self.elevationMeters = elevationMeters
        self.targetReps = targetReps
        self.targetWeightKg = targetWeightKg
        self.targetDistanceMeters = targetDistanceMeters
        self.targetDurationSeconds = targetDurationSeconds
        self.createdAt = createdAt
        self.workout = workout
        self.equipment = equipment
    }
}
