import Foundation
import SwiftData

/// A single set within a workout template.
///
/// `TemplateSet` mirrors `WorkoutSet` in structure but uses `target` prefixes
/// on numeric fields to make clear these are goals, not logged actuals.
/// The `exerciseName` field follows the same free-text convention as `WorkoutSet`,
/// anticipating a future `Exercise` entity if per-exercise history queries become
/// a priority.
@Model
public final class TemplateSet {
    public var id: UUID
    public var exerciseName: String
    public var setIndex: Int
    public var targetReps: Int?
    public var targetWeightKg: Double?
    public var targetDistanceMeters: Double?
    public var targetDurationSeconds: Double?
    public var notes: String?
    public var createdAt: Date

    /// The parent template this set belongs to.
    ///
    /// Delete rule is `.nullify` — the reference is zeroed if the parent is
    /// removed without triggering the cascade. The cascade that deletes sets
    /// when a template is deleted is declared on `WorkoutTemplate.sets`.
    @Relationship(deleteRule: .nullify, inverse: \WorkoutTemplate.sets)
    public var template: WorkoutTemplate?

    public init(
        id: UUID = UUID(),
        exerciseName: String = "",
        setIndex: Int = 0,
        targetReps: Int? = nil,
        targetWeightKg: Double? = nil,
        targetDistanceMeters: Double? = nil,
        targetDurationSeconds: Double? = nil,
        notes: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.setIndex = setIndex
        self.targetReps = targetReps
        self.targetWeightKg = targetWeightKg
        self.targetDistanceMeters = targetDistanceMeters
        self.targetDurationSeconds = targetDurationSeconds
        self.notes = notes
        self.createdAt = createdAt
    }
}
