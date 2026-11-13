#!/usr/bin/env bash
#
# Download YouTube videos at full resolution.
#
# Usage:
#   1. Put one YouTube URL per line in  urls.txt  (next to this script).
#      Lines starting with # are ignored.
#   2. Run:  ./download.sh
#
# Videos are saved into the ./downloads folder, each as a single .mp4/.mkv
# file at the highest available resolution (video + audio merged by ffmpeg).

set -euo pipefail

# --- locate ourselves so the script works from any directory ---------------
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
URLS="$DIR/urls.txt"
OUT="$DIR/downloads"

# --- make sure yt-dlp is installed -----------------------------------------
if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "yt-dlp not found — installing..."
  if command -v brew >/dev/null 2>&1; then
    brew install yt-dlp
  elif command -v pipx >/dev/null 2>&1; then
    pipx install yt-dlp
  elif command -v pip3 >/dev/null 2>&1; then
    pip3 install --user yt-dlp
  else
    echo "Could not auto-install. Install Homebrew (https://brew.sh) then run: brew install yt-dlp"
    exit 1
  fi
fi

# --- make sure ffmpeg is present (needed to merge best video + best audio) --
if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg not found — installing (needed to merge audio + video)..."
  brew install ffmpeg
fi

# --- check the URL list exists ---------------------------------------------
if [[ ! -f "$URLS" ]]; then
  echo "No urls.txt found. Creating a template at: $URLS"
  cat > "$URLS" <<'EOF'
# Paste one YouTube URL per line. Lines starting with # are ignored.
# Example:
# https://www.youtube.com/watch?v=dQw4w9WgXcQ
EOF
  echo "Edit urls.txt, add your links, then run this script again."
  exit 0
fi

mkdir -p "$OUT"

# --- download --------------------------------------------------------------
# -f: best video + best audio, falling back to best single file
# --merge-output-format mp4: produce a normal .mp4 when possible
# -i: keep going if one video fails
# -o: save as "Title [videoid].ext" to avoid name collisions
# --download-archive: skip anything already downloaded on re-runs
# --embed-metadata / --embed-thumbnail: nice-to-have tags & cover art
yt-dlp \
  -a "$URLS" \
  -f "bv*+ba/b" \
  --merge-output-format mp4 \
  -i \
  -o "$OUT/%(title)s [%(id)s].%(ext)s" \
  --download-archive "$DIR/.downloaded.txt" \
  --embed-metadata \
  --embed-thumbnail \
  --no-overwrites

echo
echo "Done. Files are in: $OUT"
