import Foundation
import SwiftData

/// A reusable blueprint for a workout.
///
/// A `WorkoutTemplate` captures the structure of a frequently repeated workout
/// without being a log entry. It does not become a `Workout` until the user
/// executes it. Templates reduce friction for users with consistent training
/// structures without forcing structure on those who do not.
///
/// ## Relationships
/// `TemplateSet` records belong to a `WorkoutTemplate` via a cascade relationship.
/// Deleting a template cascade-deletes all of its sets. Both to-many relationships
/// are declared as `[Model]?` per CloudKit's requirement that all relationships be
/// optional.
@Model
public final class WorkoutTemplate {
    public var id: UUID = UUID()
    public var name: String = ""
    public var activityType: String = ""
    public var notes: String?
    public var createdAt: Date = Date.now
    public var modifiedAt: Date = Date.now

    /// The sets that make up this template, in no guaranteed order.
    ///
    /// Sort by `setIndex` when displaying. Delete rule is `.cascade` — all
    /// associated `TemplateSet` records are deleted when this template is deleted.
    /// Use `sets ?? []` when an empty array is needed.
    @Relationship(deleteRule: .cascade)
    public var sets: [TemplateSet]?

    /// Plans generated from this template, if any.
    ///
    /// Delete rule is `.nullify` — plans survive if the template is deleted.
    /// Use `plans ?? []` when an empty array is needed.
    @Relationship(deleteRule: .nullify)
    public var plans: [PlannedWorkout]?

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
