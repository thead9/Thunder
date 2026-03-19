import Foundation
import SwiftData

/// A reusable blueprint for a workout.
///
/// A `WorkoutTemplate` captures the structure of a frequently repeated workout
/// without being a log entry. It does not become a `Workout` until the user
/// executes it. Templates reduce friction for users with consistent training
/// structures without forcing structure on those who do not.
///
/// ## Relationship to TemplateSet
/// `TemplateSet` records belong to a `WorkoutTemplate` via a cascade relationship.
/// Deleting a template cascade-deletes all of its sets.
@Model
public final class WorkoutTemplate {
    public var id: UUID
    public var name: String
    public var activityType: String
    public var notes: String?
    public var createdAt: Date
    public var modifiedAt: Date

    /// The sets that make up this template, in no guaranteed order.
    ///
    /// Sort by `setIndex` when displaying. Delete rule is `.cascade` — all
    /// associated `TemplateSet` records are deleted when this template is deleted.
    @Relationship(deleteRule: .cascade)
    public var sets = [TemplateSet]()

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
