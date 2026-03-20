import Foundation
import SwiftData

/// A single logged effort within a workout session.
///
/// `WorkoutEntry` is the universal unit of workout detail. A workout is an
/// ordered sequence of entries — each entry records what actually happened
/// during one discrete effort.
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
/// computed from entries at the call site via `Workout+Computed` — never stored.
/// The only session-level summary stored on `Workout` is `duration`, which
/// captures total elapsed time including warmup and transitions that entries
/// do not cover.
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

    /// Target rest duration after this effort, in seconds.
    ///
    /// Mirrors `TemplateEntry.targetRestDurationSeconds` — stored here so that
    /// when a structured workout is started from a template the prescribed rest
    /// period is available for per-effort target/actual comparison.
    public var targetRestDurationSeconds: Double?

    public var createdAt: Date = Date.now

    /// The exercise performed during this effort, if any.
    ///
    /// `nil` for efforts with no discrete exercise (e.g. a rest period or
    /// unstructured time-based effort). Delete rule is `.nullify` — removing an
    /// exercise record does not remove the entries that used it.
    @Relationship(deleteRule: .nullify, inverse: \Exercise.workoutEntries)
    public var exercise: Exercise?

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
        targetRestDurationSeconds: Double? = nil,
        createdAt: Date = .now,
        exercise: Exercise? = nil,
        workout: Workout? = nil,
        equipment: Equipment? = nil
    ) {
        self.id = id
        self.entryIndex = entryIndex
        self.groupIndex = groupIndex
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
        self.targetRestDurationSeconds = targetRestDurationSeconds
        self.createdAt = createdAt
        self.exercise = exercise
        self.workout = workout
        self.equipment = equipment
    }
}
