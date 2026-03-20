import Testing
import Foundation
import SwiftData
import ThunderCore

@Suite("WorkoutTemplate — default field values")
struct WorkoutTemplateDefaultsTests {

    @Test("name and activityType default to empty string")
    func stringDefaults() {
        let template = WorkoutTemplate()
        #expect(template.name == "")
        #expect(template.activityType == "")
    }

    @Test("notes defaults to nil")
    func notesDefault() {
        #expect(WorkoutTemplate().notes == nil)
    }

    @Test("entries defaults to nil")
    func entriesDefault() {
        #expect((WorkoutTemplate().entries ?? []).isEmpty)
    }
}

@Suite("TemplateEntry — default field values")
struct TemplateEntryDefaultsTests {

    @Test("all defaults correct on init")
    func defaults() {
        let entry = TemplateEntry()
        #expect(entry.entryIndex == 0)
        #expect(entry.groupIndex == nil)
        #expect(entry.exerciseName == "")
        #expect(entry.entryType == .set)
        #expect(entry.targetReps == nil)
        #expect(entry.targetWeightKg == nil)
        #expect(entry.targetDistanceMeters == nil)
        #expect(entry.targetDurationSeconds == nil)
        #expect(entry.targetRestDurationSeconds == nil)
        #expect(entry.notes == nil)
        #expect(entry.template == nil)
        #expect(entry.equipment == nil)
    }
}

@Suite("WorkoutTemplate — persistence")
struct WorkoutTemplatePersistenceTests {

    @Test("entries accessible via WorkoutTemplate.entries relationship")
    func entriesViaRelationship() throws {
        let context = try makeTestContext()

        let template = WorkoutTemplate(name: "Push Day", activityType: "Strength")
        context.insert(template)

        let e0 = TemplateEntry(entryIndex: 0, groupIndex: 0, exerciseName: "Bench Press", entryType: .set, targetReps: 5, targetWeightKg: 80)
        let e1 = TemplateEntry(entryIndex: 1, groupIndex: 0, exerciseName: "Bench Press", entryType: .set, targetReps: 5, targetWeightKg: 85)
        let e2 = TemplateEntry(entryIndex: 2, groupIndex: 1, exerciseName: "Overhead Press", entryType: .set, targetReps: 8, targetWeightKg: 50)
        e0.template = template
        e1.template = template
        e2.template = template
        context.insert(e0); context.insert(e1); context.insert(e2)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutTemplate>())
        let t = try #require(fetched.first)
        let sorted = (t.entries ?? []).sorted { $0.entryIndex < $1.entryIndex }

        #expect(sorted.count == 3)
        #expect(sorted[0].exerciseName == "Bench Press")
        #expect(sorted[0].groupIndex == 0)
        #expect(sorted[1].targetWeightKg == 85)
        #expect(sorted[2].exerciseName == "Overhead Press")
        #expect(sorted[2].groupIndex == 1)
    }

    @Test("deleting WorkoutTemplate cascade-deletes all TemplateEntries")
    func cascadeDelete() throws {
        let context = try makeTestContext()

        let template = WorkoutTemplate(name: "Pull Day")
        let e0 = TemplateEntry(entryIndex: 0, exerciseName: "Pull-up", entryType: .set)
        let e1 = TemplateEntry(entryIndex: 1, exerciseName: "Row", entryType: .interval)
        e0.template = template
        e1.template = template
        context.insert(template); context.insert(e0); context.insert(e1)
        try context.save()

        context.delete(template)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<TemplateEntry>()).isEmpty)
    }

    @Test("two templates with same activityType are fetched independently")
    func sameActivityTypeIndependence() throws {
        let context = try makeTestContext()
        let a = WorkoutTemplate(name: "Monday Push", activityType: "Strength")
        let b = WorkoutTemplate(name: "Thursday Push", activityType: "Strength")
        context.insert(a); context.insert(b)
        try context.save()

        let results = try context.fetch(FetchDescriptor<WorkoutTemplate>())
        #expect(results.count == 2)
        #expect(results[0].id != results[1].id)
    }

    @Test("deleting WorkoutTemplate nullifies plan.template; plan survives")
    func templateDeletionNullifiesPlan() throws {
        let context = try makeTestContext()
        let template = WorkoutTemplate(name: "Push Day")
        let plan = PlannedWorkout(scheduledDate: .now, template: template)
        context.insert(template); context.insert(plan)
        try context.save()

        context.delete(template)
        try context.save()

        let plans = try context.fetch(FetchDescriptor<PlannedWorkout>())
        #expect(plans.count == 1)
        #expect(plans[0].template == nil)
    }

    @Test("Workout.template link round-trips via WorkoutTemplate.workouts")
    func templateWorkoutsInverse() throws {
        let context = try makeTestContext()
        let template = WorkoutTemplate(name: "5K Plan")
        let workout = Workout(activityType: "Running")
        workout.template = template
        context.insert(template); context.insert(workout)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutTemplate>())
        let t = try #require(fetched.first)
        #expect((t.workouts ?? []).count == 1)
        #expect(t.workouts?.first?.activityType == "Running")
    }

    @Test("deleting WorkoutTemplate nullifies Workout.template; workout survives")
    func deleteTemplateNullifiesWorkoutLink() throws {
        let context = try makeTestContext()
        let template = WorkoutTemplate(name: "Easy Run")
        let workout = Workout(activityType: "Running")
        workout.template = template
        context.insert(template); context.insert(workout)
        try context.save()

        context.delete(template)
        try context.save()

        let workouts = try context.fetch(FetchDescriptor<Workout>())
        #expect(workouts.count == 1)
        #expect(workouts[0].template == nil)
    }
}
