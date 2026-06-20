# Just Enough Product Design

## Source Of Truth

This design is derived from the X Article at `https://x.com/anshuc/status/2064828802824597584`, the publicly visible reply thread captured in `.reference/article/`, and the video frame references in `.reference/`.

The article defines the product more clearly than the later demo video:

- Build a native iOS calorie tracker, not a web-style mock.
- Make logging feel like one unified conversation with a personal agent.
- Let the user dump food descriptions, photos, or messy notes into the agent instead of searching through forms.
- Each day should be a conversation thread.
- The agent should query nutrition data, remember history, update tracked food, and feel personal.
- Food entries should be beautiful, consistent, studio-style visuals.
- The user should zoom out from a day thread into a scrollable magazine-like timeline of meals.
- Every interaction and transition should feel premium, fluid, Apple-like, and verified frame by frame.

The visible replies add three practical constraints:

- Image generation must be an explicit provider abstraction because users ask how it is wired.
- The app must be testable locally and eventually distributable because users asked to try it live.
- Beauty alone is not enough; the product must actually work as a tracker, not only as a visual demo.

## Product Thesis

Just Enough is a personal nutrition journal where the primary interface is a daily conversation with an agent. The app turns messy real-world food input into accurate, editable, beautiful meal records while preserving the emotional quality of a premium visual diary.

The product should feel less like a diet spreadsheet and more like a calm food magazine that happens to know your goals.

## Target User

The target user tracks food because they care about training, body composition, or health, but hates the repeated friction of calorie apps:

- They know roughly what they ate.
- They want speed and trust.
- They care about protein and calories more than exhaustive nutrition tables.
- They want to correct estimates without fighting the UI.
- They want the app to feel worth opening every day.

## Non-Negotiable Product Requirements

1. Native iOS SwiftUI app.
2. One primary daily conversation surface.
3. Natural-language meal logging.
4. Camera/photo recognition flow.
5. Agent response with streaming-style output.
6. Nutrition estimates with calories, protein, carbs, and fat.
7. Editable meal entries.
8. Persistent local journal state.
9. User memory for goals, common foods, and preferred portions.
10. Magazine-style meal timeline.
11. Food detail screen with visual, nutrition summary, and agent explanation.
12. High-quality motion between day, timeline, and detail.
13. Local verification through iOS Simulator screenshots.

## Release Scope

The first publishable local product will ship with deterministic local providers:

- `MockAgentRuntime` parses realistic user inputs into known meal records.
- `MockNutritionProvider` returns stable nutrition estimates.
- `LocalFoodVisualProvider` maps meals to bundled studio-style food assets.
- `JournalStore` persists entries and user memory locally with JSON.

External APIs are intentionally behind protocols and can be added later without changing UI flow:

- USDA FoodData Central for nutrition.
- Gemini/OpenAI image generation for food visuals.
- Anthropic/OpenAI/Gemini agent runtime for live tool calling and streaming.

## Core Information Architecture

### Daily Conversation

The home screen is the current day. It contains:

- Day title, calories, protein, and progress.
- A conversation thread between the user and agent.
- Inline meal cards generated from the conversation.
- A bottom input surface with text, photo, and send affordances.

The day should feel active and editable, not archival.

### Magazine Timeline

The timeline is the zoomed-out view:

- Days are stacked vertically.
- Meals are represented by large images and concise labels.
- The layout is image-centric and calm.
- Tapping any meal opens detail.

The timeline is not a dashboard card grid. It is a visual catalog of eating history.

### Food Detail

Food detail explains one entry:

- Large visual.
- Calories and macro summary.
- Serving description.
- Agent confidence and rationale.
- Edit controls for calories, serving, and macros.

The detail screen must be useful for correction, not just a pretty modal.

### Capture Recognition

The camera flow is a controlled simulation in v1:

- User taps add.
- Camera-like screen opens with the bundled food photo.
- Capture moves to recognition.
- Agent identifies the food and offers a logged entry.

This keeps the product testable while preserving the intended flow.

## Architecture

### Domain

Domain models are plain Swift value types:

- `MacroProfile`
- `NutritionEstimate`
- `FoodVisual`
- `FoodEntry`
- `AgentMessage`
- `FoodDay`
- `UserNutritionMemory`

These types are UI-independent and Codable where state must persist.

### Services

Services are protocol-backed:

- `NutritionProviding`
- `FoodVisualProviding`
- `AgentRunning`
- `JournalPersisting`

The first release uses local implementations. API-backed implementations can replace them later.

### Store

`JournalStore` is the root observable app state:

- Owns days, selected day, timeline mode, selected entry, and draft input.
- Calls services to log text or recognized photos.
- Persists journal and memory after mutations.
- Exposes small actions to UI.

### UI

UI is split by screen and component:

- `JournalAppView`
- `DailyConversationView`
- `TimelineCatalogView`
- `FoodDetailView`
- `CaptureRecognitionView`
- `DesignSystem`
- `JournalComponents`

Screens should stay mostly declarative. Business logic belongs in `JournalStore` and services.

### Motion

Motion is a product feature:

- Shared food image identity between timeline/detail.
- Spring transitions for logging and opening detail.
- Streaming-style agent response reveal.
- Capture-to-result transition.

The verification loop must include screenshots of each key state and runtime interaction checks.

## Visual Direction

The app should preserve the strongest qualities of the reference video while becoming more product-complete:

- Warm white background.
- Black editorial typography.
- Muted red-orange progress and action accent.
- Soft glass controls.
- Large food imagery with realistic shadows.
- Sparse nutrition detail.
- No decorative gradients.
- No generic dashboard card wall.

Food imagery should feel consistent: studio-lit, isolated, soft shadow, magazine crop.

## Key User Flows

### Flow 1: Log Natural Language

1. User enters a messy food note.
2. Agent adds a user message.
3. Agent streams a short interpretation.
4. One or more meal records appear.
5. Day totals update.
6. State persists.

### Flow 2: Photo Recognition

1. User taps add.
2. Capture screen opens.
3. User captures the bundled meal photo.
4. Agent identifies Avocado Garden Salad.
5. User accepts or opens detail.
6. Day totals update.

### Flow 3: Review Timeline

1. User taps timeline.
2. App transitions into magazine catalog.
3. User scans meals by image.
4. User opens any meal detail.
5. User returns without losing scroll context.

### Flow 4: Edit Meal

1. User opens detail.
2. User adjusts serving or calories.
3. Macros and day totals update.
4. Agent explanation remains visible.
5. State persists.

## Verification Requirements

Every release candidate must satisfy:

- Xcode build succeeds for iOS Simulator.
- App launches on iPhone simulator.
- Screenshot proves home/day conversation state.
- Screenshot proves timeline catalog state.
- Screenshot proves capture recognition state.
- Screenshot proves food detail/edit state.
- UI automation proves add/capture/send/detail/timeline controls are reachable.
- Visual inspection confirms no obvious clipping, unreadable controls, or low-quality food crops.

## Explicit Non-Goals For First Release

- Live external API calls.
- Real camera permission handling.
- App Store account signing.
- Cloud sync.
- HealthKit integration.
- Multi-user profiles.

These are important future directions but not needed to produce a locally usable, publishable-quality product prototype.
