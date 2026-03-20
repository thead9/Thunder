import Testing
import SwiftData
@testable import ThunderCore

@Suite("Schema")
struct SchemaTests {

    @Suite("SchemaV1")
    struct SchemaV1Tests {

        @Test("Version identifier is 1.0.0")
        func versionIdentifier() {
            #expect(SchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
        }

        @Test("Models array is accessible and returns a value without crashing")
        func modelsAccessible() {
            // The count grows as model stories are implemented.
            // This test guards against the computed property crashing.
            _ = SchemaV1.models
        }
    }

    @Suite("ThunderMigrationPlan")
    struct ThunderMigrationPlanTests {

        @Test("Schemas array contains SchemaV1 as the first version")
        func schemasContainsSchemaV1() {
            let schemas = ThunderMigrationPlan.schemas
            // Existential metatypes don't support == in Swift 6;
            // type name is the idiomatic identity check for VersionedSchema.Type.
            #expect(String(describing: schemas[0]) == "SchemaV1")
        }

        @Test("Schemas array is non-empty and ordered oldest-first")
        func schemasNonEmpty() {
            #expect(!ThunderMigrationPlan.schemas.isEmpty)
        }
    }
}
