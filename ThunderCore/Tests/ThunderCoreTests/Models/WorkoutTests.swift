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

        #expect(workout.activityType == nil)
        #expect(workout.source == .manual)
        #expect(workout.duration == nil)
        #expect(workout.notes == nil)
        #expect(workout.healthKitID == nil)
        #expect(workout.date >= before && workout.date <= after)
        #expect(workout.createdAt >= before && workout.createdAt <= after)
        #expect(workout.modifiedAt >= before && workout.modifiedAt <= after)
    }

    @Test("source round-trips through assignment")
    func sourceAssignment() {
        let workout = Workout(source: .healthKit)
        #expect(workout.source == .healthKit)
        workout.source = .manual
        #expect(workout.source == .manual)
    }

    @Test("entries and template default to nil")
    func relationshipDefaults() {
        let workout = Workout()
        #expect((workout.entries ?? []).isEmpty)
        #expect(workout.template == nil)
        #expect((workout.plannedWorkouts ?? []).isEmpty)
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
        let activity = ActivityType(name: "Strength")
        context.insert(activity)

        let workout = Workout(
            id: id,
            date: date,
            duration: 3600,
            activityType: activity,
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
        #expect(w.activityType?.name == "Strength")
        #expect(w.notes == "Felt strong")
        #expect(w.source == .healthKit)
        #expect(w.healthKitID == hkID)
        #expect(w.createdAt == created)
        #expect(w.modifiedAt == modified)
    }

    @Test("workout with no activityType is valid")
    func noActivityType() throws {
        let context = try makeTestContext()
        let workout = Workout(duration: 1800, notes: "Easy run")
        context.insert(workout)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Workout>())
        #expect(fetched.count == 1)
        #expect(fetched[0].activityType == nil)
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
        let activity = ActivityType(name: "Running")
        context.insert(activity)

        let a = Workout(activityType: activity)
        let b = Workout(activityType: activity)
        context.insert(a)
        context.insert(b)
        try context.save()

        let results = try context.fetch(FetchDescriptor<Workout>())
        #expect(results.count == 2)
        #expect(results[0].id != results[1].id)
        #expect(results[0].activityType?.name == "Running")
        #expect(results[1].activityType?.name == "Running")
    }

    @Test("deleting ActivityType nullifies workout.activityType; workout survives")
    func deleteActivityTypeNullifiesWorkout() throws {
        let context = try makeTestContext()
        let activity = ActivityType(name: "Cycling")
        let workout = Workout(activityType: activity)
        context.insert(activity)
        context.insert(workout)
        try context.save()

        context.delete(activity)
        try context.save()

        let workouts = try context.fetch(FetchDescriptor<Workout>())
        #expect(workouts.count == 1)
        #expect(workouts[0].activityType == nil)
    }

    @Test("plannedWorkouts inverse is populated when plan links to workout")
    func plannedWorkoutsInverse() throws {
        let context = try makeTestContext()
        let workout = Workout()
        context.insert(workout)
        let plan = PlannedWorkout(scheduledDate: .now, status: .completed, workout: workout)
        context.insert(plan)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Workout>())
        let w = try #require(fetched.first)
        #expect((w.plannedWorkouts ?? []).count == 1)
        #expect(w.plannedWorkouts?.first?.status == .completed)
    }
}

@Suite("Workout — computed properties")
struct WorkoutComputedTests {

    @Test("totalVolume sums weight × reps across set entries")
    func totalVolume() throws {
        let context = try makeTestContext()
        let workout = Workout()
        let squat = WorkoutEntry(entryIndex: 0, entryType: .set, reps: 5, weightKg: 100)
        let press = WorkoutEntry(entryIndex: 1, entryType: .set, reps: 3, weightKg: 60)
        squat.workout = workout
        press.workout = workout
        context.insert(workout); context.insert(squat); context.insert(press)
        try context.save()

        let w = try #require(try context.fetch(FetchDescriptor<Workout>()).first)
        #expect(w.totalVolume == 5 * 100 + 3 * 60)
    }

    @Test("totalVolume excludes entries missing reps or weight")
    func totalVolumePartialFields() throws {
        let context = try makeTestContext()
        let workout = Workout()
        let complete = WorkoutEntry(entryIndex: 0, entryType: .set, reps: 5, weightKg: 100)
        let noWeight = WorkoutEntry(entryIndex: 1, entryType: .set, reps: 5)
        let noReps   = WorkoutEntry(entryIndex: 2, entryType: .set, weightKg: 100)
        complete.workout = workout; noWeight.workout = workout; noReps.workout = workout
        context.insert(workout); context.insert(complete); context.insert(noWeight); context.insert(noReps)
        try context.save()

        let w = try #require(try context.fetch(FetchDescriptor<Workout>()).first)
        #expect(w.totalVolume == 500)
    }

    @Test("totalDistance sums distanceMeters across all entries")
    func totalDistance() throws {
        let context = try makeTestContext()
        let workout = Workout()
        let e0 = WorkoutEntry(entryIndex: 0, entryType: .interval, distanceMeters: 400)
        let e1 = WorkoutEntry(entryIndex: 1, entryType: .interval, distanceMeters: 800)
        e0.workout = workout; e1.workout = workout
        context.insert(workout); context.insert(e0); context.insert(e1)
        try context.save()

        let w = try #require(try context.fetch(FetchDescriptor<Workout>()).first)
        #expect(w.totalDistance == 1200)
    }

    @Test("averageHeartRate returns nil when no entry has HR data")
    func averageHeartRateNil() throws {
        let context = try makeTestContext()
        let workout = Workout()
        let e = WorkoutEntry(entryIndex: 0, entryType: .effort, durationSeconds: 60)
        e.workout = workout
        context.insert(workout); context.insert(e)
        try context.save()

        let w = try #require(try context.fetch(FetchDescriptor<Workout>()).first)
        #expect(w.averageHeartRate == nil)
    }

    @Test("averageHeartRate averages across entries that have HR data")
    func averageHeartRateValue() throws {
        let context = try makeTestContext()
        let workout = Workout()
        let e0 = WorkoutEntry(entryIndex: 0, entryType: .interval, heartRateBPM: 160)
        let e1 = WorkoutEntry(entryIndex: 1, entryType: .interval, heartRateBPM: 180)
        e0.workout = workout; e1.workout = workout
        context.insert(workout); context.insert(e0); context.insert(e1)
        try context.save()

        let w = try #require(try context.fetch(FetchDescriptor<Workout>()).first)
        #expect(w.averageHeartRate == 170)
    }

    @Test("workout with no entries returns zero volume and distance")
    func emptyWorkoutComputeds() {
        let workout = Workout()
        #expect(workout.totalVolume == 0)
        #expect(workout.totalDistance == 0)
        #expect(workout.averageHeartRate == nil)
        #expect(workout.totalEffortDuration == 0)
    }
}
