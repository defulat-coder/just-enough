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
- Commit: pending.
