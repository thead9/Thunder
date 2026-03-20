import Foundation
import SwiftData

/// A piece of equipment used during a workout set or interval.
///
/// `Equipment` is a first-class `@Model` rather than an enum, allowing users to
/// define custom equipment and enabling richer querying across sessions.
///
/// ## Seeding
/// A vocabulary of common items is seeded at the app layer on first launch —
/// not in the migration itself. Seeded items have `isUserDefined: false`.
/// User-created equipment has `isUserDefined: true`.
///
/// ## Relationships
/// `WorkoutSet`, `TemplateSet`, and `WorkoutInterval` hold optional references
/// to an `Equipment` record. Delete rule on all three is `.nullify` — deleting
/// a piece of equipment does not delete the sets or intervals that used it.
/// All relationships are bidirectional with explicit inverses on both sides.
@Model
public final class Equipment {
    public var id: UUID = UUID()
    public var name: String = ""

    /// Broad grouping for display and filtering.
    ///
    /// Example values: "Strength", "Cardio", "Bodyweight".
    /// Stored as `String` rather than an enum so new categories can be added
    /// without a migration.
    public var category: String = ""
    public var notes: String?

    /// `false` for seeded vocabulary items; `true` for user-created equipment.
    public var isUserDefined: Bool = false
    public var createdAt: Date = Date.now

    /// The workout sets that used this piece of equipment.
    ///
    /// Delete rule is `.nullify` — sets are not deleted when equipment is removed.
    /// Use `workoutSets ?? []` at call sites.
    @Relationship(deleteRule: .nullify)
    public var workoutSets: [WorkoutSet]?

    /// The template sets that reference this piece of equipment.
    ///
    /// Delete rule is `.nullify`. Use `templateSets ?? []` at call sites.
    @Relationship(deleteRule: .nullify)
    public var templateSets: [TemplateSet]?

    /// The workout intervals that used this piece of equipment.
    ///
    /// Delete rule is `.nullify`. Use `workoutIntervals ?? []` at call sites.
    @Relationship(deleteRule: .nullify)
    public var workoutIntervals: [WorkoutInterval]?

    public init(
        id: UUID = UUID(),
        name: String = "",
        category: String = "",
        notes: String? = nil,
        isUserDefined: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.notes = notes
        self.isUserDefined = isUserDefined
        self.createdAt = createdAt
    }
}
