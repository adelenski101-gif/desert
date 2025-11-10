#!/usr/bin/env bash
# wrapper: runs subfinder if installed, writes to subfinder.txt
set -euo pipefail

DOMAIN="${1:-}"
OUT_BASE="${2:-DESERT_out}"
WORK_DIR="$OUT_BASE/$DOMAIN/subenum"
LOG="$WORK_DIR/subenum.log"
OUT="$WORK_DIR/subfinder.txt"

if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <domain> [out_base]" >&2
  exit 2
fi

mkdir -p "$WORK_DIR"

if command -v subfinder >/dev/null 2>&1; then
  # run subfinder, append stderr to log, write stdout to OUT
  subfinder -d "$DOMAIN" -silent -o "$OUT" 2>>"$LOG" || true
else
  echo "[$(date -Iseconds)] [WARN] subfinder not installed" >&2
  : > "$OUT"
fi
