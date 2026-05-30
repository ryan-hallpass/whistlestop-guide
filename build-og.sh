#!/usr/bin/env bash
# Regenerate og-image.jpg from og.html at exactly 1200x630.
# Uses headless Chrome (no node_modules needed). Run from this dir.
set -euo pipefail
cd "$(dirname "$0")"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[ -x "$CHROME" ] || CHROME="/Applications/Chromium.app/Contents/MacOS/Chromium"

TMPDIR_RUN="$(mktemp -d)"
"$CHROME" --headless=new --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=1 --window-size=1200,630 \
  --default-background-color=00000000 \
  --screenshot="$TMPDIR_RUN/og.png" \
  "file://$PWD/og.html" >/dev/null 2>&1

# headless --window-size capture == viewport == 1200x630 exactly.
# Convert PNG -> JPEG. If dims ever drift, resize to exact 1200x630 (no crop).
sips -z 630 1200 "$TMPDIR_RUN/og.png" >/dev/null
sips -s format jpeg -s formatOptions 88 "$TMPDIR_RUN/og.png" --out og-image.jpg >/dev/null

echo "Wrote og-image.jpg:"
sips -g pixelWidth -g pixelHeight og-image.jpg | grep pixel
rm -rf "$TMPDIR_RUN"
