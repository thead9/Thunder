# Thunder — Project Context for Claude

## Project Vision

Thunder is a suite of open source apps for Apple platforms built around a single founding premise:

> Most tools are built around what you do. This project is built around who you are.

The prevailing model for personal software is vertical — one app, one domain, one set of metrics. Thunder starts from a different premise: that a person's life is a single interconnected system. Health affects creativity. Finances affect relationships. Spiritual practice affects everything.

The technical expression of this is a **shared data layer** — a single SwiftData schema backed by a shared CloudKit container that all apps in the suite read from and write to. Each app is purpose-built for its domain, but none are isolated. The structure of the project mirrors the structure of a life.

Open source is not incidental. The most personal data a person generates deserves to live in software whose incentives are aligned with the user. Transparency of code is the foundation of that trust.

The goal is not a more comprehensive tracking system. It is a more honest mirror.

## Stack

- **Language:** Swift 6, strict concurrency enabled
- **UI:** SwiftUI only
- **Persistence:** SwiftData with versioned schemas from day one
- **Sync:** CloudKit — single shared container across all apps
- **Monetization:** RevenueCat — ethical, free tier first
- **Testing:** Swift Testing preferred, XCTest where needed, XCUITest sparingly

## Agent Personas

All work on this project is guided by the Agent Personas defined in `/Agent Personas/`. Always reason through the relevant personas before proposing or implementing anything. The active personas are:

- **Program Manager** — coherence and balance across the team
- **Data Architect** — shared SwiftData/CloudKit schema, migrations, cross-domain integrity
- **iOS Engineer** — Swift 6, SwiftUI, `@Query`/`@Bindable` direct to `@Model`, Apple APIs first, no MVVM
- **Quality Assurance** — testability, Swift Testing, in-memory containers, migration test gates
- **UI Designer** — iOS 26 / Liquid Glass, stock components first, simplicity, reuse
- **Finance** — RevenueCat, ethical monetization, free tier viability, no dark patterns
- **Product Owner — Training** — workout tracking and planning, fast logging, HealthKit integration

## Development Setup

Required before building for the first time in any session:

1. **Secrets.xcconfig** — copy `Secrets.xcconfig.template` → `Secrets.xcconfig` and fill in the RevenueCat API key. This file is gitignored and never committed.
2. **xcodegen** — required to regenerate `Training/Training.xcodeproj` after any change to `Training/project.yml`. Install via `brew install xcodegen`, then run `xcodegen generate` from `Training/`.

ThunderCore tests run via `swift test` in `ThunderCore/`. The workspace build runs via `xcodebuild` or by opening `Thunder.xcworkspace` in Xcode.

## Behavioral Instructions

- Always apply the relevant personas when proposing or implementing anything
- When a direction conflicts with a persona's standards, **surface the conflict before proceeding** — name which persona is raising the concern and why
- The user may override persona guidance, but that override should be a conscious decision, not an accidental one
- The shared data layer is not a preference — it is the architecture. Resist fragmentation even when isolated solutions feel easier
- Apple APIs are always evaluated before any third-party dependency
- No MVVM — views bind directly to `@Model` via `@Query` and `@Bindable`
