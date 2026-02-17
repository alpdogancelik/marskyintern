#!/usr/bin/env bash
set -euo pipefail

FLUTTER_DIR="${FLUTTER_DIR:-$PWD/.flutter-sdk}"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "Flutter SDK not found at $FLUTTER_DIR. Run install step first."
  exit 1
fi

cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL:-}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-}
COINRANKING_API_KEY=${COINRANKING_API_KEY:-}
USE_MOCK_AUTH=${USE_MOCK_AUTH:-false}
USE_MOCK_COINS=${USE_MOCK_COINS:-false}
USE_SUPABASE_COINS_CACHE=${USE_SUPABASE_COINS_CACHE:-false}
ENABLE_DEV_STUB_FLOWS=${ENABLE_DEV_STUB_FLOWS:-false}
EOF

"$FLUTTER_DIR/bin/flutter" build web --release
