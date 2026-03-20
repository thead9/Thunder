import Testing
import Foundation
import SwiftData
@testable import ThunderCore

@Suite("Equipment — default field values")
struct EquipmentDefaultsTests {

    @Test("all defaults are set correctly on init")
    func defaults() {
        let before = Date.now
        let eq = Equipment()
        let after = Date.now

        #expect(eq.name == "")
        #expect(eq.category == .other)
        #expect(eq.notes == nil)
        #expect(eq.isUserDefined == false)
        #expect(eq.createdAt >= before && eq.createdAt <= after)
    }

    @Test("isUserDefined true when explicitly set")
    func isUserDefined() {
        let eq = Equipment(name: "Custom Bar", isUserDefined: true)
        #expect(eq.isUserDefined == true)
        #expect(eq.name == "Custom Bar")
    }

    @Test("category enum round-trips for all cases")
    func categoryRoundTrip() {
        for category in EquipmentCategory.allCases {
            let eq = Equipment(category: category)
            #expect(eq.category == category)
        }
    }
}

@Suite("Equipment — persistence")
struct EquipmentPersistenceTests {

    @Test("insert → save → fetch round-trip preserves all fields including category enum")
    func roundTrip() throws {
        let context = try makeTestContext()
        let id = UUID()
        let created = Date(timeIntervalSince1970: 2_000_000)

        let eq = Equipment(
            id: id,
            name: "Barbell",
            category: .strength,
            notes: "Standard 20 kg bar",
            isUserDefined: false,
            createdAt: created
        )
        context.insert(eq)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Equipment>())
        #expect(fetched.count == 1)
        let e = try #require(fetched.first)
        #expect(e.id == id)
        #expect(e.name == "Barbell")
        #expect(e.category == .strength)
        #expect(e.notes == "Standard 20 kg bar")
        #expect(e.isUserDefined == false)
        #expect(e.createdAt == created)
    }
}

@Suite("Equipment — relationships")
struct EquipmentRelationshipTests {

    @Test("Equipment assigned to WorkoutSet round-trips through save")
    func equipmentWorkoutSetRoundTrip() throws {
        let context = try makeTestContext()

        let eq = Equipment(name: "Dumbbells", category: .strength)
        let workout = Workout(activityType: "Strength")
        let set = WorkoutSet(exerciseName: "Curl", setIndex: 0)
        set.workout = workout
        set.equipment = eq

        context.insert(eq)
        context.insert(workout)
        context.insert(set)
        try context.save()

        let fetchedSets = try context.fetch(FetchDescriptor<WorkoutSet>())
        let s = try #require(fetchedSets.first)
        #expect(s.equipment?.name == "Dumbbells")
    }

    @Test("deleting Equipment nullifies WorkoutSet.equipment; set is not deleted")
    func deleteEquipmentNullifiesSet() throws {
        let context = try makeTestContext()

        let eq = Equipment(name: "Kettlebell", category: .strength)
        let workout = Workout(activityType: "Strength")
        let set = WorkoutSet(exerciseName: "Swing", setIndex: 0)
        set.workout = workout
        set.equipment = eq

        context.insert(eq)
        context.insert(workout)
        context.insert(set)
        try context.save()

        context.delete(eq)
        try context.save()

        let remainingSets = try context.fetch(FetchDescriptor<WorkoutSet>())
        #expect(remainingSets.count == 1)
        #expect(remainingSets[0].equipment == nil)

        let remainingEquipment = try context.fetch(FetchDescriptor<Equipment>())
        #expect(remainingEquipment.isEmpty)
    }

    @Test("Equipment assigned to TemplateSet round-trips through save")
    func equipmentTemplateSetRoundTrip() throws {
        let context = try makeTestContext()

        let eq = Equipment(name: "Cable Machine", category: .strength)
        let template = WorkoutTemplate(name: "Push Day")
        let tset = TemplateSet(exerciseName: "Tricep Pushdown", setIndex: 0)
        tset.template = template
        tset.equipment = eq

        context.insert(eq)
        context.insert(template)
        context.insert(tset)
        try context.save()

        let fetchedSets = try context.fetch(FetchDescriptor<TemplateSet>())
        let ts = try #require(fetchedSets.first)
        #expect(ts.equipment?.name == "Cable Machine")
    }
}
