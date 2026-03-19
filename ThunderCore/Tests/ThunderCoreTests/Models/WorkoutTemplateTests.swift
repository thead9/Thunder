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
        let template = WorkoutTemplate()
        #expect(template.notes == nil)
    }

    @Test("sets defaults to empty array")
    func setsDefault() {
        let template = WorkoutTemplate()
        #expect(template.sets.isEmpty)
    }
}

@Suite("TemplateSet — default field values")
struct TemplateSetDefaultsTests {

    @Test("setIndex defaults to 0")
    func setIndexDefault() {
        let set = TemplateSet()
        #expect(set.setIndex == 0)
    }

    @Test("exerciseName defaults to empty string")
    func exerciseNameDefault() {
        let set = TemplateSet()
        #expect(set.exerciseName == "")
    }

    @Test("all optional target fields default to nil")
    func optionalFieldsNil() {
        let set = TemplateSet()
        #expect(set.targetReps == nil)
        #expect(set.targetWeightKg == nil)
        #expect(set.targetDistanceMeters == nil)
        #expect(set.targetDurationSeconds == nil)
        #expect(set.notes == nil)
        #expect(set.template == nil)
    }
}

@Suite("WorkoutTemplate — persistence")
struct WorkoutTemplatePersistenceTests {

    @Test("sets are accessible via WorkoutTemplate.sets relationship")
    func setsViaRelationship() throws {
        let context = try makeTestContext()

        let template = WorkoutTemplate(name: "Push Day", activityType: "Strength")
        context.insert(template)

        let set0 = TemplateSet(exerciseName: "Bench Press", setIndex: 0, targetReps: 5, targetWeightKg: 80)
        let set1 = TemplateSet(exerciseName: "Bench Press", setIndex: 1, targetReps: 5, targetWeightKg: 85)
        let set2 = TemplateSet(exerciseName: "Overhead Press", setIndex: 2, targetReps: 8, targetWeightKg: 50)
        context.insert(set0)
        context.insert(set1)
        context.insert(set2)
        template.sets.append(contentsOf: [set0, set1, set2])
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutTemplate>())
        let fetchedTemplate = try #require(fetched.first)
        let sortedSets = fetchedTemplate.sets.sorted { $0.setIndex < $1.setIndex }

        #expect(sortedSets.count == 3)
        #expect(sortedSets[0].exerciseName == "Bench Press")
        #expect(sortedSets[0].targetWeightKg == 80)
        #expect(sortedSets[1].targetWeightKg == 85)
        #expect(sortedSets[2].exerciseName == "Overhead Press")
    }

    @Test("deleting WorkoutTemplate cascade-deletes all TemplateSets")
    func cascadeDelete() throws {
        let context = try makeTestContext()

        let template = WorkoutTemplate(name: "Pull Day")
        context.insert(template)

        let set0 = TemplateSet(exerciseName: "Pull-up", setIndex: 0)
        let set1 = TemplateSet(exerciseName: "Row", setIndex: 1)
        context.insert(set0)
        context.insert(set1)
        template.sets.append(contentsOf: [set0, set1])
        try context.save()

        context.delete(template)
        try context.save()

        let remainingSets = try context.fetch(FetchDescriptor<TemplateSet>())
        #expect(remainingSets.isEmpty)
    }

    @Test("two templates with same activityType are fetched independently")
    func sameActivityTypeIndependence() throws {
        let context = try makeTestContext()

        let a = WorkoutTemplate(name: "Monday Push", activityType: "Strength")
        let b = WorkoutTemplate(name: "Thursday Push", activityType: "Strength")
        context.insert(a)
        context.insert(b)
        try context.save()

        let results = try context.fetch(FetchDescriptor<WorkoutTemplate>())
        #expect(results.count == 2)
        #expect(results[0].id != results[1].id)
    }
}
