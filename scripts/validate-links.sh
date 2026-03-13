#!/bin/bash
# validate-links.sh — Check all URLs in README.md are reachable
#
# Usage: validate-links.sh [--verbose]
#
# Extracts all https:// URLs from README.md and checks each one
# with a HEAD request. Reports dead links and a summary.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
README="$REPO_DIR/README.md"

VERBOSE=0
if [[ "${1:-}" == "--verbose" ]]; then
    VERBOSE=1
fi

if [[ ! -f "$README" ]]; then
    echo "ERROR: $README not found" >&2
    exit 1
fi

# ─── Extract unique URLs ────────────────────────────────────────────

urls=$(grep -oE 'https://[^ )">]+' "$README" | sort -u)
total=$(echo "$urls" | wc -l | tr -d ' ')

echo "=== Validate Links: README.md ==="
echo "Found $total unique URLs"
echo ""

# ─── Check each URL ─────────────────────────────────────────────────

ok=0
fail=0
failures=""

while IFS= read -r url; do
    # Skip empty lines
    [[ -z "$url" ]] && continue

    http_code=$(curl -o /dev/null -s -w "%{http_code}" --head --max-time 10 -L "$url" 2>/dev/null || echo "000")

    if [[ "$http_code" -ge 200 && "$http_code" -lt 400 ]]; then
        ok=$((ok + 1))
        if [[ $VERBOSE -eq 1 ]]; then
            echo "  OK    $http_code  $url"
        fi
    else
        fail=$((fail + 1))
        echo "  FAIL  $http_code  $url"
        failures="$failures  $http_code  $url"$'\n'
    fi
done <<< "$urls"

# ─── Summary ────────────────────────────────────────────────────────

echo ""
echo "=== Summary ==="
echo "OK:   $ok"
echo "Fail: $fail"
echo "Total: $total"

if [[ $fail -gt 0 ]]; then
    echo ""
    echo "Dead links:"
    echo -n "$failures"
    exit 1
fi
