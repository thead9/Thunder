import Testing
import SwiftData
import Foundation
@testable import ThunderCore

@Suite("SchemaV2")
struct SchemaV2Tests {

    @Test("Version identifier is 2.0.0")
    func versionIdentifier() {
        #expect(SchemaV2.versionIdentifier == Schema.Version(2, 0, 0))
    }

    @Test("Models array includes all V2 types")
    func modelsIncludeNewTypes() {
        let names = SchemaV2.models.map { String(describing: $0) }
        #expect(names.contains("CardioComponent"))
        #expect(names.contains("Equipment"))
        #expect(names.contains("WorkoutInterval"))
        #expect(names.contains("Workout"))
        #expect(names.contains("WorkoutSet"))
        #expect(names.contains("WorkoutTemplate"))
        #expect(names.contains("TemplateSet"))
        #expect(names.contains("PlannedWorkout"))
    }
}

@Suite("ThunderMigrationPlan — V2")
struct ThunderMigrationPlanV2Tests {

    @Test("Schemas array contains SchemaV1 then SchemaV2 in order")
    func schemasContainsBothVersions() {
        let schemas = ThunderMigrationPlan.schemas
        #expect(schemas.count == 2)
        #expect(String(describing: schemas[0]) == "SchemaV1")
        #expect(String(describing: schemas[1]) == "SchemaV2")
    }

    @Test("Stages array contains one lightweight stage")
    func stagesContainsOneLightweightStage() {
        #expect(ThunderMigrationPlan.stages.count == 1)
    }

    @Test("Current is SchemaV2")
    func currentIsSchemaV2() {
        #expect(ThunderMigrationPlan.Current.versionIdentifier == Schema.Version(2, 0, 0))
    }
}

@Suite("Migration — V1 to V2")
struct MigrationV1ToV2Tests {

    /// Seeds a SchemaV1 on-disk store, then opens it as SchemaV2 via the migration
    /// plan and confirms all records survive. New optional fields and new model
    /// types (CardioComponent, Equipment, WorkoutInterval) are absent — their
    /// absence is the correct post-migration state for pre-existing records.
    @Test("V1 data survives migration to V2 with new optional relationships nil")
    func v1DataSurvivesMigration() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let storeURL = tempDir.appendingPathComponent("thunder.store")

        // STEP 1 — Write SchemaV1 data to disk.
        let v1Schema = Schema(SchemaV1.models, version: SchemaV1.versionIdentifier)
        let v1Config = ModelConfiguration(schema: v1Schema, url: storeURL)
        let v1Container = try ModelContainer(for: v1Schema, configurations: v1Config)
        let v1Context = ModelContext(v1Container)

        let workout = Workout(
            activityType: "Running",
            notes: "Pre-migration workout"
        )
        let template = WorkoutTemplate(name: "Easy Run")
        let set = WorkoutSet(exerciseName: "Jog", setIndex: 0)
        set.workout = workout

        v1Context.insert(workout)
        v1Context.insert(template)
        v1Context.insert(set)
        try v1Context.save()

        // STEP 2 — Open the same store with the full migration plan (V1→V2).
        let v2Schema = Schema(
            ThunderMigrationPlan.Current.models,
            version: ThunderMigrationPlan.Current.versionIdentifier
        )
        let v2Config = ModelConfiguration(schema: v2Schema, url: storeURL)
        let v2Container = try ModelContainer(
            for: v2Schema,
            migrationPlan: ThunderMigrationPlan.self,
            configurations: v2Config
        )
        let v2Context = ModelContext(v2Container)

        // STEP 3 — Confirm existing records survived intact.
        let workouts = try v2Context.fetch(FetchDescriptor<Workout>())
        #expect(workouts.count == 1)
        let w = try #require(workouts.first)
        #expect(w.activityType == "Running")
        #expect(w.notes == "Pre-migration workout")
        // New V2 relationships are nil on migrated records.
        #expect(w.cardio == nil)
        #expect(w.template == nil)

        let templates = try v2Context.fetch(FetchDescriptor<WorkoutTemplate>())
        #expect(templates.count == 1)
        #expect(templates[0].name == "Easy Run")
        #expect((templates[0].workouts ?? []).isEmpty)

        let sets = try v2Context.fetch(FetchDescriptor<WorkoutSet>())
        #expect(sets.count == 1)
        #expect(sets[0].exerciseName == "Jog")
        #expect(sets[0].equipment == nil)

        // New V2 model types have no records — nothing was seeded before migration.
        #expect(try v2Context.fetch(FetchDescriptor<CardioComponent>()).isEmpty)
        #expect(try v2Context.fetch(FetchDescriptor<Equipment>()).isEmpty)
        #expect(try v2Context.fetch(FetchDescriptor<WorkoutInterval>()).isEmpty)
    }
}
