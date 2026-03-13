#!/bin/bash
# generate-makefile.sh — Generate Makefile.osx-modern for a single Angband variant
#
# Usage: generate-makefile.sh <variant-dir> [--name NAME] [--exe EXE] [--version VERSION]
#
# Generates src/Makefile.osx-modern (or Source/Makefile.osx-modern for NuAngband)
# by detecting source files from existing build files and parameterizing a template.

set -euo pipefail

# ─── Argument parsing ───────────────────────────────────────────────

VARIANT_DIR=""
OPT_NAME=""
OPT_EXE=""
OPT_VERSION=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)    OPT_NAME="$2"; shift 2 ;;
        --exe)     OPT_EXE="$2"; shift 2 ;;
        --version) OPT_VERSION="$2"; shift 2 ;;
        -*)        echo "Unknown option: $1" >&2; exit 1 ;;
        *)         VARIANT_DIR="$1"; shift ;;
    esac
done

if [[ -z "$VARIANT_DIR" ]]; then
    echo "Usage: $0 <variant-dir> [--name NAME] [--exe EXE] [--version VERSION]" >&2
    exit 1
fi

# Resolve to absolute path
VARIANT_DIR="$(cd "$VARIANT_DIR" && pwd)"
VARIANT_BASENAME="$(basename "$VARIANT_DIR")"

# ─── Detect source directory ────────────────────────────────────────

if [[ -d "$VARIANT_DIR/src" ]]; then
    SRCDIR="$VARIANT_DIR/src"
    SRCREL="src"
elif [[ -d "$VARIANT_DIR/Source" ]]; then
    SRCDIR="$VARIANT_DIR/Source"
    SRCREL="Source"
else
    echo "ERROR: No src/ or Source/ directory in $VARIANT_DIR" >&2
    exit 1
fi

# ─── Derive variant metadata ───────────────────────────────────────

NAME="${OPT_NAME:-$VARIANT_BASENAME}"
EXE="${OPT_EXE:-$(echo "$NAME" | tr '[:upper:]' '[:lower:]')}"
VERSION="${OPT_VERSION:-1.0.0}"

# Try to extract version from existing build files
if [[ -z "$OPT_VERSION" ]]; then
    for f in "$SRCDIR"/Makefile.src "$SRCDIR"/Makefile.am "$SRCDIR"/configure.ac "$SRCDIR"/../configure.ac; do
        if [[ -f "$f" ]]; then
            v=$(grep -oE 'VERSION\s*=\s*[0-9][0-9.a-zA-Z]+' "$f" 2>/dev/null | head -1 | sed 's/.*=\s*//' || true)
            if [[ -n "$v" ]]; then
                VERSION="$v"
                break
            fi
        fi
    done
fi

# ─── Detect if app bundle resources exist ───────────────────────────

HAS_OSX_BUNDLE=0
BUNDLE_DIR=""
if [[ -d "$SRCDIR/osx" ]]; then
    HAS_OSX_BUNDLE=1
    BUNDLE_DIR="osx"
elif [[ -d "$SRCDIR/cocoa" ]]; then
    HAS_OSX_BUNDLE=1
    BUNDLE_DIR="cocoa"
fi

# ─── Detect lib/ layout ────────────────────────────────────────────

LIB_LAYOUT="classic"
if [[ -d "$VARIANT_DIR/lib/gamedata" ]]; then
    LIB_LAYOUT="modern"
fi

# ─── Detect if Makefile.src exists (ComPosband-style) ───────────────

HAS_MAKEFILE_SRC=0
if [[ -f "$SRCDIR/Makefile.src" ]]; then
    # Check if it defines ANGFILES or similar obj variables
    if grep -qE '(ANGFILES|ZFILES|CFILES)\s*=' "$SRCDIR/Makefile.src"; then
        HAS_MAKEFILE_SRC=1
    fi
fi

# ─── Extract source files ──────────────────────────────────────────
# Priority: Makefile.std > Makefile.am > Makefile.src > Makefile > glob *.c

extract_srcs_from_makefile() {
    local mkfile="$1"
    local varname="$2"
    # Extract multi-line variable assignment (handles backslash continuations)
    # Strip \r for CRLF files first; || true prevents pipefail exit on no match
    tr -d '\r' < "$mkfile" | \
        sed -n "/^${varname}[[:space:]]*=[[:space:]]*/,/[^\\\\]$/p" | \
        sed "s/^${varname}[[:space:]]*=[[:space:]]*//" | \
        tr '\\' ' ' | tr '\n' ' ' | \
        (grep -oE '[a-zA-Z0-9_-]+\.c' || true) | \
        sort -u
}

extract_objs_from_makefile() {
    local mkfile="$1"
    local varname="$2"
    tr -d '\r' < "$mkfile" | \
        sed -n "/^${varname}[[:space:]]*=[[:space:]]*/,/[^\\\\]$/p" | \
        sed "s/^${varname}[[:space:]]*=[[:space:]]*//" | \
        tr '\\' ' ' | tr '\n' ' ' | \
        (grep -oE '[a-zA-Z0-9_-]+\.o' || true) | \
        sed 's/\.o$/.c/' | \
        sort -u
}

RAW_SRCS=""

# Try Makefile.std first
if [[ -f "$SRCDIR/Makefile.std" ]]; then
    RAW_SRCS=$(extract_srcs_from_makefile "$SRCDIR/Makefile.std" "SRCS")
    if [[ -z "$RAW_SRCS" ]]; then
        RAW_SRCS=$(extract_objs_from_makefile "$SRCDIR/Makefile.std" "OBJS")
    fi
fi

# Try Makefile.am
if [[ -z "$RAW_SRCS" && -f "$SRCDIR/Makefile.am" ]]; then
    # Makefile.am uses progname_SOURCES (with various progname patterns)
    RAW_SRCS=$(tr -d '\r' < "$SRCDIR/Makefile.am" | \
        sed -n '/SOURCES\s*=\s*/,/[^\\]$/p' | \
        tr '\\' ' ' | tr '\n' ' ' | \
        (grep -oE '[a-zA-Z0-9_-]+\.c' || true) | \
        sort -u)
fi

# Try Makefile.src (non-ComPosband style, or simple SRCS)
if [[ -z "$RAW_SRCS" && -f "$SRCDIR/Makefile.src" && "$HAS_MAKEFILE_SRC" -eq 0 ]]; then
    RAW_SRCS=$(extract_srcs_from_makefile "$SRCDIR/Makefile.src" "SRCS")
fi

# Try plain Makefile
if [[ -z "$RAW_SRCS" && -f "$SRCDIR/Makefile" ]]; then
    RAW_SRCS=$(extract_srcs_from_makefile "$SRCDIR/Makefile" "SRCS")
    if [[ -z "$RAW_SRCS" ]]; then
        RAW_SRCS=$(extract_srcs_from_makefile "$SRCDIR/Makefile" "SOURCES")
    fi
    if [[ -z "$RAW_SRCS" ]]; then
        RAW_SRCS=$(extract_objs_from_makefile "$SRCDIR/Makefile" "OBJS")
    fi
    if [[ -z "$RAW_SRCS" ]]; then
        RAW_SRCS=$(extract_objs_from_makefile "$SRCDIR/Makefile" "OBJECTS")
    fi
    if [[ -z "$RAW_SRCS" ]]; then
        RAW_SRCS=$(extract_objs_from_makefile "$SRCDIR/Makefile" "OBJ")
    fi
fi

# Fallback: glob all .c files in src/ (try both .c and .C for uppercase variants)
if [[ -z "$RAW_SRCS" ]]; then
    RAW_SRCS=$(cd "$SRCDIR" && (ls *.c *.C 2>/dev/null || true) | sort -u)
fi

if [[ -z "$RAW_SRCS" ]]; then
    echo "ERROR: No source files found in $SRCDIR" >&2
    exit 1
fi

# ─── Filter sources for macOS terminal build ────────────────────────
# Keep: main.c, main-gcu.c, and all non-main-* files
# Exclude: main-win.c, main-dos.c, main-x11.c, main-gtk.c, main-sdl.c,
#          main-mac.c, main-crb.c, main-cap.c, main-xaw.c, main-ami.c,
#          main-acn.c, main-ibm.c, main-emx.c, main-286.c, main-lsl.c,
#          main-ros.c, main-sla.c, main-xpj.c, main-vcs.c, main-nds.c,
#          maid-x11.c, readdib.c, *.res files
# Also exclude header files (.h) that might have been captured

FILTERED_SRCS=""
HAS_MAIN=0
HAS_MAIN_GCU=0

for src in $RAW_SRCS; do
    # Normalize: convert case pattern for matching (keep original for filename)
    src_lower=$(echo "$src" | tr '[:upper:]' '[:lower:]')

    # Skip non-.c files
    case "$src_lower" in
        *.h|*.H) continue ;;
    esac

    # Check if file actually exists
    if [[ ! -f "$SRCDIR/$src" ]]; then
        continue
    fi

    case "$src_lower" in
        main.c)
            HAS_MAIN=1
            FILTERED_SRCS="$FILTERED_SRCS $src"
            ;;
        main-gcu.c)
            HAS_MAIN_GCU=1
            FILTERED_SRCS="$FILTERED_SRCS $src"
            ;;
        main-*.c|maid-*.c|readdib.c)
            # Skip platform-specific drivers
            ;;
        *)
            FILTERED_SRCS="$FILTERED_SRCS $src"
            ;;
    esac
done

# Ensure main.c and main-gcu.c are present (check both cases)
if [[ $HAS_MAIN -eq 0 ]]; then
    if [[ -f "$SRCDIR/main.c" ]]; then
        FILTERED_SRCS="$FILTERED_SRCS main.c"
    elif [[ -f "$SRCDIR/MAIN.C" ]]; then
        FILTERED_SRCS="$FILTERED_SRCS MAIN.C"
    fi
fi
if [[ $HAS_MAIN_GCU -eq 0 ]]; then
    if [[ -f "$SRCDIR/main-gcu.c" ]]; then
        FILTERED_SRCS="$FILTERED_SRCS main-gcu.c"
    elif [[ -f "$SRCDIR/MAIN-GCU.C" ]]; then
        FILTERED_SRCS="$FILTERED_SRCS MAIN-GCU.C"
    fi
fi

# Trim leading space and sort
FILTERED_SRCS=$(echo "$FILTERED_SRCS" | tr ' ' '\n' | sed '/^$/d' | sort -u)

if [[ -z "$FILTERED_SRCS" ]]; then
    echo "ERROR: No source files after filtering for $VARIANT_BASENAME" >&2
    exit 1
fi

# ─── Format source list ────────────────────────────────────────────
# Group into lines of ~5 files for readability

format_file_list() {
    local ext="$1"
    local files="$2"
    local count=0
    local line="  "
    local result=""

    while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        if [[ $ext == "o" ]]; then
            if [[ "$f" == *.c ]]; then
                f="${f%.c}.o"
            elif [[ "$f" == *.C ]]; then
                f="${f%.C}.o"
            fi
        fi
        if [[ $count -ge 5 ]]; then
            result="${result}${line} \\
"
            line="  $f"
            count=1
        else
            if [[ $count -eq 0 ]]; then
                line="  $f"
            else
                line="$line $f"
            fi
            count=$((count + 1))
        fi
    done <<< "$files"
    result="${result}${line}"
    echo "$result"
}

SRCS_FORMATTED=$(format_file_list "c" "$FILTERED_SRCS")
OBJS_FORMATTED=$(format_file_list "o" "$FILTERED_SRCS")

# ─── Pattern rule (no header deps — simpler and more robust) ──────
# Header dependency tracking is unnecessary for one-shot builds and
# causes failures when header names don't match filesystem case or
# when expected headers are missing.

# Check if any source files use uppercase .C extension
HAS_UPPERCASE_C=0
if ls "$SRCDIR"/*.C >/dev/null 2>&1; then
    # Verify there are actual uppercase .C files (not just case-insensitive matches)
    if python3 -c "import os; exit(0 if any(f.endswith('.C') for f in os.listdir('$SRCDIR')) else 1)" 2>/dev/null; then
        HAS_UPPERCASE_C=1
    fi
fi

if [[ $HAS_UPPERCASE_C -eq 1 ]]; then
    HDRS_SECTION="# Compilation rules (handles both .c and .C source files)
%.o: %.c
	\$(CC) \$(CFLAGS) -c -o \$@ \$<

%.o: %.C
	\$(CC) \$(CFLAGS) -c -o \$@ \$<"
else
    HDRS_SECTION="# Compilation rule
%.o: %.c
	\$(CC) \$(CFLAGS) -c -o \$@ \$<"
fi

# ─── Determine default target ──────────────────────────────────────

if [[ $HAS_OSX_BUNDLE -eq 1 ]]; then
    DEFAULT_TARGET="install"
else
    DEFAULT_TARGET="install-terminal"
fi

# ─── Detect variant-specific CFLAGS needs ─────────────────────────

# Build optional CFLAGS += line for variant-specific needs
EXTRA_CFLAGS_PARTS=""

# Some variants reference DEFAULT_CONFIG_PATH etc. in their C source
if grep -rql 'DEFAULT_CONFIG_PATH' "$SRCDIR"/*.c 2>/dev/null; then
    EXTRA_CFLAGS_PARTS="$EXTRA_CFLAGS_PARTS -DDEFAULT_CONFIG_PATH=\\\"./lib\\\" -DDEFAULT_LIB_PATH=\\\"./lib\\\" -DDEFAULT_DATA_PATH=\\\"./lib/data\\\""
fi

# Note: Some variants used 'restrict' as a variable name (C99 keyword conflict).
# These have been fixed by renaming to 'class_restrict' in source directly,
# since -Drestrict= breaks system headers that use restrict as a keyword.

EXTRA_CFLAGS_LINE=""
if [[ -n "$EXTRA_CFLAGS_PARTS" ]]; then
    EXTRA_CFLAGS_LINE="CFLAGS +=$EXTRA_CFLAGS_PARTS"
fi

# ─── Generate the Makefile ─────────────────────────────────────────

OUTPUT="$SRCDIR/Makefile.osx-modern"

# Build the LIBFILES and install sections based on lib layout
if [[ "$LIB_LAYOUT" == "modern" ]]; then
    LIBFILES_SECTION='LIBFILES = \
  ../lib/gamedata/*.txt \
  ../lib/help/*.txt \
  ../lib/pref/*.prf \
  ../lib/sounds/*.mp3'

    INSTALL_BUNDLE_LIBDIRS='	@mkdir -p $(APPRES)/lib/gamedata
	@mkdir -p $(APPRES)/lib/data
	@mkdir -p $(APPRES)/lib/save
	@mkdir -p $(APPRES)/lib/help
	@mkdir -p $(APPRES)/lib/pref
	@mkdir -p $(APPRES)/lib/sounds
	@mkdir -p $(APPRES)/lib/icons
	@mkdir -p $(APPRES)/lib/tiles'

    INSTALL_BUNDLE_COPY='	@cp ../lib/gamedata/*.txt $(APPRES)/lib/gamedata
	@cp ../lib/help/*.txt $(APPRES)/lib/help
	@cp ../lib/pref/*.prf $(APPRES)/lib/pref

	# Optionally install sound and graphics tiles, if present
	-cp -f ../lib/sounds/*.mp3 $(APPRES)/lib/sounds
	-cp -f ../lib/tiles/*.png $(APPRES)/lib/tiles
	-cp -f ../lib/icons/*.png $(APPRES)/lib/icons'
else
    LIBFILES_SECTION='LIBFILES = \
  ../lib/edit/*.txt \
  ../lib/file/*.txt \
  ../lib/help/*.txt \
  ../lib/help/*.hlp \
  ../lib/pref/*.prf'

    INSTALL_BUNDLE_LIBDIRS='	@mkdir -p $(APPRES)/lib/edit
	@mkdir -p $(APPRES)/lib/file
	@mkdir -p $(APPRES)/lib/apex
	@mkdir -p $(APPRES)/lib/data
	@mkdir -p $(APPRES)/lib/save
	@mkdir -p $(APPRES)/lib/help
	@mkdir -p $(APPRES)/lib/pref
	@mkdir -p $(APPRES)/lib/script
	@mkdir -p $(APPRES)/lib/xtra/graf
	@mkdir -p $(APPRES)/lib/xtra/sound'

    INSTALL_BUNDLE_COPY='	@cp ../lib/edit/*.txt $(APPRES)/lib/edit
	@cp ../lib/file/*.txt $(APPRES)/lib/file
	@cp ../lib/help/*.txt $(APPRES)/lib/help
	-cp -f ../lib/help/*.hlp $(APPRES)/lib/help
	@cp ../lib/pref/*.prf $(APPRES)/lib/pref

	# Optionally install sound and graphics tiles, if present
	-cp -f ../lib/xtra/graf/*.png $(APPRES)/lib/xtra/graf
	-cp -f ../lib/xtra/sound/*.wav $(APPRES)/lib/xtra/sound'
fi

# ─── Handle ComPosband-style Makefile.src include ──────────────────
# If Makefile.src defines ANGFILES/ZFILES/CFILES, use include instead of inline SRCS

if [[ $HAS_MAKEFILE_SRC -eq 1 ]]; then
    SRCS_BLOCK="# Import the source file list from the variant's build system
include Makefile.src

# All object files - explicit expansion required
OBJS = "
    # Detect which variables are defined
    for var in ANGFILES CFILES ZFILES; do
        if grep -qE "^${var}\s*=" "$SRCDIR/Makefile.src"; then
            SRCS_BLOCK="$SRCS_BLOCK\$(${var}) "
        fi
    done
    SRCS_BLOCK="${SRCS_BLOCK}main.o main-gcu.o"
else
    SRCS_BLOCK="# Source files
SRCS = \\
$SRCS_FORMATTED

OBJS = \\
$OBJS_FORMATTED"
fi

# ─── Write the Makefile ────────────────────────────────────────────

cat > "$OUTPUT" << 'MAKEFILE_HEADER'
# File: Makefile.osx-modern
MAKEFILE_HEADER

cat >> "$OUTPUT" << MAKEFILE_META

# Modern macOS Makefile for ${NAME}
# Generated by generate-makefile.sh — updated for current Xcode tools and Apple Silicon/Intel

CC = clang
ifeq (\$(OPT),)
OPT = -O2
endif

# Current Xcode tools path
TOOLDIR = /usr/bin
SETFILE = /usr/bin/SetFile

# Name of the game
APPNAME = ${NAME}.app
EXE = ${EXE}
NAME = ${NAME}
VERSION = ${VERSION}

${SRCS_BLOCK}

# Build for current architecture by default, universal on request
ARCH_FLAGS = -arch \$(shell uname -m)
ifeq (\$(UNIVERSAL),1)
  ARCH_FLAGS = -arch x86_64 -arch arm64
endif

# Modern SDK path detection
XCODE_PATH = \$(shell xcode-select -p)
SDK_PATH = \$(shell xcrun --show-sdk-path)

CFLAGS = \\
	-Wall -std=gnu99 \$(OPT) -I. -DUSE_GCU -DUSE_TRANSPARENCY \\
	-DHAVE_MKSTEMP -DPRIVATE_USER_PATH=\"~/Library/Preferences\" \\
	-DUSE_PRIVATE_PATHS -DALLOW_WIZARD \\
	-DNCURSES_OPAQUE=0 \\
	-Wno-error=implicit-function-declaration \\
	-Wno-error=implicit-int \\
	-Wno-error=int-conversion \\
	-Wno-error=incompatible-function-pointer-types \\
	-Wno-error=incompatible-pointer-types \\
	-Wno-error=return-type \\
	-isysroot \$(SDK_PATH) \$(ARCH_FLAGS)

LDFLAGS = -Wl,-syslibroot,\$(SDK_PATH) \$(ARCH_FLAGS)

${EXTRA_CFLAGS_LINE}

LIBS = -lncurses

# Default target
all: ${DEFAULT_TARGET}

# Build the executable
\$(EXE): \$(OBJS)
	\$(CC) \$(CFLAGS) \$(LDFLAGS) -o \$(EXE) \$(OBJS) \$(LIBS)

# Clean up
clean:
	-rm -f *.o \$(EXE)
	-rm -rf ../\$(APPNAME)

${HDRS_SECTION}

# Application bundle installation
APPBNDL = ../\$(APPNAME)
APPCONT = \$(APPBNDL)/Contents
APPBIN = \$(APPCONT)/MacOS
APPRES = \$(APPCONT)/Resources

MAKEFILE_META

# Write the install target (bundle or terminal-only)
if [[ $HAS_OSX_BUNDLE -eq 1 ]]; then
    # Detect icon/plist paths
    if [[ "$BUNDLE_DIR" == "cocoa" ]]; then
        ICON_LINE="ICONFILES = cocoa/Angband_Icons.icns cocoa/Save.icns cocoa/Edit.icns cocoa/Data.icns"
        PLIST_LINE="PLIST = cocoa/Angband-Cocoa.xml"
        NIB_DIR="cocoa/English.lproj/MainMenu.nib"
        NIB_DEST="English.lproj/MainMenu.nib"
    else
        ICON_LINE="ICONFILES = osx/\$(NAME).icns osx/Save.icns osx/Edit.icns osx/Data.icns"
        PLIST_LINE="PLIST = osx/Angband.xml"
        NIB_DIR="osx/English.lproj/main.nib"
        NIB_DEST="English.lproj/main.nib"
    fi

    cat >> "$OUTPUT" << MAKEFILE_BUNDLE
# Resource files
${ICON_LINE}
${PLIST_LINE}

${LIBFILES_SECTION}

install: \$(EXE) \$(ICONFILES) \$(PLIST) \$(LIBFILES)
	@echo "Creating application bundle..."
	@mkdir -p \$(APPBNDL)
	@mkdir -p \$(APPCONT)
	@mkdir -p \$(APPBIN)
	@mkdir -p \$(APPRES)
	@mkdir -p \$(APPRES)/${NIB_DEST}
${INSTALL_BUNDLE_LIBDIRS}

	@echo "Copying files..."
${INSTALL_BUNDLE_COPY}

	install -m 755 \$(EXE) \$(APPBIN)
	install -m 644 \$(ICONFILES) \$(APPRES)
	cp ${NIB_DIR}/*ib \$(APPRES)/${NIB_DEST}
	sed -e 's/\\\$\$VERSION\\\$\$/\$(VERSION)/' -e 's/\\\$\$COPYRIGHT\\\$\$/\$(COPYRIGHT)/' \\
		-e 's/\\\$\$NAME\\\$\$/\$(NAME)/' -e 's/\\\$\$EXECUTABLE\\\$\$/\$(EXE)/' \\
		\$(PLIST) > \$(APPCONT)/Info.plist

	# Set bundle bit if SetFile is available
	-\$(SETFILE) -a B \$(APPBNDL) 2>/dev/null || true

MAKEFILE_BUNDLE
fi

cat >> "$OUTPUT" << MAKEFILE_TERMINAL
# Install terminal version target
install-terminal: \$(EXE)
	@echo "Installing terminal version..."
	@cp \$(EXE) ../\$(EXE)-terminal
	@echo "Terminal version installed as ../\$(EXE)-terminal"
	@echo "Run with: ./\$(EXE)-terminal"

# Help target
help:
	@echo "Available targets:"
	@echo "  all             - Build and ${DEFAULT_TARGET} (default)"
	@echo "  \$(EXE)          - Build executable only"
MAKEFILE_TERMINAL

if [[ $HAS_OSX_BUNDLE -eq 1 ]]; then
    cat >> "$OUTPUT" << 'MAKEFILE_HELP_BUNDLE'
	@echo "  install         - Build and create app bundle"
MAKEFILE_HELP_BUNDLE
fi

cat >> "$OUTPUT" << 'MAKEFILE_FOOTER'
	@echo "  install-terminal- Build and install terminal version"
	@echo "  clean           - Clean build artifacts"
	@echo "  help            - Show this help"
	@echo ""
	@echo "Options:"
	@echo "  UNIVERSAL=1 - Build universal binary (x86_64 + arm64)"
	@echo "  OPT=-O3     - Change optimization level"

.PHONY: all install install-terminal clean help
MAKEFILE_FOOTER

echo "Generated: $OUTPUT"
echo "  Name=$NAME  EXE=$EXE  Version=$VERSION"
echo "  Sources: $(echo "$FILTERED_SRCS" | wc -l | tr -d ' ') files"
echo "  Lib layout: $LIB_LAYOUT"
echo "  App bundle: $( [[ $HAS_OSX_BUNDLE -eq 1 ]] && echo "yes ($BUNDLE_DIR)" || echo "no (terminal-only)" )"
echo "  Default target: $DEFAULT_TARGET"
