# Ten Round Source Rebuild Log

Date: 2026-06-20

This log tracks the requested repeated loop: read the original X source, inspect the current implementation, identify the gap, adjust, verify, then continue to the next round.

## Round 1 - Repeatable Verification

- Source pressure: the article emphasizes simulator verification and repeatable self-checking.
- Gap: simulator state persisted every test meal, so screenshots became harder to compare against the source.
- Adjustment: added `--reset-journal` launch argument support in `JournalStore`.
- Evidence: `build_run_sim` succeeded with `--reset-journal`; clean home returned to `1,660 cal`.

## Round 2 - Day Thread Semantics

- Source pressure: each day should be a conversation thread the user can page through.
- Gap: day pills had been shortened to dates, which weakened the source language of `Today`, `Yesterday`, and `Wednesday`.
- Adjustment: added `FoodDay.pagerTitle` and restored semantic day labels inside a horizontal day pager; compact non-current labels prevent truncation while full day titles remain in the day header.
- Evidence: simulator screenshot showed truncation, then the labels were corrected.

## Round 3 - Visible Agent Tooling

- Source pressure: the original system has agent memory, nutrition DB querying, tool calling, and streaming.
- Gap: services existed in code, but meal rows did not visually communicate agent tool use.
- Adjustment: added a compact tool trace above inline meal results: `memory`, `nutrition DB`, and generated food count.
- Evidence: simulator screenshot shows `memory`, `nutrition DB`, and `4 foods` above generated meal rows.

## Round 4 - Capture Recognition Trace

- Source pressure: photo input should feel like an agent using tools, not a static canned result.
- Gap: recognition jumped from captured photo to final result with no visible analysis.
- Adjustment: added `Agent analysis` chips for `vision`, `memory`, and `nutrition DB` on the recognition review screen.
- Evidence: `docs/verification/round-04-recognition-trace.jpg`.

## Round 5 - Estimate Source In Detail

- Source pressure: tracker must actually work, and estimates need trust without clutter.
- Gap: detail had rationale text, but source/confidence were buried below the edit control.
- Adjustment: added source/confidence pills directly under the primary calorie readout.
- Evidence: `docs/verification/round-05-detail-source.jpg`.

## Round 6 - Timeline As Zoomed-Out Threads

- Source pressure: the timeline should feel like zooming out from day threads.
- Gap: catalog did not explicitly connect itself back to the conversation model.
- Adjustment: timeline header now says it is zoomed out from agent threads, and each day section exposes an `Open thread` action.
- Evidence: `docs/verification/round-06-zoomed-timeline.jpg`.

## Round 7 - Detail Visual Weight

- Source pressure: the visual pass should remove awkward layout weight and generic UI heaviness.
- Gap: the detail edit button read like a heavy red bar, source names were too long for compact estimate pills, and custom sheet close controls were unreliable against the rounded sheet edge.
- Adjustment: shortened nutrition source copy, constrained the save action to a centered capsule, and replaced the custom close control with the system sheet drag indicator.
- Evidence: detail screenshot showed the issue; implementation was rebuilt and now uses the system sheet dismiss affordance.

## Round 8 - Frame Audit Artifact

- Source pressure: the article calls out frame-level verification and contact sheets.
- Gap: the repo had screenshots but no repeatable way to audit video frames.
- Adjustment: added `scripts/frame_audit.sh` to inspect MP4 metadata, extract frames, and generate a contact sheet.
- Evidence: recorded `docs/verification/round-08-current-flow.mp4` and ran the script. The environment lacks ffmpeg/ffprobe, so the script used its Quick Look fallback and wrote `docs/verification/round-08-frame-audit/contact-sheet.jpg`.

## Round 9 - Product Readiness Instructions

- Source pressure: public replies ask whether people can test the app; setup should be explicit.
- Gap: README did not mention deterministic reset or frame audit workflow.
- Adjustment: README now documents `--reset-journal` verification and the frame-audit script.
- Evidence: README includes deterministic launch args and `scripts/frame_audit.sh` usage.

## Round 10 - Final Completion Audit

- Source pressure: repeat the original source review loop until the implemented product is materially closer and verified.
- Gap: the previous log still had missing evidence and no final clean-launch proof.
- Adjustment: re-read the round log, README, verification artifacts, and git history; ran a final clean `build_run_sim` with `--reset-journal`; captured a final home screenshot.
- Evidence: `docs/verification/round-10-final-home.jpg`; final build succeeded with no warnings or errors.
