# Just Enough

Just Enough is a native SwiftUI nutrition journal inspired by the X article in `.reference/article/`. It turns messy meal notes and photo captures into editable, persistent food records with a premium food-magazine visual style.

The current release is a local, publishable-quality prototype: it is fully runnable on iOS Simulator, uses deterministic local providers, and keeps the future API seams explicit.

## Product Scope

- Daily conversation surface for natural-language food logging.
- Agent-style parsing that turns notes like `latte and avocado salad` into tracked meals.
- Thread-first meal results where generated food cards appear inside the agent conversation.
- Direct day paging between daily conversation threads.
- Camera capture simulation with food recognition review.
- Editable meal detail with calories, macros, confidence, and rationale.
- Persistent local journal state using JSON in the app container.
- Magazine-style timeline for browsing meals across days.
- Studio-style bundled food imagery and warm editorial UI.

The first release intentionally does not call live external services. Nutrition, image selection, and agent behavior are protocol-backed local implementations so USDA, OpenAI, Gemini, Anthropic, or another provider can be added without reshaping the UI.

## Architecture

- `Sources/JustEnoughApp/Domain/`: `Codable` domain models for meals, macros, estimates, days, messages, memory, and snapshots.
- `Sources/JustEnoughApp/Services/`: provider protocols plus local nutrition, visual, agent, and JSON persistence implementations.
- `Sources/JustEnoughApp/State/`: `JournalStore`, the root observable state and action boundary.
- `Sources/JustEnoughApp/DesignSystem/`: shared color, typography, and page styling.
- `Sources/JustEnoughApp/UI/`: daily conversation, timeline, capture, recognition, detail, and reusable components.
- `docs/design/product-design.md`: formal product and system design document derived from the article and visible replies.
- `docs/design/source-alignment-audit.md`: latest source-vs-implementation gap review and adjustment record.
- `docs/superpowers/plans/2026-06-20-just-enough-product-refactor.md`: implementation plan and module breakdown.

## Run Locally

Open `JustEnough.xcodeproj` in Xcode and run the `JustEnough` scheme on an iPhone simulator.

For deterministic QA screenshots, launch with:

```text
--reset-journal
```

This resets the local JSON journal to the bundled seed data.

Verified local target:

- Scheme: `JustEnough`
- Bundle ID: `com.local.JustEnough`
- Simulator: `iPhone 13`, iOS 26.3

## Verified Flows

The app was built, installed, launched, and exercised through XcodeBuildMCP on iOS Simulator.

- Home/day conversation renders with existing tracked meals and totals.
- Day paging changes the active conversation thread.
- Natural-language logging accepts `latte and avocado salad`, adds both meals, and updates totals.
- Natural-language logging accepts `coffee and salmon`, adds `Cafe Latte` and `Grilled Salmon Plate`, and renders them inline in the thread.
- Timeline opens from the grid control and renders the meal catalog.
- Capture screen opens from the add button and presents the camera-like meal photo.
- Recognition review identifies `Avocado Garden Salad` and exposes an accept action.
- Accepting recognition writes the meal, opens detail, and persists it.
- Detail save updates the agent rationale after a calorie adjustment save.

Verification screenshots are saved in `docs/verification/`:

- `home-day.jpg`
- `agent-thread.jpg`
- `timeline-catalog.jpg`
- `capture.jpg`
- `recognition.jpg`
- `detail-edit.jpg`
- `thread-first-home.jpg`
- `thread-log-results.jpg`
- `image-catalog-timeline.jpg`
- `round-03-thread-tools.jpg`
- `round-04-recognition-trace.jpg`
- `round-05-detail-source.jpg`
- `round-06-zoomed-timeline.jpg`
- `round-07-detail-weight-before-close-fix.jpg`
- `round-08-current-flow.mp4`
- `round-08-frame-audit/contact-sheet.jpg`
- `round-10-final-home.jpg`

## Frame Audit

Use the frame audit helper to sample a simulator recording or source video:

```bash
scripts/frame_audit.sh path/to/video.mp4 docs/verification/frame-audit
```

The script writes sampled frames and a contact sheet for visual review.

## Release Notes

This project is ready for local user testing and product iteration. Before App Store distribution, wire production providers, add real camera permissions, configure signing, add analytics/privacy copy, and run device QA.
