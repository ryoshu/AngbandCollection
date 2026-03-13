# Modernization of Orphaned Angband Variants

## Intent

This document outlines the strategy for modernizing orphaned Angband variants to build and run on modern operating systems, particularly macOS and Linux. The goal is to preserve these historical roguelike games by making them accessible to contemporary users.

## Completed: Oangband 1.1.0u

✅ **Successfully modernized Oangband** - serves as template for other variants

### Key Modernization Approach Used
1. **Frontend Migration**: Switched from deprecated Carbon GUI to curses terminal interface
2. **Framework Updates**: Removed deprecated QuickTime framework dependencies  
3. **Build System**: Created modern Makefile with current Xcode SDK detection
4. **Architecture Support**: Added Apple Silicon + Intel universal binary support
5. **Documentation**: Comprehensive build instructions and troubleshooting guide

### Files Created for Oangband
- `src/Makefile.osx-modern` - Modern macOS build system
- `BUILD-MODERN-MACOS.md` - Complete build documentation
- `oangband-launcher.sh` - Convenience launcher script
- `.gitignore` - Standard development artifacts exclusion

## Batch Modernization Results

Using `scripts/generate-makefile.sh` and `scripts/batch-modernize.sh`, all 52 preserved variants were processed. Source-level fixes were applied where needed (deprecated API replacements, C99 compliance, linker conflicts).

### Results: 45 of 52 Build Successfully

**Builds (45 variants):**
Angband64, Angband65, Animeband, Chengband, ChocolateAngband, ComPosband, Craftband, D11Angband, DaJAngband, Diabloband, Discband, Entroband, EricAngband, EyAngband, Frazband, Friendband, GilAngband, Goingband, GSNband, Ingband, IsoAngband, Jackalband, Jackband, Kangband, MJBand, Minimal, Multiband, Neoband, NuAngband, Oangband, PernAngband, PsiAngband, PziAngband, Questband, RandomBand, RePosband, RobertAngband, Sil, TOband, TeamAngband, Weird, XAngband, XBand, Xygos, eband

**Fails (4 variants):**
- Conglomoband — requires Lua library (lua.h)
- Kamband — requires Lua library
- TFork — requires toLua library (tolua.h)
- Easyband — incomplete source archive (64 undefined symbols)

**Skipped (3 variants):**
- IronHells — client/server architecture, not applicable
- Utumno — C++ codebase, needs separate approach
- BAngband — Moria-style (curses in main.c, no main-gcu.c), needs custom Makefile

### Common Source Fixes Applied

- `cuserid()` replaced with `getlogin()` (removed from modern POSIX)
- `strnicmp` aliased to `strncasecmp` (Windows-only function)
- `restrict` C99 keyword conflicts resolved by renaming variables
- `static` declaration conflicts resolved (extern vs static in separate files)
- Split string literals across lines joined onto single lines
- `#undef bool` removed from main-gcu.c (conflicts with ncurses.h)
- Missing source files added to Makefiles (variant-specific extras)
- Uppercase .C/.H files renamed to lowercase (GNU Make case sensitivity)

### Build Scripts

- `scripts/generate-makefile.sh` — generates `Makefile.osx-modern` for a single variant
- `scripts/batch-modernize.sh` — runs generator across all preserved variants
- `scripts/verify-builds.sh` — builds all variants and produces summary report

### Future Work

- Conglomoband/Kamband/TFork could build if Lua is installed (e.g., `brew install lua`)
- BAngband needs a hand-written Makefile (different architecture from standard Angband)
- Easyband may need source files recovered from other archives