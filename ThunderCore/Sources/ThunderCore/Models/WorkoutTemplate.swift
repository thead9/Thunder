import Foundation
import SwiftData

/// A reusable blueprint for a workout.
///
/// A `WorkoutTemplate` captures the structure of a frequently repeated workout
/// without being a log entry. It does not become a `Workout` until the user
/// executes it. Templates reduce friction for users with consistent training
/// structures without forcing structure on users who do not have one.
///
/// ## Entries
/// `TemplateEntry` records prescribe what the template calls for. They mirror
/// `WorkoutEntry` in structure but carry only target fields — no actuals.
/// Deleting a template cascade-deletes all of its entries.
///
/// ## Workout link
/// `workouts` is the inverse of `Workout.template`. It provides a queryable
/// record of every log entry that was started from this template. Delete rule
/// is `.nullify` — deleting a template sets `Workout.template` to `nil` on all
/// associated logs without deleting them.
@Model
public final class WorkoutTemplate {
    public var id: UUID = UUID()
    public var name: String = ""
    public var activityType: String = ""
    public var notes: String?
    public var createdAt: Date = Date.now
    public var modifiedAt: Date = Date.now

    /// The prescribed efforts that make up this template, in no guaranteed order.
    ///
    /// Sort by `entryIndex` when displaying. Group by `groupIndex` to cluster
    /// sets of the same exercise. Delete rule is `.cascade` — all entries are
    /// deleted when this template is deleted. Use `entries ?? []` at call sites.
    @Relationship(deleteRule: .cascade)
    public var entries: [TemplateEntry]?

    /// Plans generated from this template, if any.
    ///
    /// Delete rule is `.nullify` — plans survive if the template is deleted.
    /// Use `plans ?? []` at call sites.
    @Relationship(deleteRule: .nullify)
    public var plans: [PlannedWorkout]?

    /// Workouts that were started from this template.
    ///
    /// Inverse of `Workout.template`. Delete rule is `.nullify` — deleting this
    /// template sets `Workout.template` to `nil` on all associated logs; it does
    /// not delete the logs. Use `workouts ?? []` at call sites.
    @Relationship(deleteRule: .nullify)
    public var workouts: [Workout]?

    public init(
        id: UUID = UUID(),
        name: String = "",
        activityType: String = "",
        notes: String? = nil,
        createdAt: Date = .now,
        modifiedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.activityType = activityType
        self.notes = notes
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
