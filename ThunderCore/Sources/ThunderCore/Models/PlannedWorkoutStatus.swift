/// The status of a planned workout.
///
/// Stored as a `String` raw value so SwiftData persists it without a
/// transformation and CloudKit syncs it as a plain string attribute.
public enum PlannedWorkoutStatus: String, Codable, Sendable {
    /// The workout has been scheduled but not yet completed or skipped.
    case planned

    /// The workout was completed. A linked `Workout` record typically exists.
    case completed

    /// The workout was intentionally skipped. The plan record is retained
    /// to surface the gap between intent and reality.
    case skipped
}
