#!/usr/bin/env bash
set -euo pipefail

FLUTTER_DIR="${FLUTTER_DIR:-$PWD/.flutter-sdk}"
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"

if [ ! -d "$FLUTTER_DIR/.git" ]; then
  echo "Installing Flutter SDK into $FLUTTER_DIR..."
  git clone --depth 1 -b "$FLUTTER_CHANNEL" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
else
  echo "Using existing Flutter SDK at $FLUTTER_DIR"
fi

"$FLUTTER_DIR/bin/flutter" --version
"$FLUTTER_DIR/bin/flutter" config --enable-web
"$FLUTTER_DIR/bin/flutter" pub get
