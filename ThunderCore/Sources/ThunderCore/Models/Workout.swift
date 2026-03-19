import Foundation
import SwiftData

/// A single logged workout session.
///
/// `Workout` is the core log entry in the Training domain. It is the most-written
/// and most-queried model in the suite. Every field is either optional or carries
/// a default value to satisfy CloudKit's requirement that no non-optional attribute
/// is nil on first sync.
///
/// ## HealthKit correlation
/// `healthKitID` stores the `UUID` of a matching `HKWorkout` when one exists.
/// The HealthKit service (BIZ-2) populates this field; the model itself has no
/// HealthKit dependency.
///
/// ## Relationships
/// `WorkoutSet` and `PlannedWorkout` hold the inverse relationships to `Workout`.
/// Delete rules on those relationships are declared in their respective model files
/// (TRAIN-2, TRAIN-4). Any `@Relationship` on this model that owns child objects
/// must declare an explicit delete rule — never rely on the default.
@Model
public final class Workout {
    public var id: UUID
    public var date: Date
    public var duration: TimeInterval?
    public var activityType: String
    public var notes: String?

    /// Raw `String` backing for `WorkoutSource`.
    ///
    /// SwiftData / CloudKit does not natively persist enums, so the source is
    /// stored as its raw value and projected through the computed `source` property.
    public var sourceRawValue: String

    /// The UUID of the correlated `HKWorkout`, if one exists.
    ///
    /// Populated by the HealthKit service (BIZ-2). `nil` for manually entered workouts
    /// until a correlation is established.
    public var healthKitID: UUID?
    public var createdAt: Date
    public var modifiedAt: Date

    /// The origin of this workout entry.
    ///
    /// A computed property over `sourceRawValue`. The raw value is what is actually
    /// persisted; this property is the type-safe interface for callers.
    public var source: WorkoutSource {
        get { WorkoutSource(rawValue: sourceRawValue) ?? .manual }
        set { sourceRawValue = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        date: Date = .now,
        duration: TimeInterval? = nil,
        activityType: String = "",
        notes: String? = nil,
        source: WorkoutSource = .manual,
        healthKitID: UUID? = nil,
        createdAt: Date = .now,
        modifiedAt: Date = .now
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.activityType = activityType
        self.notes = notes
        self.sourceRawValue = source.rawValue
        self.healthKitID = healthKitID
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
