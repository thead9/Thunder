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
        #expect(interval.cardio == nil)
        #expect(interval.equipment == nil)
        #expect(interval.createdAt >= before && interval.createdAt <= after)
    }
}

@Suite("CardioComponent — default field values")
struct CardioComponentDefaultsTests {

    @Test("all defaults are set correctly on init")
    func defaults() {
        let before = Date.now
        let c = CardioComponent()
        let after = Date.now

        #expect(c.distanceMeters == nil)
        #expect(c.elevationGainMeters == nil)
        #expect(c.averageHeartRateBPM == nil)
        #expect(c.maxHeartRateBPM == nil)
        #expect(c.workout == nil)
        #expect(c.intervals == nil)
        #expect(c.createdAt >= before && c.createdAt <= after)
    }
}

@Suite("CardioComponent — persistence")
struct CardioComponentPersistenceTests {

    @Test("CardioComponent attached to Workout round-trips through save")
    func roundTrip() throws {
        let context = try makeTestContext()

        let workout = Workout(activityType: "Running")
        let cardio = CardioComponent(
            distanceMeters: 5000,
            elevationGainMeters: 42,
            averageHeartRateBPM: 148,
            maxHeartRateBPM: 172
        )
        workout.cardio = cardio

        context.insert(workout)
        context.insert(cardio)
        try context.save()

        let fetchedWorkouts = try context.fetch(FetchDescriptor<Workout>())
        let w = try #require(fetchedWorkouts.first)
        #expect(w.cardio?.distanceMeters == 5000)
        #expect(w.cardio?.elevationGainMeters == 42)
        #expect(w.cardio?.averageHeartRateBPM == 148)
        #expect(w.cardio?.maxHeartRateBPM == 172)
    }

    @Test("deleting Workout cascade-deletes CardioComponent and all its intervals")
    func deleteWorkoutCascadesComponentAndIntervals() throws {
        let context = try makeTestContext()

        let workout = Workout(activityType: "Rowing")
        let cardio = CardioComponent(distanceMeters: 2000)
        let i0 = WorkoutInterval(exerciseName: "500m", intervalIndex: 0)
        let i1 = WorkoutInterval(exerciseName: "500m", intervalIndex: 1)
        workout.cardio = cardio
        i0.cardio = cardio
        i1.cardio = cardio

        context.insert(workout)
        context.insert(cardio)
        context.insert(i0)
        context.insert(i1)
        try context.save()

        context.delete(workout)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<CardioComponent>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<WorkoutInterval>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<Workout>()).isEmpty)
    }

    @Test("Workout with intervals — fetch via component relationship, confirm count and ordering")
    func workoutIntervalsViaComponent() throws {
        let context = try makeTestContext()

        let workout = Workout(activityType: "Running")
        let cardio = CardioComponent(distanceMeters: 1600)
        let i0 = WorkoutInterval(exerciseName: "400m", intervalIndex: 0, actualDistanceMeters: 400)
        let i1 = WorkoutInterval(exerciseName: "400m", intervalIndex: 1, actualDistanceMeters: 400)
        let i2 = WorkoutInterval(exerciseName: "400m", intervalIndex: 2, actualDistanceMeters: 400)
        workout.cardio = cardio
        i0.cardio = cardio
        i1.cardio = cardio
        i2.cardio = cardio

        context.insert(workout)
        context.insert(cardio)
        context.insert(i0)
        context.insert(i1)
        context.insert(i2)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Workout>())
        let w = try #require(fetched.first)
        let intervals = (w.cardio?.intervals ?? []).sorted { $0.intervalIndex < $1.intervalIndex }
        #expect(intervals.count == 3)
        #expect(intervals[0].intervalIndex == 0)
        #expect(intervals[1].intervalIndex == 1)
        #expect(intervals[2].intervalIndex == 2)
    }

    @Test("WorkoutInterval with equipment round-trips through save")
    func intervalEquipmentRoundTrip() throws {
        let context = try makeTestContext()

        let eq = Equipment(name: "Rowing Machine", category: .cardio)
        let workout = Workout(activityType: "Rowing")
        let cardio = CardioComponent(distanceMeters: 500)
        let interval = WorkoutInterval(
            exerciseName: "500m",
            intervalIndex: 0,
            actualDistanceMeters: 500,
            heartRateAverageBPM: 155
        )
        workout.cardio = cardio
        interval.cardio = cardio
        interval.equipment = eq

        context.insert(eq)
        context.insert(workout)
        context.insert(cardio)
        context.insert(interval)
        try context.save()

        let fetchedIntervals = try context.fetch(FetchDescriptor<WorkoutInterval>())
        let i = try #require(fetchedIntervals.first)
        #expect(i.equipment?.name == "Rowing Machine")
        #expect(i.heartRateAverageBPM == 155)
        #expect(i.actualDistanceMeters == 500)
    }

    @Test("strength-only Workout has nil cardio component")
    func strengthWorkoutHasNilCardio() throws {
        let context = try makeTestContext()

        let workout = Workout(activityType: "Strength")
        context.insert(workout)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Workout>())
        let w = try #require(fetched.first)
        #expect(w.cardio == nil)
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
