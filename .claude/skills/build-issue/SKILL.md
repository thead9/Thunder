---
name: build-issue
description: >
  Full Thunder development cycle: implement an issue, run a persona review,
  correct findings, then open a PR. Use this skill whenever the user says
  "/build-issue", "build issue #N", "implement and review", or any variant of
  "implement → review → retro → PR". Always invoke this skill for Thunder
  development work — do not handle these requests ad-hoc.
---

# build-issue — Thunder Development Cycle

This skill encodes the complete, repeatable workflow for taking a GitHub issue
from "open" to "PR ready" on the Thunder project (`thead9/Thunder`).

The four phases always run in order:

1. **Implement** — write the code
2. **Review** — all 7 personas assess the changes
3. **Retro** — correct every finding; flag persona file updates
4. **PR** — open the pull request

---

## Phase 1 — Implement

### Identify the issue

- If the user named an issue number (e.g. `/build-issue #7`), fetch it:
  ```
  gh issue view <N> --repo thead9/Thunder
  ```
- If no issue was specified, list open issues on the current milestone and
  pick the next unstarted one that has no blocking dependencies:
  ```
  gh issue list --repo thead9/Thunder --state open --milestone "<current>"
  ```
  Announce which issue you chose and why before starting.

### Branch

Create a feature branch from `main` named after the issue:
```
git checkout -b <label>-<N>-<short-slug>
# e.g.  data-7-workout-model
```

### Implement

Follow the project's conventions exactly:

- **Swift 6**, strict concurrency, no MVVM
- **SwiftUI** only — no UIKit
- **SwiftData** with versioned schemas; all new models go in `SchemaV1` (or the
  current schema version); consumer code references `ThunderMigrationPlan.Current`,
  never a specific `SchemaVN` type directly
- **Apple APIs first** — evaluate before any third-party dependency
- Views bind directly via `@Query` / `@Bindable` — no view models
- Tests use `makeTestContext()` from `TestHelpers.swift` and the Swift Testing
  framework (`@Test`, `@Suite`, `#expect`)
- Run the build and tests before moving to Phase 2

---

## Phase 2 — Persona Review

Read every persona file in `/Agent Personas/` before writing a single line of
review. The files are the authoritative definitions — do not rely on memory.

Review the implementation from each persona's point of view:

| Persona | File | Primary lens |
|---|---|---|
| Program Manager | `Program Manager.md` | Coherence, cross-domain risk, foundational premise |
| Data Architect | `Data Architect.md` | Schema correctness, migration safety, CloudKit integrity |
| iOS Engineer | `iOS Engineer.md` | Swift 6, SwiftUI patterns, Apple API use, no MVVM |
| Quality Assurance | `Quality Assurance.md` | Test coverage, in-memory containers, migration gates |
| UI Designer | `UI Designer.md` | iOS 26 / Liquid Glass, stock components, simplicity |
| Finance | `Finance.md` | RevenueCat integration, ethical monetisation, free tier |
| Product Owner — Training | `Product Owner - Training.md` | Workout UX, fast logging, HealthKit |

For each persona, write a short section:

```
### <Persona Name>
**Status:** ✅ Approved  |  ⚠️ Concerns  |  🚫 Blocking
<findings, or "No concerns." if clean>
```

Only personas whose domain is touched by the change need substantive findings.
The Program Manager and QA always review everything.

---

## Phase 3 — Retro

### Correct findings

Work through every ⚠️ and 🚫 finding from Phase 2 in order of severity
(blocking first). For each:

1. Explain what you're changing and why
2. Make the change
3. Mark the finding resolved in your notes

After all corrections, do a final build + test run to confirm nothing broke.

### Persona file updates

If any finding reveals that a persona's standards are **incomplete or
outdated** — meaning the finding couldn't have been predicted from reading the
persona file as written — flag it explicitly:

```
🔔 Persona Update Candidate
Persona: <name>
Gap: <what the file currently says / doesn't say>
Proposed addition: <the specific text you'd add>
```

**Never edit a persona file without explicit user approval.** Present the
flag, then wait. The user will say yes or no.

---

## Phase 4 — PR

Once all findings are resolved and the user has responded to any persona
update flags:

1. Commit all changes with a clear message referencing the issue:
   ```
   git commit -m "$(cat <<'EOF'
   <type>(<scope>): <summary>

   Closes #<N>

   Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
   EOF
   )"
   ```

2. Push the branch and open the PR:
   ```
   gh pr create \
     --repo thead9/Thunder \
     --title "<short title>" \
     --body "$(cat <<'EOF'
   ## Summary
   <bullet points>

   ## Persona Review
   <one line per persona: ✅ / ⚠️ resolved / N/A>

   ## Test plan
   <checklist>

   Closes #<N>

   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   EOF
   )"
   ```

3. Return the PR URL.

---

## Quick reference — what never changes

- Persona files live in `/Users/thomasheadley/Developer/Thunder/Agent Personas/`
- Repo: `thead9/Thunder`
- Shared data layer: `ThunderCore` local Swift package
- Schema alias: `ThunderMigrationPlan.Current` (never reference `SchemaVN` directly in consumers)
- Test helper: `makeTestContext()` in `ThunderCoreTests/Helpers/TestHelpers.swift`
- Project gen: `xcodegen` — never hand-edit `.pbxproj`
