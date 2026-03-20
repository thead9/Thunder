import Foundation
import SwiftData

/// A single interval within a structured cardio session.
///
/// `WorkoutInterval` captures the per-interval detail for structured cardio
/// sessions (e.g. 8×400m repeats). It belongs to a `CardioComponent`, not
/// directly to a `Workout` — intervals are semantically part of the cardio
/// session and do not exist independently.
///
/// ## Ordering
/// Sort by `intervalIndex` when displaying. The index is caller-managed;
/// this model does not enforce uniqueness.
///
/// ## Relationship to CardioComponent
/// Each `WorkoutInterval` belongs to exactly one `CardioComponent`. Delete
/// rule on this side is `.nullify` — the reference becomes `nil` if the parent
/// is removed without triggering the cascade. The cascade that deletes intervals
/// when a `CardioComponent` is deleted is declared on `CardioComponent.intervals`.
///
/// ## Equipment
/// An optional `Equipment` reference captures what was used (e.g. "Rowing Machine").
/// Delete rule is `.nullify` — removing an equipment record does not remove the interval.
@Model
public final class WorkoutInterval {
    public var id: UUID = UUID()
    public var exerciseName: String = ""
    public var intervalIndex: Int = 0
    public var targetDistanceMeters: Double?
    public var actualDistanceMeters: Double?
    public var targetDurationSeconds: Double?
    public var actualDurationSeconds: Double?
    public var restDurationSeconds: Double?
    public var heartRateAverageBPM: Double?
    public var notes: String?
    public var createdAt: Date = Date.now

    /// The cardio component this interval belongs to.
    ///
    /// Delete rule is `.nullify` — if the parent is removed without triggering
    /// the cascade, the reference becomes `nil` rather than a dangling pointer.
    /// The cascade that deletes intervals when a `CardioComponent` is deleted is
    /// declared on `CardioComponent.intervals`.
    @Relationship(deleteRule: .nullify, inverse: \CardioComponent.intervals)
    public var cardio: CardioComponent?

    /// The equipment used during this interval, if any.
    ///
    /// Delete rule is `.nullify` — removing equipment does not remove the interval.
    @Relationship(deleteRule: .nullify, inverse: \Equipment.workoutIntervals)
    public var equipment: Equipment?

    public init(
        id: UUID = UUID(),
        exerciseName: String = "",
        intervalIndex: Int = 0,
        targetDistanceMeters: Double? = nil,
        actualDistanceMeters: Double? = nil,
        targetDurationSeconds: Double? = nil,
        actualDurationSeconds: Double? = nil,
        restDurationSeconds: Double? = nil,
        heartRateAverageBPM: Double? = nil,
        notes: String? = nil,
        createdAt: Date = .now,
        cardio: CardioComponent? = nil,
        equipment: Equipment? = nil
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.intervalIndex = intervalIndex
        self.targetDistanceMeters = targetDistanceMeters
        self.actualDistanceMeters = actualDistanceMeters
        self.targetDurationSeconds = targetDurationSeconds
        self.actualDurationSeconds = actualDurationSeconds
        self.restDurationSeconds = restDurationSeconds
        self.heartRateAverageBPM = heartRateAverageBPM
        self.notes = notes
        self.createdAt = createdAt
        self.cardio = cardio
        self.equipment = equipment
    }
}
