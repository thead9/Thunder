/// The origin of a logged workout.
///
/// Stored as a `String` raw value so SwiftData persists it without a
/// separate transformation and CloudKit syncs it as a plain string attribute.
public enum WorkoutSource: String, Codable, Sendable {
    /// The user entered the workout manually.
    case manual

    /// The workout was imported from or correlated with a HealthKit entry.
    case healthKit
}
