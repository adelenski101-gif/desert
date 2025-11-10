#!/usr/bin/env bash
# wrapper: runs assetfinder if installed, writes to assetfinder.txt
set -euo pipefail

DOMAIN="${1:-}"
OUT_BASE="${2:-DESERT_out}"
WORK_DIR="$OUT_BASE/$DOMAIN/subenum"
LOG="$WORK_DIR/subenum.log"
OUT="$WORK_DIR/assetfinder.txt"

if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <domain> [out_base]" >&2
  exit 2
fi

mkdir -p "$WORK_DIR"

if command -v assetfinder >/dev/null 2>&1; then
  assetfinder --subs-only "$DOMAIN" > "$OUT" 2>>"$LOG" || true
else
  echo "[$(date -Iseconds)] [WARN] assetfinder not installed" >&2
  : > "$OUT"
fi
