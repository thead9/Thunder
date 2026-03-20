import Foundation
import SwiftData

/// A piece of equipment referenced by workout and template entries.
///
/// `Equipment` is a first-class `@Model` rather than an enum, allowing users to
/// define custom equipment and enabling richer querying across sessions.
///
/// ## Seeding
/// A vocabulary of common items is seeded at the app layer on first launch.
/// Seeded items have `isUserDefined: false`. User-created items have `isUserDefined: true`.
///
/// ## Relationships
/// Both `WorkoutEntry` and `TemplateEntry` hold an optional reference to an
/// `Equipment` record. Delete rule on both is `.nullify` — removing a piece of
/// equipment does not remove the entries that used it.
@Model
public final class Equipment {
    public var id: UUID = UUID()
    public var name: String = ""

    /// Broad grouping for display and filtering.
    ///
    /// Stored as its `String` raw value — adding new `EquipmentCategory` cases
    /// is non-breaking.
    public var category: EquipmentCategory = EquipmentCategory.other
    public var notes: String?

    /// `false` for seeded vocabulary; `true` for user-created equipment.
    public var isUserDefined: Bool = false
    public var createdAt: Date = Date.now

    /// Workout entries that used this piece of equipment.
    ///
    /// Use `workoutEntries ?? []` at call sites.
    @Relationship(deleteRule: .nullify)
    public var workoutEntries: [WorkoutEntry]?

    /// Template entries that reference this piece of equipment.
    ///
    /// Use `templateEntries ?? []` at call sites.
    @Relationship(deleteRule: .nullify)
    public var templateEntries: [TemplateEntry]?

    public init(
        id: UUID = UUID(),
        name: String = "",
        category: EquipmentCategory = .other,
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
