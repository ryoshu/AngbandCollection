# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a preservation archive of orphaned Angband variants and related roguelike games, with an active focus on modernizing them to compile and run on contemporary macOS (Apple Silicon and Intel).

## Architecture Strategy

Preservation + modernization approach:

1. **Preservation archive** - Orphaned variants with no upstream repository are stored in `/preserved/`
2. **Active modernization** - 45 of 52 preserved variants ported to modern macOS using ncurses terminal interface
3. **Utility scripts** - Tools in `/scripts/` for build automation, link validation, and orphan fetching
4. **External references** - README.md lists actively maintained variants with links for reference

## Repository Structure

```
/scripts/
  generate-makefile.sh   # Generate Makefile.osx-modern for a variant
  batch-modernize.sh     # Batch-modernize multiple variants
  verify-builds.sh       # Build all variants and generate report
  validate-links.sh      # Check all README URLs are reachable
  fetch-orphans.sh       # Download orphaned variants for preservation
/preserved/              # Orphaned variants (52 total, 45 buildable)
  <Variant>/
    src/                  # Source code
    src/Makefile.osx-modern  # Modern macOS Makefile
    src/build-osx-modern.log # Build log
    BUILD-MODERN-MACOS.md    # Per-variant build instructions
/README.md               # Archive index with build status table
/build-report.txt         # Latest build verification report
```

- `/preserved/` contains orphaned variants with no active upstream repository
- Each buildable variant has a `Makefile.osx-modern`, `BUILD-MODERN-MACOS.md`, and build log
- `/scripts/` contains build automation and maintenance utilities
- README.md lists both preserved variants (with build status) and external active variants

## Common Development Tasks

### Building a preserved variant
```bash
cd preserved/<VariantName>/src
make -f Makefile.osx-modern clean
make -f Makefile.osx-modern install-terminal
cd ..
./<variantname>-terminal
```

### Preserving a new orphaned variant
1. Use `scripts/fetch-orphans.sh <url> <name>` to download and extract
2. Run `scripts/generate-makefile.sh` to create a modern Makefile
3. Fix any compilation errors in source files
4. Run `scripts/verify-builds.sh --only <name>` to confirm it builds
5. Add to the build status table in README.md

### Modernizing a variant for macOS
1. **Assessment Phase** - Analyze existing build system and identify deprecated dependencies
2. **Adaptation Phase** - Create modern Makefile, switch to ncurses terminal interface, update SDK paths
3. **Testing Phase** - Build on Apple Silicon, verify game launches
4. **Documentation Phase** - Create BUILD-MODERN-MACOS.md with instructions

### Validating repository health
- Run `scripts/validate-links.sh` to check all external URLs in README.md
- Run `scripts/verify-builds.sh` to rebuild all variants and generate build-report.txt

## Repository Management Principles

- Only preserve locally what cannot be found elsewhere
- Modernize orphaned variants using systematic approach (Oangband serves as template)
- Use standardized modernization components: modern Makefiles, ncurses terminal interface
- Keep build status table in README.md up to date
- Compiled binaries and object files are gitignored — only source and build scripts are committed
