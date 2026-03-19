import Foundation
import SwiftData

/// A single set within a logged workout.
///
/// `WorkoutSet` is the detail layer for users who want to log structured exercise
/// data. It is optional — a `Workout` with zero sets is valid and common. Only
/// users who want set/rep/weight tracking interact with this model.
///
/// ## Relationship to Workout
/// Each `WorkoutSet` belongs to exactly one `Workout`. The relationship is declared
/// with `.nullify` on this side (the set's `workout` reference becomes `nil` if the
/// parent is somehow orphaned) and `.cascade` on the `Workout` side (sets are deleted
/// when their parent workout is deleted).
///
/// ## Exercise naming
/// `exerciseName` is a free-text string. A future migration may introduce a dedicated
/// `Exercise` entity if per-exercise history queries become a priority. The field name
/// and type are chosen to make that migration straightforward.
///
/// ## Future: equipment tracking
/// Equipment per set (e.g. "barbell", "cable machine") is a planned feature,
/// likely added as a lightweight `String?` migration on this model.
@Model
public final class WorkoutSet {
    public var id: UUID
    public var exerciseName: String
    public var setIndex: Int
    public var reps: Int?
    public var weightKg: Double?
    public var distanceMeters: Double?
    public var durationSeconds: Double?
    public var notes: String?
    public var createdAt: Date

    /// The parent workout this set belongs to.
    ///
    /// Delete rule is `.nullify` — if the parent is removed without triggering
    /// the cascade (e.g. direct context deletion), the reference becomes `nil`
    /// rather than leaving a dangling pointer. The cascade that deletes sets
    /// when a workout is deleted is declared on `Workout.sets`.
    @Relationship(deleteRule: .nullify, inverse: \Workout.sets)
    public var workout: Workout?

    public init(
        id: UUID = UUID(),
        exerciseName: String = "",
        setIndex: Int = 0,
        reps: Int? = nil,
        weightKg: Double? = nil,
        distanceMeters: Double? = nil,
        durationSeconds: Double? = nil,
        notes: String? = nil,
        createdAt: Date = .now,
        workout: Workout? = nil
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.setIndex = setIndex
        self.reps = reps
        self.weightKg = weightKg
        self.distanceMeters = distanceMeters
        self.durationSeconds = durationSeconds
        self.notes = notes
        self.createdAt = createdAt
        self.workout = workout
    }
}
