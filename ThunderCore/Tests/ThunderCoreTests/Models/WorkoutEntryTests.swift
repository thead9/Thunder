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
        #expect(entry.exercise == nil)
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
        #expect(entry.targetRestDurationSeconds == nil)
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
        let workout = Workout()
        let squat = Exercise(name: "Squat")
        let entry = WorkoutEntry(
            entryIndex: 0,
            groupIndex: 0,
            entryType: .set,
            reps: 5,
            weightKg: 100,
            restDurationSeconds: 180,
            targetReps: 5,
            targetWeightKg: 100,
            targetRestDurationSeconds: 180,
            exercise: squat
        )
        entry.workout = workout
        context.insert(workout)
        context.insert(squat)
        context.insert(entry)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutEntry>())
        let e = try #require(fetched.first)
        #expect(e.exercise?.name == "Squat")
        #expect(e.entryType == .set)
        #expect(e.reps == 5)
        #expect(e.weightKg == 100)
        #expect(e.groupIndex == 0)
        #expect(e.restDurationSeconds == 180)
        #expect(e.targetReps == 5)
        #expect(e.targetWeightKg == 100)
        #expect(e.targetRestDurationSeconds == 180)
    }

    @Test("cardio interval round-trips all fields")
    func cardioIntervalRoundTrip() throws {
        let context = try makeTestContext()
        let workout = Workout()
        let exercise = Exercise(name: "400m repeat")
        let entry = WorkoutEntry(
            entryIndex: 0,
            entryType: .interval,
            distanceMeters: 400,
            durationSeconds: 105,
            restDurationSeconds: 60,
            heartRateBPM: 172,
            targetDistanceMeters: 400,
            targetDurationSeconds: 100,
            targetRestDurationSeconds: 60,
            exercise: exercise
        )
        entry.workout = workout
        context.insert(workout)
        context.insert(exercise)
        context.insert(entry)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutEntry>())
        let e = try #require(fetched.first)
        #expect(e.entryType == .interval)
        #expect(e.distanceMeters == 400)
        #expect(e.durationSeconds == 105)
        #expect(e.heartRateBPM == 172)
        #expect(e.targetDurationSeconds == 100)
        #expect(e.targetRestDurationSeconds == 60)
    }

    @Test("free effort round-trips")
    func freeEffortRoundTrip() throws {
        let context = try makeTestContext()
        let workout = Workout()
        let exercise = Exercise(name: "Warrior II")
        let entry = WorkoutEntry(
            entryIndex: 0,
            entryType: .effort,
            durationSeconds: 60,
            exercise: exercise
        )
        entry.workout = workout
        context.insert(workout)
        context.insert(exercise)
        context.insert(entry)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutEntry>())
        let e = try #require(fetched.first)
        #expect(e.entryType == .effort)
        #expect(e.durationSeconds == 60)
        #expect(e.reps == nil)
        #expect(e.distanceMeters == nil)
    }

    @Test("entry with no exercise is valid")
    func entryWithoutExercise() throws {
        let context = try makeTestContext()
        let workout = Workout()
        let entry = WorkoutEntry(entryIndex: 0, entryType: .effort, durationSeconds: 300)
        entry.workout = workout
        context.insert(workout); context.insert(entry)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutEntry>())
        #expect(fetched.count == 1)
        #expect(fetched[0].exercise == nil)
    }

    @Test("mixed-modality workout — entries with different types coexist")
    func mixedModalityWorkout() throws {
        let context = try makeTestContext()
        let workout = Workout()
        let thruster = Exercise(name: "Thruster")
        let row = Exercise(name: "Row")
        let e0 = WorkoutEntry(entryIndex: 0, entryType: .set, reps: 21, weightKg: 43, exercise: thruster)
        let e1 = WorkoutEntry(entryIndex: 1, entryType: .interval, distanceMeters: 500, exercise: row)
        e0.workout = workout
        e1.workout = workout
        context.insert(workout)
        context.insert(thruster); context.insert(row)
        context.insert(e0); context.insert(e1)
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
        let workout = Workout()
        let e0 = WorkoutEntry(entryIndex: 0, entryType: .set)
        let e1 = WorkoutEntry(entryIndex: 1, entryType: .set)
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
        let w1 = Workout()
        let w2 = Workout()
        let squat = Exercise(name: "Squat")
        let row = Exercise(name: "Row")
        let e1 = WorkoutEntry(entryIndex: 0, entryType: .set, exercise: squat)
        let e2 = WorkoutEntry(entryIndex: 0, entryType: .interval, exercise: row)
        e1.workout = w1
        e2.workout = w2
        context.insert(w1); context.insert(w2)
        context.insert(squat); context.insert(row)
        context.insert(e1); context.insert(e2)
        try context.save()

        let w1Entries = (w1.entries ?? [])
        let w2Entries = (w2.entries ?? [])
        #expect(w1Entries.count == 1)
        #expect(w2Entries.count == 1)
        #expect(w1Entries[0].exercise?.name == "Squat")
        #expect(w2Entries[0].exercise?.name == "Row")
    }
}

@Suite("WorkoutEntry — equipment relationship")
struct WorkoutEntryEquipmentTests {

    @Test("equipment assigned to entry round-trips through save")
    func equipmentRoundTrip() throws {
        let context = try makeTestContext()
        let eq = Equipment(name: "Barbell", category: .strength)
        let workout = Workout()
        let exercise = Exercise(name: "Deadlift")
        let entry = WorkoutEntry(entryIndex: 0, entryType: .set, exercise: exercise)
        entry.workout = workout
        entry.equipment = eq
        context.insert(eq); context.insert(workout); context.insert(exercise); context.insert(entry)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutEntry>())
        #expect(fetched.first?.equipment?.name == "Barbell")
    }

    @Test("deleting equipment nullifies entry.equipment; entry survives")
    func deleteEquipmentNullifiesEntry() throws {
        let context = try makeTestContext()
        let eq = Equipment(name: "Kettlebell", category: .strength)
        let workout = Workout()
        let exercise = Exercise(name: "Swing")
        let entry = WorkoutEntry(entryIndex: 0, entryType: .set, exercise: exercise)
        entry.workout = workout
        entry.equipment = eq
        context.insert(eq); context.insert(workout); context.insert(exercise); context.insert(entry)
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

@Suite("Exercise — defaults and persistence")
struct ExerciseTests {

    @Test("all defaults correct on init")
    func defaults() {
        let ex = Exercise()
        #expect(ex.name == "")
        #expect(ex.notes == nil)
        #expect(ex.isUserDefined == false)
    }

    @Test("insert → save → fetch round-trip")
    func roundTrip() throws {
        let context = try makeTestContext()
        let id = UUID()
        let ex = Exercise(id: id, name: "Bench Press", notes: "Flat barbell", isUserDefined: false)
        context.insert(ex)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Exercise>())
        let e = try #require(fetched.first)
        #expect(e.id == id)
        #expect(e.name == "Bench Press")
        #expect(e.notes == "Flat barbell")
    }

    @Test("Exercise.workoutEntries inverse is populated")
    func workoutEntriesInverse() throws {
        let context = try makeTestContext()
        let workout = Workout()
        let exercise = Exercise(name: "Squat")
        let e0 = WorkoutEntry(entryIndex: 0, entryType: .set, exercise: exercise)
        let e1 = WorkoutEntry(entryIndex: 1, entryType: .set, exercise: exercise)
        e0.workout = workout; e1.workout = workout
        context.insert(workout); context.insert(exercise)
        context.insert(e0); context.insert(e1)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Exercise>())
        let ex = try #require(fetched.first)
        #expect((ex.workoutEntries ?? []).count == 2)
    }

    @Test("deleting Exercise nullifies entry.exercise; entry survives")
    func deleteExerciseNullifiesEntry() throws {
        let context = try makeTestContext()
        let workout = Workout()
        let exercise = Exercise(name: "Deadlift")
        let entry = WorkoutEntry(entryIndex: 0, entryType: .set, exercise: exercise)
        entry.workout = workout
        context.insert(workout); context.insert(exercise); context.insert(entry)
        try context.save()

        context.delete(exercise)
        try context.save()

        let entries = try context.fetch(FetchDescriptor<WorkoutEntry>())
        #expect(entries.count == 1)
        #expect(entries[0].exercise == nil)
    }
}
