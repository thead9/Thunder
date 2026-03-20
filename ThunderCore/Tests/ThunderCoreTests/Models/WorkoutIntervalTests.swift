import Testing
import Foundation
import SwiftData
@testable import ThunderCore

@Suite("WorkoutInterval — default field values")
struct WorkoutIntervalDefaultsTests {

    @Test("all defaults are set correctly on init")
    func defaults() {
        let before = Date.now
        let interval = WorkoutInterval()
        let after = Date.now

        #expect(interval.exerciseName == "")
        #expect(interval.intervalIndex == 0)
        #expect(interval.targetDistanceMeters == nil)
        #expect(interval.actualDistanceMeters == nil)
        #expect(interval.targetDurationSeconds == nil)
        #expect(interval.actualDurationSeconds == nil)
        #expect(interval.restDurationSeconds == nil)
        #expect(interval.heartRateAverageBPM == nil)
        #expect(interval.notes == nil)
        #expect(interval.workout == nil)
        #expect(interval.equipment == nil)
        #expect(interval.createdAt >= before && interval.createdAt <= after)
    }
}

@Suite("WorkoutInterval — persistence")
struct WorkoutIntervalPersistenceTests {

    @Test("Workout with multiple intervals — fetch via relationship, confirm count and ordering")
    func workoutIntervalsRelationship() throws {
        let context = try makeTestContext()

        let workout = Workout(activityType: "Running")
        let i0 = WorkoutInterval(exerciseName: "400m", intervalIndex: 0, actualDistanceMeters: 400)
        let i1 = WorkoutInterval(exerciseName: "400m", intervalIndex: 1, actualDistanceMeters: 400)
        let i2 = WorkoutInterval(exerciseName: "400m", intervalIndex: 2, actualDistanceMeters: 400)
        i0.workout = workout
        i1.workout = workout
        i2.workout = workout

        context.insert(workout)
        context.insert(i0)
        context.insert(i1)
        context.insert(i2)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Workout>())
        let w = try #require(fetched.first)
        let intervals = (w.intervals ?? []).sorted { $0.intervalIndex < $1.intervalIndex }
        #expect(intervals.count == 3)
        #expect(intervals[0].intervalIndex == 0)
        #expect(intervals[1].intervalIndex == 1)
        #expect(intervals[2].intervalIndex == 2)
    }

    @Test("deleting Workout cascade-deletes all WorkoutInterval records")
    func deleteWorkoutCascadesIntervals() throws {
        let context = try makeTestContext()

        let workout = Workout(activityType: "Rowing")
        let i0 = WorkoutInterval(exerciseName: "500m", intervalIndex: 0)
        let i1 = WorkoutInterval(exerciseName: "500m", intervalIndex: 1)
        i0.workout = workout
        i1.workout = workout

        context.insert(workout)
        context.insert(i0)
        context.insert(i1)
        try context.save()

        context.delete(workout)
        try context.save()

        let remainingIntervals = try context.fetch(FetchDescriptor<WorkoutInterval>())
        #expect(remainingIntervals.isEmpty)
    }

    @Test("WorkoutInterval with equipment round-trips through save")
    func intervalEquipmentRoundTrip() throws {
        let context = try makeTestContext()

        let eq = Equipment(name: "Rowing Machine", category: "Cardio")
        let workout = Workout(activityType: "Rowing")
        let interval = WorkoutInterval(
            exerciseName: "500m",
            intervalIndex: 0,
            actualDistanceMeters: 500,
            heartRateAverageBPM: 155
        )
        interval.workout = workout
        interval.equipment = eq

        context.insert(eq)
        context.insert(workout)
        context.insert(interval)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutInterval>())
        let i = try #require(fetched.first)
        #expect(i.equipment?.name == "Rowing Machine")
        #expect(i.heartRateAverageBPM == 155)
        #expect(i.actualDistanceMeters == 500)
    }
}

@Suite("WorkoutTemplate — workouts inverse relationship")
struct WorkoutTemplateWorkoutsTests {

    @Test("Workout.template link round-trips via WorkoutTemplate.workouts")
    func templateWorkoutsRoundTrip() throws {
        let context = try makeTestContext()

        let template = WorkoutTemplate(name: "5K Intervals")
        let workout = Workout(activityType: "Running")
        workout.template = template

        context.insert(template)
        context.insert(workout)
        try context.save()

        let fetchedTemplates = try context.fetch(FetchDescriptor<WorkoutTemplate>())
        let t = try #require(fetchedTemplates.first)
        #expect((t.workouts ?? []).count == 1)
        #expect(t.workouts?.first?.activityType == "Running")
    }

    @Test("deleting WorkoutTemplate nullifies Workout.template; workout is not deleted")
    func deleteTemplateNullifiesWorkout() throws {
        let context = try makeTestContext()

        let template = WorkoutTemplate(name: "Easy Run")
        let workout = Workout(activityType: "Running")
        workout.template = template

        context.insert(template)
        context.insert(workout)
        try context.save()

        context.delete(template)
        try context.save()

        let remainingWorkouts = try context.fetch(FetchDescriptor<Workout>())
        #expect(remainingWorkouts.count == 1)
        #expect(remainingWorkouts[0].template == nil)

        let remainingTemplates = try context.fetch(FetchDescriptor<WorkoutTemplate>())
        #expect(remainingTemplates.isEmpty)
    }
}
