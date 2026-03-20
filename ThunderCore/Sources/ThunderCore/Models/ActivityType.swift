import Foundation
import SwiftData

/// A named category of physical activity.
///
/// `ActivityType` is a first-class `@Model` rather than a free-text `String`,
/// enabling queryable history by activity, cross-workout analytics, and a
/// user-extensible vocabulary. A seeded set of common types ships with the app
/// (`isUserDefined: false`). Users may add their own (`isUserDefined: true`).
///
/// ## Why not an enum?
/// Enums constrain the vocabulary to what was anticipated at build time. A
/// person who trains via capoeira, parkour, or axe throwing should not need a
/// software update to log their sport. A model allows arbitrary extension
/// without a schema migration.
///
/// ## Relationships
/// `workouts` and `templates` are the inverses of `Workout.activityType` and
/// `WorkoutTemplate.activityType`. Delete rule is `.nullify` on both — removing
/// an activity type does not delete the workouts or templates that referenced it.
/// Use `activityType ?? []` at call sites for those collections.
@Model
public final class ActivityType {
    public var id: UUID = UUID()
    public var name: String = ""

    /// `false` for seeded vocabulary; `true` for user-created types.
    public var isUserDefined: Bool = false
    public var createdAt: Date = Date.now

    /// Workouts logged under this activity type.
    ///
    /// Use `workouts ?? []` at call sites.
    @Relationship(deleteRule: .nullify)
    public var workouts: [Workout]?

    /// Templates created under this activity type.
    ///
    /// Use `templates ?? []` at call sites.
    @Relationship(deleteRule: .nullify)
    public var templates: [WorkoutTemplate]?

    public init(
        id: UUID = UUID(),
        name: String = "",
        isUserDefined: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.isUserDefined = isUserDefined
        self.createdAt = createdAt
    }
}
