import Foundation
import SwiftData

/// A named exercise that can be referenced across workout and template entries.
///
/// `Exercise` is a first-class `@Model` rather than a free-text `String`,
/// enabling queryable history by exercise (e.g. "all Squat sets ever"), volume
/// progression over time, and a user-extensible exercise library. A seeded set
/// of common exercises ships with the app (`isUserDefined: false`). Users may
/// add their own (`isUserDefined: true`).
///
/// ## Why not a String?
/// A string on the entry cannot answer "show me every time I deadlifted." A
/// model makes the exercise a queryable entity — joining sessions, plotting
/// one-rep-max progression, and comparing templates becomes a fetch, not a
/// text-matching heuristic.
///
/// ## Relationships
/// `workoutEntries` and `templateEntries` are the inverses of
/// `WorkoutEntry.exercise` and `TemplateEntry.exercise`. Delete rule is
/// `.nullify` — removing an exercise record does not remove the entries that
/// used it; those entries simply lose their exercise link.
@Model
public final class Exercise {
    public var id: UUID = UUID()
    public var name: String = ""
    public var notes: String?

    /// `false` for seeded vocabulary; `true` for user-created exercises.
    public var isUserDefined: Bool = false
    public var createdAt: Date = Date.now

    /// Logged workout entries that performed this exercise.
    ///
    /// Use `workoutEntries ?? []` at call sites.
    @Relationship(deleteRule: .nullify)
    public var workoutEntries: [WorkoutEntry]?

    /// Template entries that prescribe this exercise.
    ///
    /// Use `templateEntries ?? []` at call sites.
    @Relationship(deleteRule: .nullify)
    public var templateEntries: [TemplateEntry]?

    public init(
        id: UUID = UUID(),
        name: String = "",
        notes: String? = nil,
        isUserDefined: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.isUserDefined = isUserDefined
        self.createdAt = createdAt
    }
}
