import Foundation
import SwiftData

/// A single logged workout session.
///
/// `Workout` is the top-level log entry. It captures session-level facts that
/// cannot be derived from its entries: when the session happened, how long the
/// total elapsed time was (including warmup and transitions), what kind of
/// activity it was, and where the data came from.
///
/// ## Entries
/// All per-effort detail lives in `WorkoutEntry`. A `Workout` with no entries
/// is valid — logging "ran 5k" with just a duration and activity type is a
/// complete record. Structured detail (sets, intervals, pace data) is opt-in
/// via entries.
///
/// ## Single source of truth
/// Session summaries — total distance, total volume, average HR — are computed
/// from entries at the call site. `duration` is the only stored summary because
/// it captures elapsed time including rest and transitions that entries do not.
///
/// ## Template link
/// `template` is set once when a workout is started from a template (VIEW-6).
/// It is the explicit, queryable link between a log entry and the template it
/// came from. String-based matching is not a substitute.
///
/// ## HealthKit
/// `healthKitID` stores the UUID of a matching `HKWorkout`. The HealthKit
/// service populates this field; the model has no HealthKit dependency.
@Model
public final class Workout {
    public var id: UUID = UUID()
    public var date: Date = Date.now

    /// Total elapsed session time in seconds, including warmup and transitions.
    ///
    /// This is NOT the sum of entry durations — it is the real-world clock from
    /// session start to end. Use entry durations for per-effort analytics.
    public var duration: TimeInterval?
    public var activityType: String = ""
    public var notes: String?
    public var source: WorkoutSource = WorkoutSource.manual
    public var healthKitID: UUID?
    public var createdAt: Date = Date.now
    public var modifiedAt: Date = Date.now

    /// All efforts logged within this session, in no guaranteed order.
    ///
    /// Sort by `entryIndex` when displaying. Group by `groupIndex` to cluster
    /// sets of the same exercise. Delete rule is `.cascade` — all entries are
    /// deleted when this workout is deleted. Use `entries ?? []` at call sites.
    @Relationship(deleteRule: .cascade)
    public var entries: [WorkoutEntry]?

    /// The template this workout was started from, if any.
    ///
    /// `nil` for all workouts not initiated via a template. Set once on save;
    /// never modified. Delete rule is `.nullify` — the template survives if the
    /// workout log is deleted.
    @Relationship(deleteRule: .nullify, inverse: \WorkoutTemplate.workouts)
    public var template: WorkoutTemplate?

    /// Plans that were fulfilled by this workout, if any.
    ///
    /// Delete rule is `.nullify` — plans survive if the workout log is deleted.
    @Relationship(deleteRule: .nullify)
    public var plannedWorkouts: [PlannedWorkout]?

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
