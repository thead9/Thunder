import Testing
import Foundation
import SwiftData
@testable import ThunderCore

@Suite("WorkoutEntryType")
struct WorkoutEntryTypeTests {

    @Test("raw value round-trip: set")
    func rawValueSet() {
        #expect(WorkoutEntryType(rawValue: "set") == .set)
        #expect(WorkoutEntryType.set.rawValue == "set")
    }

    @Test("raw value round-trip: interval")
    func rawValueInterval() {
        #expect(WorkoutEntryType(rawValue: "interval") == .interval)
        #expect(WorkoutEntryType.interval.rawValue == "interval")
    }

    @Test("raw value round-trip: effort")
    func rawValueEffort() {
        #expect(WorkoutEntryType(rawValue: "effort") == .effort)
        #expect(WorkoutEntryType.effort.rawValue == "effort")
    }

    @Test("unknown raw value returns nil")
    func unknownRawValue() {
        #expect(WorkoutEntryType(rawValue: "unknown") == nil)
    }
}

@Suite("WorkoutEntry — default field values")
struct WorkoutEntryDefaultsTests {

    @Test("all defaults are correct on init")
    func defaults() {
        let before = Date.now
        let entry = WorkoutEntry()
        let after = Date.now

        #expect(entry.entryIndex == 0)
        #expect(entry.groupIndex == nil)
        #expect(entry.exerciseName == "")
        #expect(entry.entryType == .set)
        #expect(entry.notes == nil)
        #expect(entry.reps == nil)
        #expect(entry.weightKg == nil)
        #expect(entry.distanceMeters == nil)
        #expect(entry.durationSeconds == nil)
        #expect(entry.restDurationSeconds == nil)
        #expect(entry.heartRateBPM == nil)
        #expect(entry.elevationMeters == nil)
        #expect(entry.targetReps == nil)
        #expect(entry.targetWeightKg == nil)
        #expect(entry.targetDistanceMeters == nil)
        #expect(entry.targetDurationSeconds == nil)
        #expect(entry.workout == nil)
        #expect(entry.equipment == nil)
        #expect(entry.createdAt >= before && entry.createdAt <= after)
    }
}

@Suite("WorkoutEntry — persistence")
struct WorkoutEntryPersistenceTests {

    @Test("strength set round-trips all fields")
    func strengthSetRoundTrip() throws {
        let context = try makeTestContext()
        let workout = Workout(activityType: "Strength")
        let entry = WorkoutEntry(
            entryIndex: 0,
            groupIndex: 0,
            exerciseName: "Squat",
            entryType: .set,
            reps: 5,
            weightKg: 100,
            restDurationSeconds: 180,
            targetReps: 5,
            targetWeightKg: 100
        )
        entry.workout = workout
        context.insert(workout)
        context.insert(entry)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutEntry>())
        let e = try #require(fetched.first)
        #expect(e.exerciseName == "Squat")
        #expect(e.entryType == .set)
        #expect(e.reps == 5)
        #expect(e.weightKg == 100)
        #expect(e.groupIndex == 0)
        #expect(e.restDurationSeconds == 180)
        #expect(e.targetReps == 5)
        #expect(e.targetWeightKg == 100)
    }

    @Test("cardio interval round-trips all fields")
    func cardioIntervalRoundTrip() throws {
        let context = try makeTestContext()
        let workout = Workout(activityType: "Running")
        let entry = WorkoutEntry(
            entryIndex: 0,
            exerciseName: "400m repeat",
            entryType: .interval,
            distanceMeters: 400,
            durationSeconds: 105,
            restDurationSeconds: 60,
            heartRateBPM: 172,
            targetDistanceMeters: 400,
            targetDurationSeconds: 100
        )
        entry.workout = workout
        context.insert(workout)
        context.insert(entry)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutEntry>())
        let e = try #require(fetched.first)
        #expect(e.entryType == .interval)
        #expect(e.distanceMeters == 400)
        #expect(e.durationSeconds == 105)
        #expect(e.heartRateBPM == 172)
        #expect(e.targetDurationSeconds == 100)
    }

    @Test("free effort round-trips")
    func freeEffortRoundTrip() throws {
        let context = try makeTestContext()
        let workout = Workout(activityType: "Yoga")
        let entry = WorkoutEntry(
            entryIndex: 0,
            exerciseName: "Warrior II",
            entryType: .effort,
            durationSeconds: 60
        )
        entry.workout = workout
        context.insert(workout)
        context.insert(entry)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutEntry>())
        let e = try #require(fetched.first)
        #expect(e.entryType == .effort)
        #expect(e.durationSeconds == 60)
        #expect(e.reps == nil)
        #expect(e.distanceMeters == nil)
    }

    @Test("mixed-modality workout — entries with different types coexist")
    func mixedModalityWorkout() throws {
        let context = try makeTestContext()
        let workout = Workout(activityType: "CrossFit")
        let squat = WorkoutEntry(entryIndex: 0, exerciseName: "Thruster", entryType: .set, reps: 21, weightKg: 43)
        let row = WorkoutEntry(entryIndex: 1, exerciseName: "Row", entryType: .interval, distanceMeters: 500)
        squat.workout = workout
        row.workout = workout
        context.insert(workout)
        context.insert(squat)
        context.insert(row)
        try context.save()

        let entries = try context.fetch(
            FetchDescriptor<WorkoutEntry>(sortBy: [SortDescriptor(\.entryIndex)])
        )
        #expect(entries.count == 2)
        #expect(entries[0].entryType == .set)
        #expect(entries[1].entryType == .interval)
    }

    @Test("deleting Workout cascade-deletes all entries")
    func deleteWorkoutCascadesEntries() throws {
        let context = try makeTestContext()
        let workout = Workout(activityType: "Strength")
        let e0 = WorkoutEntry(entryIndex: 0, exerciseName: "Squat", entryType: .set)
        let e1 = WorkoutEntry(entryIndex: 1, exerciseName: "Press", entryType: .set)
        e0.workout = workout
        e1.workout = workout
        context.insert(workout)
        context.insert(e0)
        context.insert(e1)
        try context.save()

        context.delete(workout)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<WorkoutEntry>()).isEmpty)
    }

    @Test("entries for a workout are isolated from other workouts")
    func entryIsolation() throws {
        let context = try makeTestContext()
        let w1 = Workout(activityType: "Strength")
        let w2 = Workout(activityType: "Cardio")
        let e1 = WorkoutEntry(entryIndex: 0, exerciseName: "Squat", entryType: .set)
        let e2 = WorkoutEntry(entryIndex: 0, exerciseName: "Row", entryType: .interval)
        e1.workout = w1
        e2.workout = w2
        context.insert(w1); context.insert(w2)
        context.insert(e1); context.insert(e2)
        try context.save()

        let w1Entries = (w1.entries ?? [])
        let w2Entries = (w2.entries ?? [])
        #expect(w1Entries.count == 1)
        #expect(w2Entries.count == 1)
        #expect(w1Entries[0].exerciseName == "Squat")
        #expect(w2Entries[0].exerciseName == "Row")
    }
}

@Suite("WorkoutEntry — equipment relationship")
struct WorkoutEntryEquipmentTests {

    @Test("equipment assigned to entry round-trips through save")
    func equipmentRoundTrip() throws {
        let context = try makeTestContext()
        let eq = Equipment(name: "Barbell", category: .strength)
        let workout = Workout(activityType: "Strength")
        let entry = WorkoutEntry(entryIndex: 0, exerciseName: "Deadlift", entryType: .set)
        entry.workout = workout
        entry.equipment = eq
        context.insert(eq); context.insert(workout); context.insert(entry)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutEntry>())
        #expect(fetched.first?.equipment?.name == "Barbell")
    }

    @Test("deleting equipment nullifies entry.equipment; entry survives")
    func deleteEquipmentNullifiesEntry() throws {
        let context = try makeTestContext()
        let eq = Equipment(name: "Kettlebell", category: .strength)
        let workout = Workout(activityType: "Strength")
        let entry = WorkoutEntry(entryIndex: 0, exerciseName: "Swing", entryType: .set)
        entry.workout = workout
        entry.equipment = eq
        context.insert(eq); context.insert(workout); context.insert(entry)
        try context.save()

        context.delete(eq)
        try context.save()

        let entries = try context.fetch(FetchDescriptor<WorkoutEntry>())
        #expect(entries.count == 1)
        #expect(entries[0].equipment == nil)
    }
}

@Suite("Equipment — defaults and persistence")
struct EquipmentTests {

    @Test("all defaults correct on init")
    func defaults() {
        let eq = Equipment()
        #expect(eq.name == "")
        #expect(eq.category == .other)
        #expect(eq.notes == nil)
        #expect(eq.isUserDefined == false)
    }

    @Test("category enum round-trips for all cases")
    func categoryRoundTrip() throws {
        let context = try makeTestContext()
        for category in EquipmentCategory.allCases {
            let eq = Equipment(name: category.rawValue, category: category)
            context.insert(eq)
        }
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Equipment>())
        let categories = Set(fetched.map(\.category))
        #expect(categories == Set(EquipmentCategory.allCases))
    }

    @Test("insert → save → fetch round-trip")
    func roundTrip() throws {
        let context = try makeTestContext()
        let id = UUID()
        let eq = Equipment(id: id, name: "Pull-up Bar", category: .bodyweight, isUserDefined: false)
        context.insert(eq)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Equipment>())
        let e = try #require(fetched.first)
        #expect(e.id == id)
        #expect(e.name == "Pull-up Bar")
        #expect(e.category == .bodyweight)
    }
}
