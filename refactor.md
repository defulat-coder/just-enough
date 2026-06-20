# Refactor Log

## 2026-06-21

### Baseline

- Repository: clean `main` tracking `origin/main`.
- Live baseline: `JustEnough` built and launched on iPhone 13 simulator with `--reset-journal`.
- Screenshot check: home/day conversation rendered normally with Chinese UI and no obvious overlap.

### Step 1 - Deepen journal mutation behavior

- Candidate: `JournalStore` was a shallow root module doing UI-facing state, agent orchestration, entry construction, day/message mutation, memory updates, and persistence.
- Change: extract `JournalMutationEngine` so entry construction, day/message recording, memory updates, and entry mutation live behind a focused interface.
- Expected leverage: UI callers still use `JournalStore`, while journal write rules gain better locality and a direct future test surface.
- Verification: passed `build_run_sim --reset-journal`, simulator screenshot check, `git diff --check`, and `scripts/verify_delivery.sh`.
- Autoreview: checked that the extracted interface preserves the original early-return behavior, persistence timing, generated message linkage, and selected-entry refresh.
- Commit: `7436ccf Extract journal mutation engine`.

### Step 2 - Keep navigation mode behind store commands

- Candidate: UI screens were directly assigning `store.mode`, which made route transitions a shared implementation detail.
- Change: make `mode` read-only outside `JournalStore` and replace direct writes with `returnToDay()` / `returnToCapture()`.
- Expected leverage: route names and transitions now stay local to the store interface, while views express user intent.
- Verification: passed `build_run_sim --reset-journal`, simulator screenshot check, no remaining `store.mode =` writes, `git diff --check`, and `scripts/verify_delivery.sh`.
- Autoreview: checked that route rendering still reads `mode`, sheets still bind `selectedEntry`, and capture/timeline back actions now use store intent methods.
- Commit: `8b676d0 Hide journal navigation mode writes`.

### Step 3 - Split food detail sections into dedicated views

- Candidate: `FoodDetailView` mixed page shell, section rendering, source-pill rendering, slider binding, and save action in computed `some View` helpers.
- Change: extract title, nutrition, estimate source, calorie adjustment, source pill, and rationale sections into private view types; keep save orchestration in `FoodDetailView`.
- Expected leverage: the detail page now reads as a stable screen composition, with section inputs explicit and the save action isolated.
- Verification: passed `build_run_sim --reset-journal`, runtime UI snapshot opening a meal detail sheet, simulator screenshot check, `git diff --check`, and `scripts/verify_delivery.sh`.
- Autoreview: checked that section extraction kept all original labels, image sizing, slider range/step, save accessibility identifier, source/confidence rendering, and calorie-save orchestration.
- Commit: `3ec1ea3 Split food detail view sections`.

### Step 4 - Split daily conversation composition

- Candidate: `DailyConversationView` still hid the title and conversation stream behind computed `some View` helpers.
- Change: extract `DailyConversationTitle` and `AgentConversationSection`, passing explicit messages, entry lookup, and selection callbacks.
- Expected leverage: the home screen body now shows the app chrome, day summary, pager, memory strip, conversation stream, and input bar as explicit composition.
- Verification: passed `build_run_sim --reset-journal`, runtime UI flow typing `coffee and salmon`, header update to `2,460` kcal / `119g` protein, runtime candidates for new reply/cards, simulator screenshot check, `git diff --check`, and `scripts/verify_delivery.sh`.
- Autoreview: checked that title copy, conversation label, related-entry lookup, entry selection, input binding, and send/capture actions stayed equivalent.
- Commit: `336762c Clarify daily conversation composition`.

### Step 5 - Split timeline catalog composition

- Candidate: `TimelineCatalogView` still used computed helpers that closed over the whole store.
- Change: extract `TimelineCatalogHeader` and `TimelineDaySection`, passing day counts, calorie totals, day data, and callbacks explicitly.
- Expected leverage: the catalog page now has the same explicit composition style as the home and detail screens.
- Verification: passed `build_run_sim --reset-journal`, runtime UI snapshot for `饮食图册`, explicit tap from home to catalog, catalog screenshot check, no remaining computed `some View` helpers / `store.mode =` writes, `git diff --check`, and `scripts/verify_delivery.sh`.
- Autoreview: checked that catalog title, total calorie copy, day open action, entry selection callbacks, and meal tile rendering stayed equivalent.
- Commit: pending.
