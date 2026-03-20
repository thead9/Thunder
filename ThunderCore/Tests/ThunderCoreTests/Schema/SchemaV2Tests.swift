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

    @Test("Models array includes Equipment and WorkoutInterval")
    func modelsIncludeNewTypes() {
        let names = SchemaV2.models.map { String(describing: $0) }
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
    /// plan and confirms all records survive with new optional fields set to nil.
    @Test("V1 data survives migration to V2 with new optional fields nil")
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

        // Release the V1 container before opening with the migration plan.
        // Swift does not expose explicit container disposal, but creating a new
        // container at the same URL with the migration plan is sufficient for
        // testing purposes — the store file is flushed on save above.

        // STEP 2 — Open the same store with the full migration plan (V1→V2).
        let v2Schema = Schema(ThunderMigrationPlan.Current.models, version: ThunderMigrationPlan.Current.versionIdentifier)
        let v2Config = ModelConfiguration(schema: v2Schema, url: storeURL)
        let v2Container = try ModelContainer(
            for: v2Schema,
            migrationPlan: ThunderMigrationPlan.self,
            configurations: v2Config
        )
        let v2Context = ModelContext(v2Container)

        // STEP 3 — Confirm all existing records survived.
        let workouts = try v2Context.fetch(FetchDescriptor<Workout>())
        #expect(workouts.count == 1)
        let w = try #require(workouts.first)
        #expect(w.activityType == "Running")
        #expect(w.notes == "Pre-migration workout")

        // New optional fields must be nil after migration.
        #expect(w.distanceMeters == nil)
        #expect(w.elevationGainMeters == nil)
        #expect(w.averageHeartRateBPM == nil)
        #expect(w.maxHeartRateBPM == nil)
        #expect(w.template == nil)
        #expect((w.intervals ?? []).isEmpty)

        let templates = try v2Context.fetch(FetchDescriptor<WorkoutTemplate>())
        #expect(templates.count == 1)
        let t = try #require(templates.first)
        #expect(t.name == "Easy Run")
        #expect((t.workouts ?? []).isEmpty)

        let sets = try v2Context.fetch(FetchDescriptor<WorkoutSet>())
        #expect(sets.count == 1)
        let s = try #require(sets.first)
        #expect(s.exerciseName == "Jog")
        #expect(s.equipment == nil)

        // New model types must be empty — no records were added before migration.
        let equipment = try v2Context.fetch(FetchDescriptor<Equipment>())
        #expect(equipment.isEmpty)

        let intervals = try v2Context.fetch(FetchDescriptor<WorkoutInterval>())
        #expect(intervals.isEmpty)
    }
}
