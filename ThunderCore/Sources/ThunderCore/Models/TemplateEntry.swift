import Foundation
import SwiftData

/// A single planned effort within a workout template.
///
/// `TemplateEntry` is the template counterpart to `WorkoutEntry`. Where
/// `WorkoutEntry` records what actually happened, `TemplateEntry` records
/// what the template prescribes. Fields are target-only — there are no
/// actuals here.
///
/// ## Grouping
/// `groupIndex` works identically to `WorkoutEntry.groupIndex` — entries
/// sharing a `groupIndex` represent one logical exercise block in the template.
///
/// ## CloudKit
/// All attributes are optional or carry declaration-site defaults.
@Model
public final class TemplateEntry {
    public var id: UUID = UUID()
    public var entryIndex: Int = 0
    public var groupIndex: Int?
    public var exerciseName: String = ""
    public var entryType: WorkoutEntryType = WorkoutEntryType.set
    public var notes: String?

    // MARK: Targets

    public var targetReps: Int?
    public var targetWeightKg: Double?
    public var targetDistanceMeters: Double?
    public var targetDurationSeconds: Double?
    public var targetRestDurationSeconds: Double?

    public var createdAt: Date = Date.now

    /// The template this entry belongs to.
    ///
    /// Delete rule is `.nullify` — the reference becomes `nil` rather than
    /// dangling if the parent is removed without triggering the cascade.
    /// The cascade that deletes entries when a template is deleted is declared
    /// on `WorkoutTemplate.entries`.
    @Relationship(deleteRule: .nullify, inverse: \WorkoutTemplate.entries)
    public var template: WorkoutTemplate?

    /// The equipment prescribed for this effort, if any.
    ///
    /// Delete rule is `.nullify` — removing equipment does not remove the entry.
    @Relationship(deleteRule: .nullify, inverse: \Equipment.templateEntries)
    public var equipment: Equipment?

    public init(
        id: UUID = UUID(),
        entryIndex: Int = 0,
        groupIndex: Int? = nil,
        exerciseName: String = "",
        entryType: WorkoutEntryType = .set,
        notes: String? = nil,
        targetReps: Int? = nil,
        targetWeightKg: Double? = nil,
        targetDistanceMeters: Double? = nil,
        targetDurationSeconds: Double? = nil,
        targetRestDurationSeconds: Double? = nil,
        createdAt: Date = .now,
        equipment: Equipment? = nil
    ) {
        self.id = id
        self.entryIndex = entryIndex
        self.groupIndex = groupIndex
        self.exerciseName = exerciseName
        self.entryType = entryType
        self.notes = notes
        self.targetReps = targetReps
        self.targetWeightKg = targetWeightKg
        self.targetDistanceMeters = targetDistanceMeters
        self.targetDurationSeconds = targetDurationSeconds
        self.targetRestDurationSeconds = targetRestDurationSeconds
        self.createdAt = createdAt
        self.equipment = equipment
    }
}
