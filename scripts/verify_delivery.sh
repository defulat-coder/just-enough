#!/usr/bin/env bash
set -euo pipefail

required_files=(
  "README.md"
  "docs/design/product-design.md"
  "docs/design/source-alignment-audit.md"
  "docs/design/ten-round-source-rebuild.md"
  "docs/design/ten-round-source-rebuild-2.md"
  "docs/verification/round-10-final-home.jpg"
  "docs/verification/round-13-clean-target.jpg"
  "docs/verification/round-13-stream-parser-target.jpg"
  "docs/verification/round-16-home-input.jpg"
  "docs/verification/round-16-home-input-return.jpg"
  "docs/verification/round-16-timeline-framing.jpg"
  "docs/verification/round-19-home.jpg"
  "docs/verification/round-19-current-flow.mp4"
  "docs/verification/round-19-frame-audit/contact-sheet.jpg"
  "docs/verification/round-20-final-home.jpg"
  "docs/verification/round-08-current-flow.mp4"
  "docs/verification/round-08-frame-audit/contact-sheet.jpg"
  "scripts/frame_audit.sh"
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || { echo "Missing required file: $file" >&2; exit 1; }
done

for round in $(seq 1 20); do
  rg -q "Round $round " docs/design/ten-round-source-rebuild.md docs/design/ten-round-source-rebuild-2.md \
    || { echo "Missing round $round in rebuild logs" >&2; exit 1; }
done

if rg -q "\\b(Pending|pending|TODO|TBD)\\b" docs/design/ten-round-source-rebuild.md docs/design/ten-round-source-rebuild-2.md README.md; then
  echo "Found unfinished marker in delivery files" >&2
  exit 1
fi

rg -q -- "--reset-journal" README.md Sources/JustEnoughApp/State/JournalStore.swift \
  || { echo "Missing reset-journal documentation or implementation" >&2; exit 1; }

rg -q "写下吃了什么，或加照片" Sources/JustEnoughApp/UI/JournalComponents.swift \
  || { echo "Input surface no longer advertises messy meal dumping" >&2; exit 1; }

echo "delivery verification passed"
