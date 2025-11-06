#!/usr/bin/env bash
# ============================================================
#  URL Gathering Module - desert toolkit
#  Usage: url_gather.sh <target_or_file> <output_dir>
#  Works standalone or from cli.py (--urlgather)
# ============================================================

set -euo pipefail

INPUT="$1"
OUTDIR="$2"
THREADS="${3:-5}"  # optional argument
TARGETS=()

# --------------------------
# 1. Input handling
# --------------------------
if [[ -f "$INPUT" ]]; then
    echo "[*] Reading targets from file: $INPUT"
    mapfile -t TARGETS < "$INPUT"
elif [[ -n "$INPUT" ]]; then
    TARGETS+=("$INPUT")
else
    echo "Usage: $0 <target_domain_or_file> <output_dir>"
    exit 1
fi

# Create main output directory
mkdir -p "$OUTDIR"

# --------------------------
# 2. Function: URL collection for one target
# --------------------------
collect_urls() {
    local TARGET="$1"
    local WORK="$OUTDIR/$TARGET"
    mkdir -p "$WORK"

    echo -e "\n================================================="
    echo "[*] URL gathering for: $TARGET"
    echo "================================================="

    local RAW="$WORK/urls_raw.txt"
    local SORTED="$WORK/urls_sorted.txt"
    : > "$RAW"; : > "$SORTED"

    # --- Waybackurls ---
    if command -v waybackurls >/dev/null 2>&1; then
        echo "[*] waybackurls..."
        echo "$TARGET" | waybackurls >> "$RAW" || true
    else
        echo "[!] waybackurls not installed."
    fi

    # --- GAU ---
    if command -v gau >/dev/null 2>&1; then
        echo "[*] gau..."
        echo "$TARGET" | gau >> "$RAW" || true
    else
        echo "[!] gau not installed."
    fi

    # --- Katana ---
    if command -v katana >/dev/null 2>&1; then
        echo "[*] katana (JS-aware crawler)..."
        katana -silent -u "https://$TARGET" -o "$WORK/katana_urls.txt" || true
        cat "$WORK/katana_urls.txt" >> "$RAW" || true
    else
        echo "[!] katana not installed."
    fi

    # --- Simple Fallback (curl + pup) ---
    if command -v curl >/dev/null 2>&1 && command -v pup >/dev/null 2>&1; then
        echo "[*] scraping homepage links (fallback)"
        curl -fsSL "https://$TARGET" 2>/dev/null | pup 'a[href] attr{href}' >> "$RAW" || true
    else
        echo "[!] skipping fallback (curl/pup missing)"
    fi

    # --------------------------
    # 3. Cleanup & filtering
    # --------------------------
    echo "[*] Normalizing and deduplicating URLs..."
    grep -Eo "(https?://[^\"' <>]+)" "$RAW" | sed 's/\/$//' | sort -u > "$SORTED" || true

    if ! [ -s "$SORTED" ]; then
        echo "[!] No URLs found for $TARGET."
        return
    fi

    # --------------------------
    # 4. Categorization
    # --------------------------
    echo "[*] Extracting JS and PHP files..."
    grep -Ei '\.js(\?.*)?$' "$SORTED" | sort -u > "$WORK/js_urls.txt" || true
    grep -Ei '\.php(\?.*)?$' "$SORTED" | sort -u > "$WORK/php_urls.txt" || true

    # --------------------------
    # 5. Optional analysis (if tools exist)
    # --------------------------
    # JS secrets discovery
    if command -v linkfinder >/dev/null 2>&1 && [ -s "$WORK/js_urls.txt" ]; then
        echo "[*] Running LinkFinder on JS files..."
        while read -r js; do
            linkfinder -i "$js" -o cli >> "$WORK/js_endpoints.txt" 2>/dev/null || true
        done < "$WORK/js_urls.txt"
    fi
    
    if command -v mantra >/dev/null 2>&1 && [ -s "$WORK/js_urls.txt" ]; then
	    echo "[*] Running Mantra to hunt API key leaks..."
	    cat "$WORK/js_urls.txt" | mantra -d -o "$WORK/js_mantra_results.txt" || true
    else
	    echo "[!] Mantra not installed or no JS URLs found, skipping Mantra."
    fi

    # Parameter discovery (Arjun)
    if command -v arjun >/dev/null 2>&1 && [ -s "$WORK/php_urls.txt" ]; then
        echo "[*] Running Arjun on PHP files..."
        arjun -i "$WORK/php_urls.txt" -o "$WORK/arjun_params.txt" -t 5 || true
    fi

    echo "[✔] Done: $TARGET → $WORK/"
}

# --------------------------
# 6. Main loop (parallel support)
# --------------------------
for TARGET in "${TARGETS[@]}"; do
    collect_urls "$TARGET" &
    if [[ $(jobs -r -p | wc -l) -ge $THREADS ]]; then
        wait -n
    fi
done
wait

echo "================================================="
echo "[✓] URL gathering completed for all targets."
echo "Results saved in: $OUTDIR/"

