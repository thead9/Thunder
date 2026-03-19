# Training App — Use Cases

> Generated 2026-03-19. Review, edit, and return to Claude to generate GitHub issues.

---

## Persona Synthesis

- **Program Manager**: Use cases must feed the shared data layer. The suite premise lives or dies on Training contributing clean, structured data about physical effort that other apps can observe.
- **Product Owner — Training**: The core loop is everything. Logging must be fast. Plans are optional. HealthKit is not. Every use case earns its place by serving that loop or reducing friction in sustaining it.
- **UI Designer**: iOS 26 Liquid Glass, stock components first. Speed of interaction is a design constraint, not just a product one.
- **Data Architect**: CloudKit sync, versioned schema, no assumptions that require a backend beyond CloudKit.
- **Finance**: Logging and HealthKit are free. Advanced analytics and planning are subscription territory.

---

## UC-1: Log a Completed Workout (Fast Path)

**Actor:** User who just finished training
**Goal:** Record that a workout happened, with the minimum viable detail, as quickly as possible
**Precondition:** User opens the app after finishing a session

**Flow:**
1. User taps "Log Workout"
2. Selects activity type (run, lift, swim, yoga, etc.)
3. Date/time defaults to now; user adjusts if needed
4. Duration is entered (or imported from Apple Watch / HealthKit)
5. Optional: adds a note ("felt strong", "cut it short")
6. Saves — workout is written to the shared store and HealthKit simultaneously

**Success:** The session is recorded in under 30 seconds with no required fields beyond activity type and date
**Failure condition:** Any required field that isn't date or activity type is a design failure
**Tier:** Free

---

## UC-2: Log a Structured Workout (Sets / Reps / Weight / Distance)

**Actor:** User who trains with specific exercises and wants to track volume
**Goal:** Record the exact work done — exercises, sets, reps, load or distance
**Precondition:** User is logging or has just finished a structured session

**Flow:**
1. User initiates workout log (from UC-1 or from an active session)
2. Adds exercises to the session — searched or selected from recent
3. For each exercise: optionally tags the equipment used (e.g., barbell, dumbbells, cable machine) — see UC-17
4. Logs sets with reps and weight (or distance/time for cardio-style movements)
5. Can add sets inline without leaving the exercise context
6. Saves the full session

**Success:** The structured data is captured at the exercise/set level, linked to the parent workout. Equipment used is recorded alongside the exercise.
**Design note (UI Designer):** Adding a set should be a single tap or swipe — never a modal push. The exercise list and set logging should feel like a single continuous surface. Equipment tagging should be a quick optional step, not a required gate before logging sets.
**Data note (Data Architect):** Exercise entries and sets belong to their workout. The schema must support variable exercise structure (strength vs. cardio vs. bodyweight) without forcing a single shape on all workout types. Equipment association lives at the exercise-entry level, not the workout level.
**Tier:** Free (basic structured logging); advanced analytics on that data is subscription

---

## UC-3: Log a Workout from a Template

**Actor:** User who repeats a similar workout (e.g., "Monday Push Day")
**Goal:** Start from a known structure rather than building from scratch every time
**Precondition:** At least one template exists

**Flow:**
1. User taps "Log Workout" → selects "From Template"
2. Browses or searches templates
3. Selects a template — the workout is pre-populated with the template's exercises
4. User adjusts weights, reps, or exercises to reflect what actually happened
5. Saves as a completed workout

**Success:** The friction of repeating a common workout structure is eliminated; the log still reflects actual performance, not the template
**Product note:** The template is a starting point, not a prescription. It must be easy to deviate without losing the starting structure.
**Tier:** Free

---

## UC-4: Save a Workout as a Template

**Actor:** User who has logged a workout they want to repeat
**Goal:** Capture the structure of a good session for future reuse
**Precondition:** A completed workout or a new template being built from scratch

**Flow:**
1. From a completed workout log, user selects "Save as Template"
2. Names the template
3. Template is saved with the exercise structure but not the specific performance data (weights/reps from that session become defaults, not locked values)

**Alternate flow:** User creates a template from scratch (no prior workout) — same experience, starting from empty rather than a log

**Success:** The template is available in UC-3 the next time the user logs a similar session
**Tier:** Free

---

## UC-5: Plan a Future Workout

**Actor:** User who structures their training in advance
**Goal:** Create a scheduled workout intention — what they plan to do and when
**Precondition:** None required

**Flow:**
1. User creates a planned workout — activity type, target date, optional target duration/structure
2. Planned workout appears in the calendar or schedule view
3. On the target date, the planned workout appears as a prompt when the user opens the app
4. User can log against it (UC-6) or mark it as skipped (UC-7)

**Success:** The plan is captured and visible; the user is prompted at the right time without being nagged
**Product note (Training PO):** A skipped plan is data. The app should never hide or minimize skips — intent vs. reality is one of the most honest things a training log shows.
**Tier:** Subscription — planning is a power feature

---

## UC-6: Complete a Planned Workout

**Actor:** User who planned a workout and has now done it
**Goal:** Log the actual session against the planned one, preserving both the intent and the result
**Precondition:** A planned workout exists for today (or a recent date)

**Flow:**
1. User opens app; planned workout is surfaced (notification or in-app prompt)
2. User taps "Log this workout"
3. If the plan had structure (exercises), it pre-populates the log (like UC-3)
4. User adjusts to reflect reality and saves
5. The planned workout is marked as completed; the log entry is linked to the plan

**Success:** Both the plan and the actual are stored; the link between them is preserved for future trend analysis
**Data note (Data Architect):** The link between a plan and its log entry must be explicit in the schema — not inferred from date proximity. A plan can be completed late; a log can reference a plan that was originally for a different date.
**Tier:** Subscription (requires plan to exist)

---

## UC-7: Record a Skipped Workout

**Actor:** User who planned a workout but did not do it
**Goal:** Acknowledge the skip honestly without penalty or judgment
**Precondition:** A planned workout exists that was not completed

**Flow:**
1. User opens app on or after the planned date
2. The planned workout appears as unresolved
3. User marks it as skipped — optionally adds a reason ("travel", "sick", "rest day by choice")
4. The plan is resolved; the skip is stored as data

**Success:** The skip is recorded without shame UI. The calendar shows the plan and its outcome honestly.
**Product note:** The app does not treat skips as failures. It treats them as information. No streak counters that break. No red X. Data only.
**Tier:** Subscription (requires plan to exist)

---

## UC-8: Browse Workout History

**Actor:** Any user
**Goal:** See a chronological record of past workouts
**Precondition:** At least one logged workout

**Flow:**
1. User navigates to history view
2. Sees a list of past workouts, most recent first — date, activity type, duration, optional summary
3. Taps a workout to see full detail — exercises, sets, notes
4. Can filter by activity type or date range

**Success:** Finding any past workout is a 2-tap operation
**UI note (UI Designer):** The list uses stock `List` with clear visual hierarchy. Date grouping (by week or month) is preferred over flat chronological. The detail view is a `NavigationStack` push — no sheets for detail content.
**Tier:** Free (full history); advanced filtering/search may be subscription

---

## UC-9: View Training Trends

**Actor:** User who wants to understand patterns over time
**Goal:** See whether their training is consistent, how volume has changed, what activities dominate
**Precondition:** Sufficient history to show meaningful trends (a few weeks minimum)

**Flow:**
1. User navigates to trends/analytics view
2. Sees charts: workouts per week, total volume over time, activity type distribution
3. Can adjust time range (4 weeks, 3 months, 1 year)
4. Individual data points are tappable to navigate back to that session

**Success:** The user learns something about their training patterns that a list view would not show
**Design note (UI Designer):** Swift Charts only. Every chart earns its place — no decorative visualization. The question each chart answers is legible without a legend or explanation.
**Data note (Data Architect):** Trend queries should be derivable from stored workout data without additional computed fields.
**Tier:** Basic trends (workouts/week, activity distribution) free; advanced analytics (volume periodization, load progression per exercise) subscription

---

## UC-10: Import a Workout from HealthKit

**Actor:** User who completed a workout in another app (Strava, Apple Fitness+, Garmin, Apple Watch native)
**Goal:** Pull that session into Training so their history is complete
**Precondition:** Workout exists in HealthKit from another source; user has granted HealthKit permission

**Flow:**
1. User opens app; an import suggestion appears (or user navigates to "Import from Health")
2. App surfaces recent HealthKit workouts not already in Training
3. User selects a session to import
4. The workout is added to Training's history — activity type, duration, date, and any metrics the HealthKit record carries
5. User can add notes or structure after import

**Success:** The user's training history in Thunder reflects all their training, regardless of which app they used to track it
**Product note:** Training does not compete with other tracking apps. It participates in the ecosystem. A user who runs with Strava and lifts with Training should have one complete history.
**Tier:** Free

---

## UC-11: Write a Workout to HealthKit

**Actor:** User who logged a workout in Training
**Goal:** Have that workout reflected in Apple Health so the broader health picture is complete
**Precondition:** User has granted HealthKit write permission

**Flow:**
1. User saves a workout log
2. Training writes the workout to HealthKit automatically — activity type, duration, date, calories if available
3. No user action required after saving

**Success:** The workout appears in Health.app and contributes to Activity rings, health trends, and other apps that read from HealthKit
**Product note:** This is not optional and not buried in preferences. It is the default behavior that the user can revoke via iOS Settings if they choose.
**Tier:** Free

---

## UC-12: Onboard a New User

**Actor:** First-time user
**Goal:** Understand what the app does and log their first workout with zero friction
**Precondition:** Fresh install; no existing data

**Flow:**
1. User opens app for the first time
2. App requests HealthKit permission with clear explanation of what it reads and writes
3. No "create a program" or "set a goal" step — the app is immediately usable
4. A single clear CTA: "Log your first workout"
5. User completes UC-1 — the app is now useful

**Success:** A user can log their first workout within 60 seconds of installing, without reading anything
**Design note (UI Designer):** The empty state is intentional and inviting, not a list of prompts and suggestions. One clear action. The app does not ask what the user's goals are, fitness level, or what program they follow.
**Product note:** The app earns the right to more information over time. It does not demand it upfront.
**Tier:** Free

---

## UC-13: Contribute Training Data to the Thunder Suite

**Actor:** Thunder suite as a whole; other apps reading Training's data
**Goal:** Training data is available to other apps via the shared data layer — sleep, mood, and other apps can observe training load and surface connections
**Precondition:** The user uses multiple Thunder apps

**Flow:**
1. User logs a heavy training week in Training
2. A future sleep app in the suite observes training volume for the week
3. A future mood/journal app can surface correlations ("Heavy training weeks correlate with lower mood scores on Thursdays")
4. No configuration required from the user — the shared data layer makes this possible structurally

**Success:** Training data does not live in a silo. It contributes to the whole-person picture that is the founding premise of Thunder.
**Program Manager note:** This is the use case that justifies building a suite rather than a standalone app. Every schema decision in Training should be made with this use case in mind.
**Tier:** Implicit — free by virtue of being in the shared layer

---

## UC-14: Log a Cardio Workout

**Actor:** User who completed a run, bike ride, row, swim, or other distance/time-based session
**Goal:** Record cardio-specific metrics — distance, pace, heart rate, elevation — beyond what the fast-path log (UC-1) captures
**Precondition:** User opens the app after a cardio session

**Flow:**
1. User taps "Log Workout" and selects a cardio activity type (run, ride, swim, row, hike, etc.)
2. Date/time defaults to now; duration is entered or pulled from Apple Watch / HealthKit
3. User enters distance (with unit preference — miles or km set once in preferences)
4. Pace or speed is computed automatically from distance + duration; user can override if needed
5. Heart rate fields (average, max) are populated from HealthKit if available; user can enter manually
6. Optional: elevation gain (for runs and hikes)
7. Optional: equipment tag — e.g., treadmill, stationary bike, rowing machine (see UC-17)
8. Optional: notes
9. Saves — workout written to shared store and HealthKit

**Success:** A complete cardio session is recorded with accurate distance, pace, and HR data in under 60 seconds. If Apple Watch data is available, most fields are pre-filled.
**Data note (Data Architect):** Pace is derivable from distance and duration — it should not be stored as a redundant field. Store distance and duration; compute pace at query time. HR data comes from HealthKit and should be stored only if the user explicitly logs it or imports it, not silently pulled without consent.
**HealthKit note:** A run logged in Training should map to `HKWorkoutActivityType.running` with the appropriate distance and HR samples attached. The mapping between Training's activity types and HealthKit's activity type enum must be defined explicitly — not inferred.
**Tier:** Free

---

## UC-15: Log a Structured Cardio Session (Intervals)

**Actor:** User who does structured cardio work — intervals, tempo blocks, fartlek, threshold sets
**Goal:** Record not just the session totals but the breakdown of effort across intervals or segments
**Precondition:** User is logging a session that had distinct effort phases

**Flow:**
1. User initiates a cardio log (from UC-14 path) and opts into interval logging
2. Adds intervals to the session — each interval has: distance or duration, pace or HR zone, and rest duration
3. Actual performance is entered per interval (e.g., "800m in 3:42, 90s rest")
4. Session totals (total distance, total duration including rest) are computed automatically
5. Optional: a target is stored alongside actual — what the interval was supposed to be vs. what happened
6. Saves the full session

**Example:** "6×800m at 5k pace, 90s rest" — six interval records, each with target pace, actual pace, and rest duration

**Success:** The session is captured at interval resolution. A runner can look back and see not just that they ran 6km but how each 800m split went.
**Design note (UI Designer):** Interval entry should feel like set/rep entry in UC-2 — a repeating row pattern, add with a tap. The session total should update live as intervals are entered so the user always knows where they stand.
**Data note (Data Architect):** Intervals are to cardio what sets are to strength — child records of the exercise entry. The schema should model them analogously: a workout contains exercises; a cardio exercise entry contains intervals. This parallelism is intentional and should be preserved in the schema design.
**Product note:** Target vs. actual on intervals is the cardio equivalent of planned vs. completed for workouts (UC-6/7). It surfaces the same honest signal: intent vs. reality.
**Tier:** Free

---

## UC-16: Track Cardio Performance Over Time

**Actor:** User who wants to see whether their cardio fitness is improving
**Goal:** Surface meaningful cardio-specific trends — pace progression, distance growth, personal records
**Precondition:** Multiple cardio sessions logged over time

**Flow:**
1. User navigates to trends view and selects a cardio activity (e.g., running)
2. Sees pace trend over time for that activity — is their average pace improving?
3. Sees weekly mileage / total distance trend
4. Personal records are surfaced: fastest recorded pace for a given distance (5k, 10k, 1 mile, etc.)
5. Tapping any data point navigates to the session that produced it

**Success:** A runner can see at a glance whether they are getting faster, how their weekly volume has changed, and what their PR is for a given distance — all without manually tracking these in a spreadsheet.
**Design note (UI Designer):** PRs deserve visual distinction — not a trophy or gamification element, but clear callout. A PR is a data point worth surfacing prominently.
**Data note (Data Architect):** PRs for standard distances (5k, 10k, mile) must be computable from stored interval data (UC-15) as well as from full-session distance/duration logs. A user who ran a 5k as part of a 10k log should still have that 5k pace extracted if interval splits were recorded. This is a non-trivial query — it should be evaluated before the schema is finalized.
**Tier:** Basic (pace trend, weekly distance) free; PR tracking and advanced periodization analytics subscription

---

## UC-17: Tag Equipment to an Exercise

**Actor:** User logging a strength or cardio exercise that used specific equipment
**Goal:** Record what equipment was used so the log reflects not just what was done but how
**Precondition:** User is in the process of logging an exercise (UC-2 or UC-14)

**Flow:**
1. While logging an exercise, user taps an optional "Equipment" field
2. Selects from a list of equipment types — common options presented, with search
3. Selection is saved alongside the exercise entry
4. Equipment appears in the exercise detail in history (UC-8)

**Examples by domain:**
- Strength: barbell, dumbbells, kettlebell, cables, machine, resistance bands, pull-up bar, bodyweight
- Cardio: treadmill, stationary bike (upright / spin), rowing machine, ski erg, assault bike, elliptical, outdoor (no machine)

**Success:** A user can distinguish "dumbbell Romanian deadlift" from "barbell Romanian deadlift" in their history without having to encode it in the exercise name. Equipment is a first-class field, not a workaround.
**Data note (Data Architect):** Equipment is a first-class `@Model` (`Equipment`) with a name, category, and optional notes. Users can define custom equipment (e.g., "my home cable pulley") in addition to a seeded vocabulary of common items. Equipment records are reused across exercises — a `WorkoutSet` or `WorkoutInterval` holds an optional `@Relationship` to an `Equipment` instance with delete rule `.nullify` (deleting a piece of equipment does not delete the sets that used it). CloudKit sync implications: all `Equipment` attributes must be optional or carry defaults; the relationship to `WorkoutSet`/`WorkoutInterval` is the standard inverse pattern already established in the schema.
**Product note:** Equipment tagging is always optional. A user who just wants to log "bench press" without specifying barbell vs. smith machine vs. dumbbells should never be blocked from saving.
**Tier:** Free

---

## UC-18: Filter History by Equipment

**Actor:** User who wants to find sessions or exercises that used a specific piece of equipment
**Goal:** Answer questions like "what did I do on the cable machine last month?" or "how much barbell work have I done this cycle?"
**Precondition:** At least some exercises have been tagged with equipment (UC-17)

**Flow:**
1. In history view (UC-8), user applies an equipment filter
2. The list narrows to sessions that included at least one exercise using that equipment type
3. Within a session detail, exercises using the filtered equipment are visually distinguished
4. User can combine equipment filter with activity type or date range filter

**Success:** Equipment becomes a useful lens on training history — not just what exercises were done, but in what context (home gym vs. commercial gym vs. outdoor)
**Product note:** This use case is only as valuable as the completeness of UC-17. The app should not surface an equipment filter prominently until enough sessions have equipment tags to make it useful.
**Tier:** Free (basic filter); advanced equipment analytics (volume per equipment type over time) subscription

---

## Summary by Tier

| Use Case | Tier |
|---|---|
| UC-1: Log a workout (fast path) | Free |
| UC-2: Log a structured workout | Free |
| UC-3: Log from template | Free |
| UC-4: Save a template | Free |
| UC-8: Browse workout history | Free (basic) |
| UC-10: Import from HealthKit | Free |
| UC-11: Write to HealthKit | Free |
| UC-12: Onboard new user | Free |
| UC-14: Log a cardio workout | Free |
| UC-15: Log a structured cardio session (intervals) | Free |
| UC-17: Tag equipment to an exercise | Free |
| UC-18: Filter history by equipment | Free (basic) |
| UC-9: View training trends | Free (basic) / Subscription (advanced) |
| UC-16: Track cardio performance over time | Free (basic) / Subscription (advanced) |
| UC-5: Plan a future workout | Subscription |
| UC-6: Complete a planned workout | Subscription |
| UC-7: Record a skipped workout | Subscription |
| UC-13: Cross-suite data sharing | Implicit |

---

## Flags Before Becoming a Backlog

**Program Manager:** UC-5 through UC-7 (planning features) should not be built until UC-1 through UC-4 and UC-10/11 are solid. The first milestone is a complete, fast, HealthKit-connected logging experience. Planning is milestone two.

**Data Architect:** Two schema decisions must be resolved before implementation begins on structured exercise logging:

1. **Exercise schema** (UC-2, UC-14, UC-15): What an "exercise" is — how it handles strength vs. cardio vs. bodyweight vs. time-based movements, and how intervals (UC-15) relate to cardio exercises the same way sets relate to strength exercises. This shapes the entire structured logging experience.

2. **Equipment model** (UC-17): Equipment is a first-class `@Model` — user-definable, reused across exercises, with `.nullify` delete rules. A seeded vocabulary is provided. This is the schema from day one — no migration from enum needed later.

**Finance:** The subscription boundary at "planning" is a deliberate call that should be documented. It should not be decided ad hoc mid-implementation.
