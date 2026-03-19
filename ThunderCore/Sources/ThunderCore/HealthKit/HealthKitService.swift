import Foundation
import HealthKit
import SwiftData

/// Sendable data returned by `HealthKitService.importWorkouts(since:excludingIDs:)`.
///
/// Because `Workout` is `@MainActor`-isolated, the actor cannot return `Workout`
/// instances directly. `WorkoutImportData` carries the field values needed to
/// construct a `Workout` on `@MainActor` after the import query completes.
public struct WorkoutImportData: Sendable {
    public let date: Date
    public let duration: TimeInterval
    public let activityType: String
    public let healthKitID: UUID
}

/// An actor-isolated service that bridges Thunder's `Workout` model and HealthKit.
///
/// `HealthKitService` is the only type in ThunderCore that interacts with HealthKit
/// directly. No view, no other service, and nothing in the data layer imports
/// HealthKit independently.
///
/// ## Responsibilities
///
/// - Requesting the minimum HealthKit authorisations Thunder needs
/// - Writing completed workout data to HealthKit and returning the resulting UUID
///   for the caller to record on the `Workout` model
/// - Importing external `HKWorkout` records, filtered against a caller-supplied set
///   of already-correlated IDs, returning `WorkoutImportData` for the caller to
///   construct `Workout` instances on `@MainActor`
///
/// ## Thread safety
///
/// Declared as an `actor` for serialised HealthKit access. Because `Workout` and
/// `ModelContext` are `@MainActor`-isolated, model operations are the caller's
/// responsibility — the actor deals only with HealthKit.
///
/// ## Manual validation
///
/// Live HealthKit read/write paths require a real device and a provisioned app
/// target. Unit tests cover the logic exercisable without HealthKit (activity type
/// mapping, duplicate filtering). Device testing validates the live paths.
public actor HealthKitService {

    private let store = HKHealthStore()

    private static let writeTypes: Set<HKSampleType> = [HKWorkoutType.workoutType()]
    private static let readTypes: Set<HKObjectType> = [HKWorkoutType.workoutType()]

    public init() {}

    // MARK: - Authorization

    /// Requests HealthKit authorisation for the types Thunder uses.
    ///
    /// Call this before any read or write operation.
    public func requestAuthorization() async throws {
        try await store.requestAuthorization(
            toShare: Self.writeTypes,
            read: Self.readTypes
        )
    }

    // MARK: - Write

    /// Saves workout data to HealthKit and returns the resulting `HKWorkout.uuid`.
    ///
    /// The caller (on `@MainActor`) is responsible for setting `workout.healthKitID`
    /// to the returned UUID and saving the context.
    ///
    /// - Parameters:
    ///   - date: The workout start date.
    ///   - duration: The workout duration in seconds, if known.
    ///   - activityType: The Thunder `activityType` string for the workout.
    /// - Returns: The UUID of the newly created `HKWorkout`.
    /// - Throws: An `HKError` if the HealthKit save fails.
    public func write(date: Date, duration: TimeInterval?, activityType: String) async throws -> UUID {
        let hkType = hkActivityType(for: activityType)
        let start = date
        let end = duration.map { start.addingTimeInterval($0) } ?? start

        let hkWorkout = HKWorkout(activityType: hkType, start: start, end: end)
        try await store.save(hkWorkout)
        return hkWorkout.uuid
    }

    // MARK: - Import

    /// Fetches `HKWorkout` records since `date`, excluding IDs already in the store.
    ///
    /// The caller supplies `existingHealthKitIDs` — the set of `healthKitID` values
    /// already correlated in the SwiftData store — and receives `WorkoutImportData`
    /// for new records only. The caller constructs `Workout` instances and inserts
    /// them into the context on `@MainActor`.
    ///
    /// - Parameters:
    ///   - date: The earliest `startDate` to query from HealthKit.
    ///   - existingHealthKitIDs: UUIDs of `HKWorkout` records already in the store.
    /// - Returns: Import data for workouts not yet in the store.
    /// - Throws: An `HKError` if the HealthKit query fails.
    public func importWorkouts(
        since date: Date,
        excludingIDs existingHealthKitIDs: Set<UUID>
    ) async throws -> [WorkoutImportData] {
        let predicate = HKQuery.predicateForSamples(
            withStart: date,
            end: nil,
            options: .strictStartDate
        )
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let hkWorkouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (samples as? [HKWorkout]) ?? [])
                }
            }
            store.execute(query)
        }

        return hkWorkouts
            .filter { !existingHealthKitIDs.contains($0.uuid) }
            .map {
                WorkoutImportData(
                    date: $0.startDate,
                    duration: $0.endDate.timeIntervalSince($0.startDate),
                    activityType: $0.workoutActivityType.thunderActivityType,
                    healthKitID: $0.uuid
                )
            }
    }

    // MARK: - Activity type mapping

    /// Maps a Thunder `activityType` string to an `HKWorkoutActivityType`.
    ///
    /// Matching is case-insensitive. Unmapped strings return `.other`.
    public func hkActivityType(for activityType: String) -> HKWorkoutActivityType {
        switch activityType.lowercased() {
        case "running", "run":               return .running
        case "cycling", "cycle", "bike":     return .cycling
        case "walking", "walk":              return .walking
        case "swimming", "swim":             return .swimming
        case "strength", "weights",
             "lifting", "weightlifting":     return .traditionalStrengthTraining
        case "hiit", "interval":             return .highIntensityIntervalTraining
        case "yoga":                         return .yoga
        case "pilates":                      return .pilates
        case "rowing", "row":                return .rowing
        case "elliptical":                   return .elliptical
        case "stairclimbing", "stairs":      return .stairClimbing
        case "crossfit":                     return .crossTraining
        case "dance":                        return .dance
        case "soccer", "football":           return .soccer
        case "basketball":                   return .basketball
        case "tennis":                       return .tennis
        case "golf":                         return .golf
        case "hiking", "hike":               return .hiking
        default:                             return .other
        }
    }
}

// MARK: - HKWorkoutActivityType → String

extension HKWorkoutActivityType {
    /// A human-readable Thunder `activityType` string for a given HealthKit type.
    ///
    /// Used when mapping imported `HKWorkout` records to `WorkoutImportData`
    /// so the resulting `Workout` has a meaningful `activityType` string.
    var thunderActivityType: String {
        switch self {
        case .running:                        return "Running"
        case .cycling:                        return "Cycling"
        case .walking:                        return "Walking"
        case .swimming:                       return "Swimming"
        case .traditionalStrengthTraining:    return "Strength"
        case .highIntensityIntervalTraining:  return "HIIT"
        case .yoga:                           return "Yoga"
        case .pilates:                        return "Pilates"
        case .rowing:                         return "Rowing"
        case .elliptical:                     return "Elliptical"
        case .stairClimbing:                  return "Stair Climbing"
        case .crossTraining:                  return "CrossFit"
        case .dance:                          return "Dance"
        case .soccer:                         return "Soccer"
        case .basketball:                     return "Basketball"
        case .tennis:                         return "Tennis"
        case .golf:                           return "Golf"
        case .hiking:                         return "Hiking"
        default:                              return "Other"
        }
    }
}
