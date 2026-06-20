# Just Enough Product Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the video replica into a modular, locally usable SwiftUI nutrition journal product.

**Architecture:** Plain Swift domain models feed protocol-backed local services. A root `JournalStore` owns persisted state and actions, while screens stay declarative and focused.

**Tech Stack:** SwiftUI, Observation, Codable JSON persistence, XcodeBuildMCP simulator verification.

---

## File Structure

- Create `Sources/JustEnoughApp/Domain/JournalModels.swift`: domain models and seed data.
- Create `Sources/JustEnoughApp/Services/JournalServices.swift`: provider protocols and local implementations.
- Create `Sources/JustEnoughApp/State/JournalStore.swift`: root observable state and product actions.
- Create `Sources/JustEnoughApp/DesignSystem/DesignSystem.swift`: colors, typography, shared visual tokens.
- Create `Sources/JustEnoughApp/UI/JournalAppView.swift`: root navigation and route orchestration.
- Create `Sources/JustEnoughApp/UI/DailyConversationView.swift`: daily conversation and logging surface.
- Create `Sources/JustEnoughApp/UI/TimelineCatalogView.swift`: magazine-style timeline.
- Create `Sources/JustEnoughApp/UI/FoodDetailView.swift`: detail and edit controls.
- Create `Sources/JustEnoughApp/UI/CaptureRecognitionView.swift`: capture simulation and recognition result flow.
- Create `Sources/JustEnoughApp/UI/JournalComponents.swift`: reusable meal cards, input bar, chrome, macro rows.
- Modify `Sources/JustEnoughApp/JustEnoughApp.swift`: inject `JournalStore`.
- Modify `JustEnough.xcodeproj/project.pbxproj`: add all new Swift source files to the app target.
- Retire `Sources/JustEnoughApp/FoodModels.swift` and `Sources/JustEnoughApp/CalorieJournalView.swift` from the build.

## Tasks

### Task 1: Write Design Doc

- [x] Save `docs/design/product-design.md`.
- [x] Save this implementation plan.

### Task 2: Create Modular Domain And Services

- [ ] Add domain models.
- [ ] Add local agent, nutrition, visual, and persistence providers.
- [ ] Build once to catch type errors.

### Task 3: Create Root Store

- [ ] Add `JournalStore` with local persistence.
- [ ] Implement natural-language logging, photo recognition, edit, selection, and timeline actions.
- [ ] Build once to catch state ownership errors.

### Task 4: Build Product UI

- [ ] Add root app view.
- [ ] Add daily conversation view.
- [ ] Add timeline view.
- [ ] Add detail/edit view.
- [ ] Add capture recognition view.
- [ ] Add reusable components and design tokens.

### Task 5: Wire Xcode Project

- [ ] Add new source files to `project.pbxproj`.
- [ ] Remove retired source files from the target.
- [ ] Build and fix compiler errors.

### Task 6: Verify Product Flows

- [ ] Build, install, and launch on iPhone simulator.
- [ ] Capture home screenshot.
- [ ] Tap timeline and capture timeline screenshot.
- [ ] Tap add/capture and capture recognition screenshot.
- [ ] Open food detail and capture detail screenshot.
- [ ] Verify day totals update after logging.

### Task 7: Delivery Cleanup

- [ ] Update `README.md` with product scope, run steps, and verification evidence.
- [ ] Initialize git if missing.
- [ ] Commit product design and modular refactor.
