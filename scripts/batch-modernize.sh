#!/bin/bash
# batch-modernize.sh — Generate Makefile.osx-modern for all preserved Angband variants
#
# Usage: batch-modernize.sh [--dry-run] [--only VARIANT] [--force]
#
# Iterates preserved/ variants, classifies them, and calls generate-makefile.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PRESERVED_DIR="$REPO_DIR/preserved"
GENERATOR="$SCRIPT_DIR/generate-makefile.sh"

DRY_RUN=0
ONLY=""
FORCE=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)  DRY_RUN=1; shift ;;
        --only)     ONLY="$2"; shift 2 ;;
        --force)    FORCE=1; shift ;;
        -*)         echo "Unknown option: $1" >&2; exit 1 ;;
        *)          echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

# ─── Counters ───────────────────────────────────────────────────────

COUNT_SKIP=0
COUNT_EXISTING=0
COUNT_GENERATED=0
COUNT_FAILED=0
COUNT_SPECIAL=0

LOG_SKIP=""
LOG_EXISTING=""
LOG_GENERATED=""
LOG_FAILED=""
LOG_SPECIAL=""

log_skip()      { COUNT_SKIP=$((COUNT_SKIP + 1));      LOG_SKIP="$LOG_SKIP  $1: $2"$'\n'; }
log_existing()  { COUNT_EXISTING=$((COUNT_EXISTING+1)); LOG_EXISTING="$LOG_EXISTING  $1"$'\n'; }
log_generated() { COUNT_GENERATED=$((COUNT_GENERATED+1)); LOG_GENERATED="$LOG_GENERATED  $1"$'\n'; }
log_failed()    { COUNT_FAILED=$((COUNT_FAILED + 1));   LOG_FAILED="$LOG_FAILED  $1: $2"$'\n'; }
log_special()   { COUNT_SPECIAL=$((COUNT_SPECIAL+1));   LOG_SPECIAL="$LOG_SPECIAL  $1: $2"$'\n'; }

# ─── Classification ─────────────────────────────────────────────────

classify_variant() {
    local name="$1"
    local dir="$PRESERVED_DIR/$name"

    # SKIP: known incompatible variants
    case "$name" in
        IronHells)
            echo "SKIP:client/server architecture"
            return ;;
        Utumno)
            echo "SKIP:C++ codebase"
            return ;;
    esac

    # Check for src/ or Source/
    local srcdir=""
    if [[ -d "$dir/src" ]]; then
        srcdir="$dir/src"
    elif [[ -d "$dir/Source" ]]; then
        srcdir="$dir/Source"
    else
        echo "SKIP:no src/ directory"
        return
    fi

    # Check for main-gcu.c (required for terminal build) — also check uppercase .C
    if [[ ! -f "$srcdir/main-gcu.c" && ! -f "$srcdir/MAIN-GCU.C" ]]; then
        # Check if it's a Moria-style variant (has io.c or curses usage in main.c)
        if [[ -f "$srcdir/main.c" ]] && grep -q 'curses\|ncurses\|initscr' "$srcdir/main.c" 2>/dev/null; then
            echo "SPECIAL:curses in main.c (no main-gcu.c)"
        else
            echo "SKIP:no main-gcu.c (no terminal interface)"
        fi
        return
    fi

    # Check for .c files at all (either case)
    local c_count
    c_count=$( (ls "$srcdir"/*.c "$srcdir"/*.C 2>/dev/null || true) | wc -l)
    if [[ "$c_count" -eq 0 ]]; then
        echo "SKIP:no .c files"
        return
    fi

    echo "STANDARD"
}

# ─── Generate BUILD-MODERN-MACOS.md ────────────────────────────────

generate_build_doc() {
    local variant_dir="$1"
    local name="$2"
    local exe="$3"
    local doc_path="$variant_dir/BUILD-MODERN-MACOS.md"

    # Don't overwrite existing docs unless --force
    if [[ -f "$doc_path" && $FORCE -eq 0 ]]; then
        return
    fi

    cat > "$doc_path" << BUILDDOC
# Building ${name} on Modern macOS

This document describes how to build ${name} on modern macOS systems (macOS 10.15+, including Apple Silicon Macs).

## Prerequisites

- Xcode Command Line Tools: \`xcode-select --install\`
- macOS 10.15 or later

## Quick Build

For a terminal-based version (recommended):

\`\`\`bash
cd src
make -f Makefile.osx-modern clean
make -f Makefile.osx-modern install-terminal
\`\`\`

This creates \`${exe}-terminal\` in the parent directory.

## Build Options

### Terminal Version (Curses Interface)
\`\`\`bash
# Build for current architecture (Apple Silicon or Intel)
make -f Makefile.osx-modern install-terminal

# Build universal binary (both architectures)
make -f Makefile.osx-modern install-terminal UNIVERSAL=1
\`\`\`

### Available Targets
- \`${exe}\` - Build executable only
- \`install-terminal\` - Build and install terminal version
- \`clean\` - Clean build artifacts
- \`help\` - Show available options

### Build Options
- \`UNIVERSAL=1\` - Create universal binary (x86_64 + arm64)
- \`OPT=-O3\` - Change optimization level

## Running the Game

After building:
\`\`\`bash
# From the main ${name} directory:
./${exe}-terminal
\`\`\`

## Changes from Original

The modern macOS build makes these key changes:

1. **Frontend**: Uses curses (terminal) instead of platform-specific GUIs
2. **Compiler**: Uses modern clang with current SDK
3. **Architecture**: Builds for Apple Silicon by default, with universal option
4. **SDKs**: Uses current Xcode SDK path detection

## Troubleshooting

### Common Issues

**"Cannot access the './lib/file/news.txt' file!"**
- Make sure you're running from the ${name} directory (where lib/ is)
- The lib/ directory must be present with all game data

**Compilation Errors**
- Ensure Xcode Command Line Tools are installed
- Check that you're using the modern Makefile: \`Makefile.osx-modern\`

**Architecture Issues**
- For Intel Macs: The build should work automatically
- For Apple Silicon: The build defaults to arm64
- For universal: Use \`UNIVERSAL=1\` option
BUILDDOC
}

# ─── Main loop ──────────────────────────────────────────────────────

echo "=== Batch Modernize Angband Variants ==="
echo "Preserved dir: $PRESERVED_DIR"
echo ""

for variant_dir in "$PRESERVED_DIR"/*/; do
    name="$(basename "$variant_dir")"

    # Filter to single variant if --only
    if [[ -n "$ONLY" && "$name" != "$ONLY" ]]; then
        continue
    fi

    classification=$(classify_variant "$name")
    status="${classification%%:*}"
    reason="${classification#*:}"

    case "$status" in
        SKIP)
            log_skip "$name" "$reason"
            echo "SKIP    $name — $reason"
            continue
            ;;
        SPECIAL)
            log_special "$name" "$reason"
            echo "SPECIAL $name — $reason"
            continue
            ;;
    esac

    # Check if already has Makefile.osx-modern
    srcdir="src"
    [[ -d "$variant_dir/Source" && ! -d "$variant_dir/src" ]] && srcdir="Source"

    if [[ -f "$variant_dir/$srcdir/Makefile.osx-modern" && $FORCE -eq 0 ]]; then
        log_existing "$name"
        echo "EXISTS  $name — already has Makefile.osx-modern"
        continue
    fi

    # Generate
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "WOULD   $name — would generate Makefile.osx-modern"
        log_generated "$name"
        continue
    fi

    echo -n "GEN     $name ... "

    # Build generator args
    gen_args=("$variant_dir")

    # Variant-specific overrides
    case "$name" in
        NuAngband)
            gen_args+=(--name "NuAngband" --exe "nuangband")
            ;;
        GSNband)
            gen_args+=(--exe "gsnband")
            ;;
        MJBand)
            gen_args+=(--exe "mjband")
            ;;
        PziAngband)
            gen_args+=(--exe "pziangband")
            ;;
    esac

    if output=$("$GENERATOR" "${gen_args[@]}" 2>&1); then
        echo "OK"
        log_generated "$name"

        # Generate BUILD doc
        exe=$(echo "$name" | tr '[:upper:]' '[:lower:]')
        case "$name" in
            GSNband) exe="gsnband" ;;
            MJBand) exe="mjband" ;;
            PziAngband) exe="pziangband" ;;
        esac
        generate_build_doc "$variant_dir" "$name" "$exe"
    else
        echo "FAILED"
        echo "  $output" | head -5
        log_failed "$name" "$(echo "$output" | head -1)"
    fi
done

# ─── Summary ────────────────────────────────────────────────────────

echo ""
echo "=== Summary ==="
echo "Generated:  $COUNT_GENERATED"
echo "Existing:   $COUNT_EXISTING"
echo "Skipped:    $COUNT_SKIP"
echo "Special:    $COUNT_SPECIAL"
echo "Failed:     $COUNT_FAILED"

if [[ -n "$LOG_SKIP" ]]; then
    echo ""
    echo "--- Skipped ---"
    echo -n "$LOG_SKIP"
fi

if [[ -n "$LOG_SPECIAL" ]]; then
    echo ""
    echo "--- Special (needs manual handling) ---"
    echo -n "$LOG_SPECIAL"
fi

if [[ -n "$LOG_FAILED" ]]; then
    echo ""
    echo "--- Failed ---"
    echo -n "$LOG_FAILED"
fi

if [[ -n "$LOG_EXISTING" ]]; then
    echo ""
    echo "--- Already existing ---"
    echo -n "$LOG_EXISTING"
fi

if [[ -n "$LOG_GENERATED" ]]; then
    echo ""
    echo "--- Generated ---"
    echo -n "$LOG_GENERATED"
fi
