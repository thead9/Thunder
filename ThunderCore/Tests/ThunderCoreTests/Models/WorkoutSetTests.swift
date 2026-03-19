import Testing
import Foundation
import SwiftData
import ThunderCore

@Suite("WorkoutSet — default field values")
struct WorkoutSetDefaultsTests {

    @Test("setIndex defaults to 0")
    func setIndexDefault() {
        let set = WorkoutSet()
        #expect(set.setIndex == 0)
    }

    @Test("exerciseName defaults to empty string")
    func exerciseNameDefault() {
        let set = WorkoutSet()
        #expect(set.exerciseName == "")
    }

    @Test("all optional numeric fields default to nil")
    func optionalFieldsNil() {
        let set = WorkoutSet()
        #expect(set.reps == nil)
        #expect(set.weightKg == nil)
        #expect(set.distanceMeters == nil)
        #expect(set.durationSeconds == nil)
        #expect(set.notes == nil)
        #expect(set.workout == nil)
    }
}

@Suite("WorkoutSet — persistence")
struct WorkoutSetPersistenceTests {

    @Test("sets are accessible via Workout.sets relationship")
    func setsViaRelationship() throws {
        let context = try makeTestContext()

        let workout = Workout(activityType: "Strength")
        context.insert(workout)

        let set0 = WorkoutSet(exerciseName: "Squat", setIndex: 0, reps: 5, weightKg: 100)
        let set1 = WorkoutSet(exerciseName: "Squat", setIndex: 1, reps: 5, weightKg: 102.5)
        let set2 = WorkoutSet(exerciseName: "Deadlift", setIndex: 2, reps: 3, weightKg: 140)
        context.insert(set0)
        context.insert(set1)
        context.insert(set2)
        workout.sets.append(contentsOf: [set0, set1, set2])
        try context.save()

        let fetchedWorkouts = try context.fetch(FetchDescriptor<Workout>())
        let fetchedWorkout = try #require(fetchedWorkouts.first)
        let sortedSets = fetchedWorkout.sets.sorted { $0.setIndex < $1.setIndex }

        #expect(sortedSets.count == 3)
        #expect(sortedSets[0].exerciseName == "Squat")
        #expect(sortedSets[0].weightKg == 100)
        #expect(sortedSets[1].weightKg == 102.5)
        #expect(sortedSets[2].exerciseName == "Deadlift")
    }

    @Test("deleting Workout cascade-deletes all WorkoutSets")
    func cascadeDelete() throws {
        let context = try makeTestContext()

        let workout = Workout(activityType: "Strength")
        context.insert(workout)

        let set0 = WorkoutSet(exerciseName: "Bench", setIndex: 0)
        let set1 = WorkoutSet(exerciseName: "Bench", setIndex: 1)
        context.insert(set0)
        context.insert(set1)
        workout.sets.append(contentsOf: [set0, set1])
        try context.save()

        context.delete(workout)
        try context.save()

        let remainingSets = try context.fetch(FetchDescriptor<WorkoutSet>())
        #expect(remainingSets.isEmpty)
    }

    @Test("sets for a specific workout are isolated from other workouts")
    func setsIsolatedByWorkout() throws {
        let context = try makeTestContext()

        let workoutA = Workout(activityType: "Push")
        let workoutB = Workout(activityType: "Pull")
        context.insert(workoutA)
        context.insert(workoutB)

        let setA0 = WorkoutSet(exerciseName: "Bench", setIndex: 0)
        let setA1 = WorkoutSet(exerciseName: "Overhead Press", setIndex: 1)
        let setB0 = WorkoutSet(exerciseName: "Pull-up", setIndex: 0)
        context.insert(setA0)
        context.insert(setA1)
        context.insert(setB0)
        workoutA.sets.append(contentsOf: [setA0, setA1])
        workoutB.sets.append(setB0)
        try context.save()

        // Accessing sets through the relationship is the idiomatic SwiftData pattern.
        // #Predicate does not support optional-chain comparisons on relationship keys.
        let fetchedWorkouts = try context.fetch(FetchDescriptor<Workout>())
        let fetchedA = try #require(fetchedWorkouts.first { $0.activityType == "Push" })
        let fetchedB = try #require(fetchedWorkouts.first { $0.activityType == "Pull" })

        let setsForA = fetchedA.sets.sorted { $0.setIndex < $1.setIndex }
        let setsForB = fetchedB.sets.sorted { $0.setIndex < $1.setIndex }

        #expect(setsForA.count == 2)
        #expect(setsForA[0].exerciseName == "Bench")
        #expect(setsForA[1].exerciseName == "Overhead Press")
        #expect(setsForB.count == 1)
        #expect(setsForB[0].exerciseName == "Pull-up")
    }
}
