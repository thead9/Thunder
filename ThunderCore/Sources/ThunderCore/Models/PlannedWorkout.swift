import Foundation
import SwiftData

/// A scheduled future workout that may be completed, skipped, or remain planned.
///
/// `PlannedWorkout` is the intent layer of the Training domain. A plan that was
/// skipped is still data — it reflects the gap between intent and reality, which
/// is one of the most honest things a training log can surface.
///
/// ## Status storage
/// `statusRawValue` is the persisted `String` backing for `PlannedWorkoutStatus`.
/// The computed `status` property is the type-safe interface for callers.
/// A backing string is required here because `FetchDescriptor` predicates cannot
/// filter on enum values or access `.rawValue` within predicate expressions —
/// filtering by status is a core use case for this model.
///
/// ## Relationships
/// Both `template` and `workout` are optional with `.nullify` delete rules.
/// The plan record survives independently if either is deleted.
///
/// - `template`: the `WorkoutTemplate` used to generate this plan, if any.
/// - `workout`: the `Workout` log entry created when this plan was completed, if any.
@Model
public final class PlannedWorkout {
    public var id: UUID
    public var scheduledDate: Date

    /// Raw `String` backing for `PlannedWorkoutStatus`.
    ///
    /// Use the computed `status` property in application code. Use `statusRawValue`
    /// directly only in `FetchDescriptor` predicates where enum values are not supported.
    public var statusRawValue: String

    public var notes: String?
    public var createdAt: Date
    public var modifiedAt: Date

    /// The current status of this plan.
    ///
    /// A computed property over `statusRawValue`. Falls back to `.planned` if the
    /// stored value is unrecognised (guards against future raw value changes).
    public var status: PlannedWorkoutStatus {
        get { PlannedWorkoutStatus(rawValue: statusRawValue) ?? .planned }
        set { statusRawValue = newValue.rawValue }
    }

    /// The template this plan was generated from, if any.
    ///
    /// `.nullify` — the plan survives if the template is deleted.
    @Relationship(deleteRule: .nullify, inverse: \WorkoutTemplate.plans)
    public var template: WorkoutTemplate?

    /// The workout log entry created when this plan was completed, if any.
    ///
    /// `.nullify` — the plan record survives if the linked workout is deleted.
    @Relationship(deleteRule: .nullify, inverse: \Workout.plannedWorkouts)
    public var workout: Workout?

    public init(
        id: UUID = UUID(),
        scheduledDate: Date = .now,
        status: PlannedWorkoutStatus = .planned,
        notes: String? = nil,
        createdAt: Date = .now,
        modifiedAt: Date = .now,
        template: WorkoutTemplate? = nil,
        workout: Workout? = nil
    ) {
        self.id = id
        self.scheduledDate = scheduledDate
        self.statusRawValue = status.rawValue
        self.notes = notes
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.template = template
        self.workout = workout
    }
}
