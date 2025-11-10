#!/usr/bin/env bash
# wrapper: runs amass passive enum if installed, writes to amass.txt
set -euo pipefail

DOMAIN="${1:-}"
OUT_BASE="${2:-DESERT_out}"
WORK_DIR="$OUT_BASE/$DOMAIN/subenum"
LOG="$WORK_DIR/subenum.log"
OUT="$WORK_DIR/amass.txt"

if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <domain> [out_base]" >&2
  exit 2
fi

mkdir -p "$WORK_DIR"

if command -v amass >/dev/null 2>&1; then
  amass enum -passive -d "$DOMAIN" -o "$OUT" 2>>"$LOG" || true
else
  echo "[$(date -Iseconds)] [WARN] amass not installed" >&2
  : > "$OUT"
fi
