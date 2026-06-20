#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: scripts/frame_audit.sh input.mp4 output-dir" >&2
  exit 2
fi

input="$1"
output_dir="$2"
frames_dir="$output_dir/frames"
sheet="$output_dir/contact-sheet.jpg"
metadata="$output_dir/metadata.txt"

if [[ ! -f "$input" ]]; then
  echo "Input video not found: $input" >&2
  exit 1
fi

rm -rf "$output_dir"
mkdir -p "$frames_dir"

if command -v ffprobe >/dev/null && command -v ffmpeg >/dev/null; then
  ffprobe -hide_banner "$input" > "$metadata" 2>&1 || true
  ffmpeg -hide_banner -loglevel error -i "$input" -vf "fps=4,scale=240:-1" "$frames_dir/frame-%04d.jpg"
  ffmpeg -hide_banner -loglevel error -pattern_type glob -i "$frames_dir/*.jpg" -vf "tile=4x6:padding=12:margin=12:color=white" -frames:v 1 "$sheet"
else
  {
    echo "ffmpeg_or_ffprobe=missing"
    echo "fallback=quicklook-thumbnail"
    file "$input"
  } > "$metadata"
  if command -v qlmanage >/dev/null && command -v sips >/dev/null; then
    qlmanage -t -s 960 -o "$output_dir" "$input" >/dev/null 2>&1
    thumbnail="$(find "$output_dir" -maxdepth 1 -name '*.png' | head -n 1)"
    if [[ -n "$thumbnail" ]]; then
      sips -s format jpeg "$thumbnail" --out "$sheet" >/dev/null
      cp "$sheet" "$frames_dir/frame-0001.jpg"
    fi
  else
    echo "Quick Look fallback unavailable" >> "$metadata"
  fi
fi

count="$(find "$frames_dir" -name 'frame-*.jpg' | wc -l | tr -d ' ')"
{
  echo "input=$input"
  echo "frames=$count"
  echo "contact_sheet=$sheet"
} >> "$metadata"

echo "Frame audit complete: $sheet"
