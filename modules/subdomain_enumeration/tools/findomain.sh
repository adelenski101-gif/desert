#!/usr/bin/env bash
# wrapper: runs findomain if installed, writes to findomain.txt
set -euo pipefail

DOMAIN="${1:-}"
OUT_BASE="${2:-DESERT_out}"
WORK_DIR="$OUT_BASE/$DOMAIN/subenum"
LOG="$WORK_DIR/subenum.log"
OUT="$WORK_DIR/findomain.txt"

if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <domain> [out_base]" >&2
  exit 2
fi

mkdir -p "$WORK_DIR"

if command -v findomain >/dev/null 2>&1; then
  # findomain -t <domain> -q -u <outfile>
  findomain -t "$DOMAIN" -q -u "$OUT" 2>>"$LOG" || true
else
  echo "[$(date -Iseconds)] [WARN] findomain not installed" >&2
  : > "$OUT"
fi
