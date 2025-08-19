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

## Strategy for Other Variants

### Target Variants for Modernization
Based on similarity to Oangband's build system and era:

**High Compatibility (Similar Era & Build System)**
- NPPAngband - Uses autotools like Oangband
- FAangband - Same developer lineage as Oangband  
- Sangband - Similar timeframe and structure
- Zangband - Classic variant with established build patterns

**Medium Compatibility (May Need Adaptation)**
- Older variants using custom build systems
- Variants with unique platform dependencies
- Games requiring specific library versions

### General Modernization Process

1. **Assessment Phase**
   - Analyze existing build system (autotools, custom Makefiles, etc.)
   - Identify deprecated dependencies (Carbon, QuickTime, old SDL versions)
   - Check for hardcoded paths and architecture assumptions

2. **Adaptation Phase**  
   - Create modern Makefile based on Oangband template
   - Switch deprecated GUI frameworks to terminal/SDL2 alternatives
   - Update SDK paths and compiler flags
   - Add universal binary support

3. **Testing Phase**
   - Build on both Intel and Apple Silicon Macs
   - Test basic game functionality
   - Verify save file compatibility

4. **Documentation Phase**
   - Create build instructions
   - Document any variant-specific requirements
   - Add troubleshooting guide

### Reusable Components

#### Template Makefile Structure
```makefile
# Modern SDK detection
SDK_PATH = $(shell xcrun --show-sdk-path)
ARCH_FLAGS = -arch $(shell uname -m)

# Universal binary option
ifeq ($(UNIVERSAL),1)
  ARCH_FLAGS = -arch x86_64 -arch arm64
endif

# Terminal interface flags
CFLAGS = -DUSE_GCU -DUSE_TRANSPARENCY
LIBS = -lncurses
```

#### Standard Frontend Migration
- Replace `main-crb.c` (Carbon) with `main-gcu.c` (curses)
- Remove QuickTime and Carbon framework dependencies
- Add ncurses library linking

#### Common Build Targets
- `install-terminal` - Create terminal executable
- `clean` - Remove build artifacts  
- `help` - Show available options
- Universal binary support via `UNIVERSAL=1`

### Benefits of This Approach

1. **Preservation** - Keeps historical variants accessible
2. **Consistency** - Standardized build process across variants
3. **Modern Compatibility** - Works on current and future macOS versions
4. **Documentation** - Clear instructions for users and developers
5. **Template** - Reusable pattern for additional variants

### Next Steps

When modernizing additional variants:
1. Copy and adapt `Makefile.osx-modern` template
2. Identify variant-specific source files and dependencies
3. Test build process and document any unique requirements
4. Create launcher script and documentation following Oangband pattern

This systematic approach ensures orphaned Angband variants remain playable while maintaining their historical character and gameplay.