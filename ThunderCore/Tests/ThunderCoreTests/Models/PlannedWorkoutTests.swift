import Testing
import Foundation
import SwiftData
import ThunderCore

@Suite("PlannedWorkoutStatus")
struct PlannedWorkoutStatusTests {

    @Test("raw value round-trip: planned")
    func rawValuePlanned() {
        #expect(PlannedWorkoutStatus(rawValue: "planned") == .planned)
        #expect(PlannedWorkoutStatus.planned.rawValue == "planned")
    }

    @Test("raw value round-trip: completed")
    func rawValueCompleted() {
        #expect(PlannedWorkoutStatus(rawValue: "completed") == .completed)
        #expect(PlannedWorkoutStatus.completed.rawValue == "completed")
    }

    @Test("raw value round-trip: skipped")
    func rawValueSkipped() {
        #expect(PlannedWorkoutStatus(rawValue: "skipped") == .skipped)
        #expect(PlannedWorkoutStatus.skipped.rawValue == "skipped")
    }

    @Test("unknown raw value returns nil")
    func unknownRawValue() {
        #expect(PlannedWorkoutStatus(rawValue: "unknown") == nil)
    }
}

@Suite("PlannedWorkout — persistence")
struct PlannedWorkoutPersistenceTests {

    @Test("status transitions and workout link persist independently")
    func statusTransitionAndWorkoutLink() throws {
        let context = try makeTestContext()

        let plan = PlannedWorkout(scheduledDate: Date(timeIntervalSince1970: 1_000_000))
        context.insert(plan)
        try context.save()

        let workout = Workout(activityType: "Strength")
        context.insert(workout)
        plan.status = .completed
        plan.workout = workout
        try context.save()

        let plans = try context.fetch(FetchDescriptor<PlannedWorkout>())
        let workouts = try context.fetch(FetchDescriptor<Workout>())
        #expect(plans.count == 1)
        #expect(workouts.count == 1)
        #expect(plans[0].status == .completed)
        #expect(plans[0].workout?.id == workout.id)
    }

    @Test("deleting Workout nullifies plan.workout, plan survives")
    func workoutDeletionNullifiesPlan() throws {
        let context = try makeTestContext()

        let workout = Workout(activityType: "Running")
        context.insert(workout)
        let plan = PlannedWorkout(scheduledDate: .now, status: .completed, workout: workout)
        context.insert(plan)
        try context.save()

        context.delete(workout)
        try context.save()

        let plans = try context.fetch(FetchDescriptor<PlannedWorkout>())
        #expect(plans.count == 1)
        #expect(plans[0].workout == nil)
    }

    @Test("FetchDescriptor predicate filters by status")
    func fetchByStatus() throws {
        let context = try makeTestContext()

        let planned   = PlannedWorkout(scheduledDate: Date(timeIntervalSince1970: 1_000), status: .planned)
        let completed = PlannedWorkout(scheduledDate: Date(timeIntervalSince1970: 2_000), status: .completed)
        let skipped   = PlannedWorkout(scheduledDate: Date(timeIntervalSince1970: 3_000), status: .skipped)
        context.insert(planned)
        context.insert(completed)
        context.insert(skipped)
        try context.save()

        let skippedRaw = PlannedWorkoutStatus.skipped.rawValue
        let descriptor = FetchDescriptor<PlannedWorkout>(
            predicate: #Predicate { $0.statusRawValue == skippedRaw }
        )
        let results = try context.fetch(descriptor)
        #expect(results.count == 1)
        #expect(results[0].status == .skipped)
    }
}
