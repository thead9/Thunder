import Testing
import Foundation
import SwiftData
import ThunderCore

@Suite("WorkoutSource")
struct WorkoutSourceTests {

    @Test("raw value round-trip: manual")
    func rawValueManual() {
        #expect(WorkoutSource(rawValue: "manual") == .manual)
        #expect(WorkoutSource.manual.rawValue == "manual")
    }

    @Test("raw value round-trip: healthKit")
    func rawValueHealthKit() {
        #expect(WorkoutSource(rawValue: "healthKit") == .healthKit)
        #expect(WorkoutSource.healthKit.rawValue == "healthKit")
    }

    @Test("unknown raw value falls back to nil")
    func unknownRawValue() {
        #expect(WorkoutSource(rawValue: "unknown") == nil)
    }
}

@Suite("Workout — default field values")
struct WorkoutDefaultsTests {

    @Test("all defaults are set correctly on init")
    func defaults() {
        let before = Date.now
        let workout = Workout()
        let after = Date.now

        #expect(workout.activityType == "")
        #expect(workout.source == .manual)
        #expect(workout.sourceRawValue == "manual")
        #expect(workout.duration == nil)
        #expect(workout.notes == nil)
        #expect(workout.healthKitID == nil)
        #expect(workout.date >= before && workout.date <= after)
        #expect(workout.createdAt >= before && workout.createdAt <= after)
        #expect(workout.modifiedAt >= before && workout.modifiedAt <= after)
    }

    @Test("source computed property reflects sourceRawValue")
    func sourceProjection() {
        let workout = Workout(source: .healthKit)
        #expect(workout.sourceRawValue == "healthKit")
        #expect(workout.source == .healthKit)

        workout.source = .manual
        #expect(workout.sourceRawValue == "manual")
        #expect(workout.source == .manual)
    }
}

@Suite("Workout — persistence")
struct WorkoutPersistenceTests {

    @Test("insert → save → fetch round-trip preserves all fields")
    func roundTrip() throws {
        let context = try makeTestContext()

        let id = UUID()
        let hkID = UUID()
        let date = Date(timeIntervalSince1970: 1_000_000)
        let created = Date(timeIntervalSince1970: 1_000_001)
        let modified = Date(timeIntervalSince1970: 1_000_002)

        let workout = Workout(
            id: id,
            date: date,
            duration: 3600,
            activityType: "Strength",
            notes: "Felt strong",
            source: .healthKit,
            healthKitID: hkID,
            createdAt: created,
            modifiedAt: modified
        )
        context.insert(workout)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Workout>())
        #expect(fetched.count == 1)
        let w = try #require(fetched.first)
        #expect(w.id == id)
        #expect(w.date == date)
        #expect(w.duration == 3600)
        #expect(w.activityType == "Strength")
        #expect(w.notes == "Felt strong")
        #expect(w.sourceRawValue == "healthKit")
        #expect(w.healthKitID == hkID)
        #expect(w.createdAt == created)
        #expect(w.modifiedAt == modified)
    }

    @Test("FetchDescriptor date range filter returns correct results")
    func dateRangeFilter() throws {
        let context = try makeTestContext()

        let early = Workout(date: Date(timeIntervalSince1970: 1_000))
        let mid   = Workout(date: Date(timeIntervalSince1970: 5_000))
        let late  = Workout(date: Date(timeIntervalSince1970: 9_000))
        context.insert(early)
        context.insert(mid)
        context.insert(late)
        try context.save()

        let rangeStart = Date(timeIntervalSince1970: 3_000)
        let rangeEnd   = Date(timeIntervalSince1970: 7_000)
        var descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.date >= rangeStart && $0.date <= rangeEnd }
        )
        descriptor.sortBy = [SortDescriptor(\.date)]

        let results = try context.fetch(descriptor)
        #expect(results.count == 1)
        #expect(results[0].date == mid.date)
    }

    @Test("two workouts with same activityType are fetched independently")
    func sameActivityTypeIndependence() throws {
        let context = try makeTestContext()

        let a = Workout(activityType: "Running")
        let b = Workout(activityType: "Running")
        context.insert(a)
        context.insert(b)
        try context.save()

        let results = try context.fetch(FetchDescriptor<Workout>())
        #expect(results.count == 2)
        #expect(results[0].id != results[1].id)
    }
}
