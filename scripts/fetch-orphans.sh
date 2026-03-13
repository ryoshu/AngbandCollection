#!/bin/bash
# fetch-orphans.sh — Download orphaned Angband variants for preservation
#
# Usage: fetch-orphans.sh <url> <variant-name>
#        fetch-orphans.sh --from-list <file>
#
# Downloads a variant archive from a URL, extracts it into /preserved/<name>/,
# and prepares it for the repository.
#
# Supported archive formats: .tar.gz, .tar.bz2, .zip
#
# List file format (one per line):
#   <url> <variant-name>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PRESERVED_DIR="$REPO_DIR/preserved"

# ─── Functions ───────────────────────────────────────────────────────

usage() {
    echo "Usage: $0 <url> <variant-name>"
    echo "       $0 --from-list <file>"
    echo ""
    echo "Downloads an orphaned variant archive and extracts it into preserved/<name>/"
    exit 1
}

fetch_variant() {
    local url="$1"
    local name="$2"
    local dest="$PRESERVED_DIR/$name"

    if [[ -d "$dest" ]]; then
        echo "  SKIP  $name — already exists at $dest"
        return 0
    fi

    echo "  FETCH $name from $url"

    local tmpdir
    tmpdir=$(mktemp -d)
    local archive="$tmpdir/archive"

    # Download
    if ! curl -sL -o "$archive" --max-time 120 "$url"; then
        echo "  FAIL  $name — download failed"
        rm -rf "$tmpdir"
        return 1
    fi

    # Detect format and extract
    local filetype
    filetype=$(file -b "$archive")

    mkdir -p "$dest"

    case "$filetype" in
        *gzip*)
            tar xzf "$archive" -C "$tmpdir/extract" 2>/dev/null || {
                mkdir -p "$tmpdir/extract"
                tar xzf "$archive" -C "$tmpdir/extract"
            }
            ;;
        *bzip2*)
            mkdir -p "$tmpdir/extract"
            tar xjf "$archive" -C "$tmpdir/extract"
            ;;
        *Zip*)
            mkdir -p "$tmpdir/extract"
            unzip -q "$archive" -d "$tmpdir/extract"
            ;;
        *)
            echo "  FAIL  $name — unsupported archive format: $filetype"
            rm -rf "$tmpdir"
            rmdir "$dest" 2>/dev/null || true
            return 1
            ;;
    esac

    # If the archive extracted into a single subdirectory, move its contents up
    local extracted_dirs
    extracted_dirs=$(find "$tmpdir/extract" -mindepth 1 -maxdepth 1 -type d)
    local dir_count
    dir_count=$(echo "$extracted_dirs" | grep -c '.' || echo 0)

    if [[ $dir_count -eq 1 ]]; then
        # Single directory — move its contents into dest
        cp -R "$extracted_dirs"/* "$dest"/ 2>/dev/null || true
        cp -R "$extracted_dirs"/.* "$dest"/ 2>/dev/null || true
    else
        # Multiple items — move everything
        cp -R "$tmpdir/extract"/* "$dest"/ 2>/dev/null || true
    fi

    rm -rf "$tmpdir"

    echo "  OK    $name — extracted to $dest"

    # Report what we got
    local src_count=0
    for ext in c h cpp; do
        src_count=$((src_count + $(find "$dest" -name "*.$ext" 2>/dev/null | wc -l | tr -d ' ')))
    done
    echo "        $src_count source files found"
}

# ─── Main ────────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
    usage
fi

echo "=== Fetch Orphans ==="
echo ""

if [[ "$1" == "--from-list" ]]; then
    if [[ $# -lt 2 || ! -f "$2" ]]; then
        echo "ERROR: --from-list requires a valid file path" >&2
        exit 1
    fi

    ok=0
    fail=0

    while IFS=' ' read -r url name; do
        # Skip comments and blank lines
        [[ -z "$url" || "$url" == \#* ]] && continue

        if fetch_variant "$url" "$name"; then
            ok=$((ok + 1))
        else
            fail=$((fail + 1))
        fi
    done < "$2"

    echo ""
    echo "=== Summary ==="
    echo "OK:   $ok"
    echo "Fail: $fail"

    [[ $fail -gt 0 ]] && exit 1
else
    if [[ $# -lt 2 ]]; then
        usage
    fi

    fetch_variant "$1" "$2"
fi
