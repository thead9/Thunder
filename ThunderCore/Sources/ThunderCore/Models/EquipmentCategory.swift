/// The broad category a piece of equipment belongs to.
///
/// Stored as its `String` raw value by SwiftData, which means adding new cases
/// in a future schema version is non-breaking — existing records retain their
/// raw string and decode correctly when the new case is present.
///
/// Use this enum for all categorisation logic. Do not compare raw strings directly.
public enum EquipmentCategory: String, Codable, CaseIterable, Sendable {
    case strength    = "strength"
    case cardio      = "cardio"
    case bodyweight  = "bodyweight"
    case flexibility = "flexibility"
    case outdoor     = "outdoor"
    case other       = "other"
}
