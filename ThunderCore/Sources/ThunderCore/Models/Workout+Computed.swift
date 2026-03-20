import Foundation

public extension Workout {

    /// Total volume lifted across all strength entries (weight × reps).
    ///
    /// Only entries with both `weightKg` and `reps` populated contribute.
    /// `nil` fields are not treated as zero — they are not recorded data.
    var totalVolume: Double {
        (entries ?? [])
            .compactMap { entry -> Double? in
                guard let reps = entry.reps, let weight = entry.weightKg else { return nil }
                return Double(reps) * weight
            }
            .reduce(0, +)
    }

    /// Total distance covered across all entries that recorded it, in metres.
    var totalDistance: Double {
        (entries ?? [])
            .compactMap(\.distanceMeters)
            .reduce(0, +)
    }

    /// Average heart rate across all entries that recorded it, in beats per minute.
    ///
    /// Returns `nil` if no entry recorded a heart rate.
    var averageHeartRate: Double? {
        let readings = (entries ?? []).compactMap(\.heartRateBPM)
        guard !readings.isEmpty else { return nil }
        return readings.reduce(0, +) / Double(readings.count)
    }

    /// Total active effort duration across all entries, in seconds.
    ///
    /// This is NOT the same as `duration` — `duration` is real-world elapsed
    /// time including rest and transitions. This is the sum of active effort
    /// durations only, derived from entries.
    var totalEffortDuration: Double {
        (entries ?? [])
            .compactMap(\.durationSeconds)
            .reduce(0, +)
    }
}
