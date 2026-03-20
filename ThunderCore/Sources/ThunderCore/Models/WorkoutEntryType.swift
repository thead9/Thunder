/// The kind of effort a `WorkoutEntry` or `TemplateEntry` represents.
///
/// Stored as its `String` raw value by SwiftData. Adding new cases in a future
/// schema version is non-breaking — existing records retain their raw string
/// and decode correctly when the new case is present.
///
/// - `set`: A strength or resistance effort: reps, weight, exercise name.
///   e.g. "5 × 100 kg squat"
///
/// - `interval`: A structured cardio effort: distance and/or duration at a
///   target pace or intensity. e.g. "400 m in 1:45, rest 60 s"
///
/// - `effort`: A free-form time-based effort with no required metric fields.
///   e.g. "10 min warrior flow", "2 min L-sit hold"
///
/// These are not mutually exclusive descriptors — a single `WorkoutEntry` can
/// carry fields from multiple categories (e.g. a CrossFit thruster has reps,
/// weight, AND a target duration). The type drives UI presentation and default
/// field visibility, not data constraints.
public enum WorkoutEntryType: String, Codable, CaseIterable, Sendable {
    case set      = "set"
    case interval = "interval"
    case effort   = "effort"
}
