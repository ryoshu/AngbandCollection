#!/bin/bash
# verify-builds.sh — Attempt to build each variant with Makefile.osx-modern and report results
#
# Usage: verify-builds.sh [--only VARIANT] [--clean-only] [--jobs N]
#
# For each variant with Makefile.osx-modern:
#   1. Run make clean
#   2. Run make -f Makefile.osx-modern
#   3. Record success/failure/warnings
#   4. Generate summary report

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PRESERVED_DIR="$REPO_DIR/preserved"
REPORT_FILE="$REPO_DIR/build-report.txt"

ONLY=""
CLEAN_ONLY=0
JOBS=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --only)       ONLY="$2"; shift 2 ;;
        --clean-only) CLEAN_ONLY=1; shift ;;
        --jobs)       JOBS="$2"; shift 2 ;;
        -*)           echo "Unknown option: $1" >&2; exit 1 ;;
        *)            echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

# ─── Counters ───────────────────────────────────────────────────────

PASS=0
FAIL=0
WARN=0
SKIP=0
RESULTS=""

# ─── Build function ─────────────────────────────────────────────────

build_variant() {
    local name="$1"
    local variant_dir="$PRESERVED_DIR/$name"

    # Find src dir
    local srcdir=""
    if [[ -d "$variant_dir/src" ]]; then
        srcdir="$variant_dir/src"
    elif [[ -d "$variant_dir/Source" ]]; then
        srcdir="$variant_dir/Source"
    fi

    if [[ -z "$srcdir" || ! -f "$srcdir/Makefile.osx-modern" ]]; then
        return 1
    fi

    local log_file="$srcdir/build-osx-modern.log"
    local make_args="-f Makefile.osx-modern"
    if [[ -n "$JOBS" ]]; then
        make_args="$make_args -j$JOBS"
    fi

    # Clean first
    (cd "$srcdir" && make $make_args clean > /dev/null 2>&1) || true

    if [[ $CLEAN_ONLY -eq 1 ]]; then
        echo "CLEAN"
        return 0
    fi

    # Build
    local exit_code=0
    (cd "$srcdir" && make $make_args install-terminal > "$log_file" 2>&1) || exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        # Check for warnings
        local warn_count
        warn_count=$(grep -c -i 'warning:' "$log_file" 2>/dev/null || echo 0)
        if [[ $warn_count -gt 0 ]]; then
            echo "WARN:$warn_count"
        else
            echo "PASS"
        fi
    else
        # Extract first error
        local first_error
        first_error=$(grep -m1 -i 'error:' "$log_file" 2>/dev/null || echo "exit code $exit_code")
        echo "FAIL:$first_error"
    fi

    return 0
}

# ─── Main loop ──────────────────────────────────────────────────────

echo "=== Verify Builds: Angband Variants ==="
echo "Report: $REPORT_FILE"
echo ""

{
    echo "Build Verification Report"
    echo "========================="
    echo "Date: $(date)"
    echo "System: $(uname -mrs)"
    echo "Compiler: $(clang --version 2>/dev/null | head -1)"
    echo "SDK: $(xcrun --show-sdk-path 2>/dev/null || echo 'N/A')"
    echo ""
} > "$REPORT_FILE"

for variant_dir in "$PRESERVED_DIR"/*/; do
    name="$(basename "$variant_dir")"

    # Filter to single variant if --only
    if [[ -n "$ONLY" && "$name" != "$ONLY" ]]; then
        continue
    fi

    # Find Makefile.osx-modern
    srcdir=""
    if [[ -f "$variant_dir/src/Makefile.osx-modern" ]]; then
        srcdir="$variant_dir/src"
    elif [[ -f "$variant_dir/Source/Makefile.osx-modern" ]]; then
        srcdir="$variant_dir/Source"
    fi

    if [[ -z "$srcdir" ]]; then
        SKIP=$((SKIP + 1))
        continue
    fi

    echo -n "Building $name ... "

    result=$(build_variant "$name")
    status="${result%%:*}"
    detail="${result#*:}"

    case "$status" in
        PASS)
            echo "PASS"
            PASS=$((PASS + 1))
            RESULTS="$RESULTS  PASS    $name"$'\n'
            ;;
        WARN)
            echo "WARN ($detail warnings)"
            WARN=$((WARN + 1))
            RESULTS="$RESULTS  WARN    $name ($detail warnings)"$'\n'
            ;;
        FAIL)
            echo "FAIL"
            echo "         $detail"
            FAIL=$((FAIL + 1))
            RESULTS="$RESULTS  FAIL    $name: $detail"$'\n'
            ;;
        CLEAN)
            echo "cleaned"
            ;;
    esac
done

# ─── Summary ────────────────────────────────────────────────────────

TOTAL=$((PASS + WARN + FAIL))

echo ""
echo "=== Build Summary ==="
echo "Total attempted: $TOTAL"
echo "Pass:            $PASS"
echo "Warnings:        $WARN"
echo "Fail:            $FAIL"
echo "Skipped (no Makefile.osx-modern): $SKIP"

{
    echo "Summary"
    echo "-------"
    echo "Total: $TOTAL  Pass: $PASS  Warn: $WARN  Fail: $FAIL  Skip: $SKIP"
    echo ""
    echo "Results"
    echo "-------"
    echo -n "$RESULTS"
} >> "$REPORT_FILE"

echo ""
echo "Full report: $REPORT_FILE"

# Exit with failure if any builds failed
if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
