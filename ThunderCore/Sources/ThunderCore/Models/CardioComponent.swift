import Foundation
import SwiftData

/// Cardio-specific detail attached to a `Workout`.
///
/// `CardioComponent` is one of the workout component types in Thunder's
/// extensible component pattern. Rather than placing domain-specific fields
/// directly on `Workout`, each training modality owns its own model. This
/// keeps `Workout` stable across all activity types and allows new modalities
/// (strength analytics, flexibility tracking, etc.) to be added as new
/// component models in future schema versions without touching `Workout`.
///
/// ## Ownership
/// A `CardioComponent` is owned by exactly one `Workout`. Deleting the parent
/// `Workout` cascade-deletes the component (declared on `Workout.cardio`).
/// The `workout` back-reference uses `.nullify` so the property becomes `nil`
/// rather than dangling if the parent is somehow removed without cascade.
///
/// ## Intervals
/// Structured cardio interval detail lives here, not on `Workout`. Intervals
/// are semantically part of the cardio session — they do not exist independently.
/// Deleting the `CardioComponent` cascade-deletes all of its intervals.
///
/// ## CloudKit
/// All attributes are optional or carry declaration-site defaults.
@Model
public final class CardioComponent {
    public var id: UUID = UUID()

    /// Total distance covered in the session, in metres.
    public var distanceMeters: Double?

    /// Total elevation gained in the session, in metres.
    public var elevationGainMeters: Double?

    /// Average heart rate across the session, in beats per minute.
    public var averageHeartRateBPM: Double?

    /// Peak heart rate recorded during the session, in beats per minute.
    public var maxHeartRateBPM: Double?

    public var createdAt: Date = Date.now

    /// The parent workout that owns this component.
    ///
    /// Delete rule is `.nullify` — the reference becomes `nil` rather than
    /// dangling if the parent is removed without triggering the cascade.
    /// The cascade that deletes the component when a workout is deleted is
    /// declared on `Workout.cardio`.
    @Relationship(deleteRule: .nullify, inverse: \Workout.cardio)
    public var workout: Workout?

    /// Structured intervals logged within this cardio session.
    ///
    /// Sort by `intervalIndex` when displaying. Delete rule is `.cascade` —
    /// all associated `WorkoutInterval` records are deleted when this
    /// component is deleted. Use `intervals ?? []` at call sites.
    @Relationship(deleteRule: .cascade)
    public var intervals: [WorkoutInterval]?

    public init(
        id: UUID = UUID(),
        distanceMeters: Double? = nil,
        elevationGainMeters: Double? = nil,
        averageHeartRateBPM: Double? = nil,
        maxHeartRateBPM: Double? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.distanceMeters = distanceMeters
        self.elevationGainMeters = elevationGainMeters
        self.averageHeartRateBPM = averageHeartRateBPM
        self.maxHeartRateBPM = maxHeartRateBPM
        self.createdAt = createdAt
    }
}
