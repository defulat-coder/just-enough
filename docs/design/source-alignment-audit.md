# Source Alignment Audit

Date: 2026-06-20

## Source Reviewed

- X article cache: `.reference/article/source-fxtwitter.json`
- Public reply cache: `.reference/article/nitter.html`
- Nested reply cache: `.reference/article/nitter-more-2065124907412029440.html`
- Video contact sheet: `.reference/contact-sheet-1fps.jpg`
- Current SwiftUI implementation under `Sources/JustEnoughApp/`

## Original Intent

The source asks for a native iOS calorie tracker that feels like one unified conversation with a personal nutrition agent. The user should dump food text or photos into the agent, the agent should use memory and nutrition tooling, and tracked food should appear as beautiful consistent visuals. The day view should be pageable conversation threads, and the user should be able to zoom out into a premium image-centric meal timeline.

The article also stresses process quality: maintain modular code, document intent, verify interactions in Simulator, and audit the visual output instead of trusting screenshots alone.

Visible replies add three important product constraints:

- Users expect image generation/provider wiring to be explicit.
- Users want to test or run the app, not just see a pretty video.
- Beautiful output is insufficient if the tracker does not actually work.

## Gaps Found In The Previous Landing

1. **Daily screen was grid-first instead of thread-first.**
   The prior home screen opened with a food grid before the conversation. The original source frames show the thread as the product center, with food rows and images embedded inside the conversation.

2. **Meal results were visually detached from agent messages.**
   Existing meal tiles were functionally correct but behaved like a gallery. The source goal is that the agent updates tracked food as part of the conversation.

3. **Day navigation was underdeveloped.**
   The source explicitly says each day should be a conversation thread the user can page through. The previous app had seeded days but no direct day paging affordance on the main thread.

4. **Timeline layout was too editorially clever.**
   The alternating layout looked designed, but the source specifically says the high-level grid should be simplified and more image-centric. The reference frames show a calmer day-grouped image catalog.

5. **Agent memory and tool use were mostly architectural, not visible.**
   The services existed behind protocols, but the UI did not communicate that the agent is using memory, nutrition estimates, and known foods.

## Adjustments Made

1. **Thread-first daily screen.**
   `DailyConversationView` now starts with day stats, day paging, visible agent memory, then the agent thread. The food grid no longer dominates the first screen.

2. **Inline meal results.**
   Meal cards are now rendered directly under relevant agent messages. Seeded messages show the initial meals, and new natural-language/photo logs attach their generated food entries to the message flow.

3. **Day paging.**
   Added previous/next controls and compact day buttons to move between conversation threads without leaving the primary surface.

4. **Image-centric catalog timeline.**
   `TimelineCatalogView` now uses simple two-column meal tiles grouped by day instead of alternating left/right spreads.

5. **Visible memory cues.**
   The daily screen now shows concise agent memory chips for protein target, lifting focus, and common foods.

6. **Typography cleanup.**
   Removed negative letter spacing from the editorial title helper to keep text stable and aligned with the project UI rules.

## Verified Evidence

- Build/run succeeded on iPhone 13 Simulator with no warnings or errors.
- `docs/verification/thread-first-home.jpg` shows the revised thread-first home.
- `docs/verification/thread-log-results.jpg` shows natural-language logging producing inline meal results.
- `docs/verification/image-catalog-timeline.jpg` shows the simplified image-centric timeline.

Runtime validation:

- Entered `coffee and salmon`.
- App created `Cafe Latte` and `Grilled Salmon Plate`.
- Day total updated to `3,500 cal`.
- Protein total updated to `155g protein`.
- Generated meal cards appeared inside the agent thread.

## Remaining Product Gaps

These are intentionally not solved in the local prototype yet:

- Real external USDA lookup.
- Real image generation provider and generated transparent food assets.
- Real camera permissions and photo classification.
- Frame-by-frame animation analysis with recorded video and pixel-diff scripts.
- App Store signing and release packaging.

The current implementation is materially closer to the source intent than the previous landing because it restores the conversation as the primary interaction model while preserving the local runnable architecture.

## Repository Status

The workspace has been initialized as a git repository and committed with the rebuilt implementation, source references, documentation, and verification screenshots.
