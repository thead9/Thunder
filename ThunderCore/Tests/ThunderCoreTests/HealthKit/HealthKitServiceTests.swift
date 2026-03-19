import Foundation
import HealthKit
import Testing
@testable import ThunderCore

/// Tests for the logic exercisable without a live HealthKit store.
///
/// Live read/write paths require a real device and a provisioned app target.
/// These tests cover:
/// - Activity type string → `HKWorkoutActivityType` mapping (and `.other` fallback)
/// - `HKWorkoutActivityType` → Thunder string reverse mapping
/// - `WorkoutImportData` Sendable struct construction
@Suite("HealthKitService — activity type mapping")
struct HealthKitServiceActivityTypeMappingTests {

    let service = HealthKitService()

    // MARK: - String → HKWorkoutActivityType

    @Test("running maps correctly", arguments: ["running", "run", "Running", "RUN"])
    func runningMapping(input: String) async {
        let result = await service.hkActivityType(for: input)
        #expect(result == .running)
    }

    @Test("cycling maps correctly", arguments: ["cycling", "cycle", "bike", "BIKE"])
    func cyclingMapping(input: String) async {
        let result = await service.hkActivityType(for: input)
        #expect(result == .cycling)
    }

    @Test("walking maps correctly", arguments: ["walking", "walk"])
    func walkingMapping(input: String) async {
        let result = await service.hkActivityType(for: input)
        #expect(result == .walking)
    }

    @Test("swimming maps correctly", arguments: ["swimming", "swim"])
    func swimmingMapping(input: String) async {
        let result = await service.hkActivityType(for: input)
        #expect(result == .swimming)
    }

    @Test("strength training maps correctly", arguments: ["strength", "weights", "lifting", "weightlifting"])
    func strengthMapping(input: String) async {
        let result = await service.hkActivityType(for: input)
        #expect(result == .traditionalStrengthTraining)
    }

    @Test("HIIT maps correctly", arguments: ["hiit", "interval", "HIIT"])
    func hiitMapping(input: String) async {
        let result = await service.hkActivityType(for: input)
        #expect(result == .highIntensityIntervalTraining)
    }

    @Test("yoga maps correctly")
    func yogaMapping() async {
        let result = await service.hkActivityType(for: "yoga")
        #expect(result == .yoga)
    }

    @Test("pilates maps correctly")
    func pilatesMapping() async {
        let result = await service.hkActivityType(for: "pilates")
        #expect(result == .pilates)
    }

    @Test("rowing maps correctly", arguments: ["rowing", "row"])
    func rowingMapping(input: String) async {
        let result = await service.hkActivityType(for: input)
        #expect(result == .rowing)
    }

    @Test("elliptical maps correctly")
    func ellipticalMapping() async {
        let result = await service.hkActivityType(for: "elliptical")
        #expect(result == .elliptical)
    }

    @Test("stair climbing maps correctly", arguments: ["stairclimbing", "stairs"])
    func stairClimbingMapping(input: String) async {
        let result = await service.hkActivityType(for: input)
        #expect(result == .stairClimbing)
    }

    @Test("crossfit maps correctly")
    func crossfitMapping() async {
        let result = await service.hkActivityType(for: "crossfit")
        #expect(result == .crossTraining)
    }

    @Test("dance maps correctly")
    func danceMapping() async {
        let result = await service.hkActivityType(for: "dance")
        #expect(result == .cardioDance)
    }

    @Test("soccer/football maps correctly", arguments: ["soccer", "football"])
    func soccerMapping(input: String) async {
        let result = await service.hkActivityType(for: input)
        #expect(result == .soccer)
    }

    @Test("basketball maps correctly")
    func basketballMapping() async {
        let result = await service.hkActivityType(for: "basketball")
        #expect(result == .basketball)
    }

    @Test("tennis maps correctly")
    func tennisMapping() async {
        let result = await service.hkActivityType(for: "tennis")
        #expect(result == .tennis)
    }

    @Test("golf maps correctly")
    func golfMapping() async {
        let result = await service.hkActivityType(for: "golf")
        #expect(result == .golf)
    }

    @Test("hiking maps correctly", arguments: ["hiking", "hike"])
    func hikingMapping(input: String) async {
        let result = await service.hkActivityType(for: input)
        #expect(result == .hiking)
    }

    @Test("unknown activity type falls back to .other")
    func unknownFallsToOther() async {
        let result = await service.hkActivityType(for: "interpretive dance")
        #expect(result == .other)
    }

    @Test("empty string falls back to .other")
    func emptyStringFallsToOther() async {
        let result = await service.hkActivityType(for: "")
        #expect(result == .other)
    }
}

// MARK: - Reverse mapping

@Suite("HKWorkoutActivityType — thunderActivityType")
struct ThunderActivityTypeTests {

    @Test("running reverse maps to Running")
    func runningReverseMap() {
        #expect(HKWorkoutActivityType.running.thunderActivityType == "Running")
    }

    @Test("cycling reverse maps to Cycling")
    func cyclingReverseMap() {
        #expect(HKWorkoutActivityType.cycling.thunderActivityType == "Cycling")
    }

    @Test("walking reverse maps to Walking")
    func walkingReverseMap() {
        #expect(HKWorkoutActivityType.walking.thunderActivityType == "Walking")
    }

    @Test("swimming reverse maps to Swimming")
    func swimmingReverseMap() {
        #expect(HKWorkoutActivityType.swimming.thunderActivityType == "Swimming")
    }

    @Test("traditionalStrengthTraining reverse maps to Strength")
    func strengthReverseMap() {
        #expect(HKWorkoutActivityType.traditionalStrengthTraining.thunderActivityType == "Strength")
    }

    @Test("highIntensityIntervalTraining reverse maps to HIIT")
    func hiitReverseMap() {
        #expect(HKWorkoutActivityType.highIntensityIntervalTraining.thunderActivityType == "HIIT")
    }

    @Test("yoga reverse maps to Yoga")
    func yogaReverseMap() {
        #expect(HKWorkoutActivityType.yoga.thunderActivityType == "Yoga")
    }

    @Test("pilates reverse maps to Pilates")
    func pilatesReverseMap() {
        #expect(HKWorkoutActivityType.pilates.thunderActivityType == "Pilates")
    }

    @Test("rowing reverse maps to Rowing")
    func rowingReverseMap() {
        #expect(HKWorkoutActivityType.rowing.thunderActivityType == "Rowing")
    }

    @Test("elliptical reverse maps to Elliptical")
    func ellipticalReverseMap() {
        #expect(HKWorkoutActivityType.elliptical.thunderActivityType == "Elliptical")
    }

    @Test("stairClimbing reverse maps to Stair Climbing")
    func stairClimbingReverseMap() {
        #expect(HKWorkoutActivityType.stairClimbing.thunderActivityType == "Stair Climbing")
    }

    @Test("crossTraining reverse maps to CrossFit")
    func crossTrainingReverseMap() {
        #expect(HKWorkoutActivityType.crossTraining.thunderActivityType == "CrossFit")
    }

    @Test("cardioDance reverse maps to Dance")
    func cardioDanceReverseMap() {
        #expect(HKWorkoutActivityType.cardioDance.thunderActivityType == "Dance")
    }

    @Test("socialDance reverse maps to Dance")
    func socialDanceReverseMap() {
        #expect(HKWorkoutActivityType.socialDance.thunderActivityType == "Dance")
    }

    @Test("soccer reverse maps to Soccer")
    func soccerReverseMap() {
        #expect(HKWorkoutActivityType.soccer.thunderActivityType == "Soccer")
    }

    @Test("basketball reverse maps to Basketball")
    func basketballReverseMap() {
        #expect(HKWorkoutActivityType.basketball.thunderActivityType == "Basketball")
    }

    @Test("tennis reverse maps to Tennis")
    func tennisReverseMap() {
        #expect(HKWorkoutActivityType.tennis.thunderActivityType == "Tennis")
    }

    @Test("golf reverse maps to Golf")
    func golfReverseMap() {
        #expect(HKWorkoutActivityType.golf.thunderActivityType == "Golf")
    }

    @Test("hiking reverse maps to Hiking")
    func hikingReverseMap() {
        #expect(HKWorkoutActivityType.hiking.thunderActivityType == "Hiking")
    }

    @Test("other reverse maps to Other")
    func otherReverseMap() {
        #expect(HKWorkoutActivityType.other.thunderActivityType == "Other")
    }
}

// MARK: - WorkoutImportData

@Suite("WorkoutImportData")
struct WorkoutImportDataTests {

    @Test("stores all fields correctly")
    func storesFields() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 1_000_000)
        let data = WorkoutImportData(
            date: date,
            duration: 3600,
            activityType: "Running",
            healthKitID: id
        )
        #expect(data.date == date)
        #expect(data.duration == 3600)
        #expect(data.activityType == "Running")
        #expect(data.healthKitID == id)
    }

    @Test("is Sendable")
    func isSendable() async {
        let data = WorkoutImportData(
            date: .now,
            duration: 1800,
            activityType: "Cycling",
            healthKitID: UUID()
        )
        // Passing across a task boundary exercises the Sendable constraint
        let received = await Task.detached { data }.value
        #expect(received.activityType == "Cycling")
    }
}
