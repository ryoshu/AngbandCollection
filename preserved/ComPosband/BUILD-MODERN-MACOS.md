# Building ComPosband on Modern macOS

This document provides instructions for building ComPosband on modern macOS systems, including Apple Silicon (M1/M2/M3) and Intel Macs.

## Overview

ComPosband has been successfully modernized to build and run on contemporary macOS versions using current Xcode developer tools. The modernization includes:

- Updated build system for current Xcode SDK
- Universal binary support (Intel + Apple Silicon)
- Terminal-based interface using ncurses
- Fixed missing function declarations
- Modern path configuration

## Prerequisites

- **macOS**: 10.15 (Catalina) or later
- **Xcode Command Line Tools**: Install with `xcode-select --install`
- **Terminal access**: Required for compilation and gameplay

## Quick Start

1. **Navigate to the source directory:**
   ```bash
   cd src/
   ```

2. **Build ComPosband:**
   ```bash
   make -f Makefile.osx-modern install-terminal
   ```

3. **Launch the game:**
   ```bash
   ../composband-launcher.sh
   ```

## Build Options

### Standard Build
Build for current architecture (Intel or Apple Silicon):
```bash
make -f Makefile.osx-modern composband
```

### Universal Binary
Build a universal binary that runs on both Intel and Apple Silicon:
```bash
make -f Makefile.osx-modern UNIVERSAL=1 composband
```

### Optimization Levels
Change optimization settings:
```bash
make -f Makefile.osx-modern OPT=-O3 composband    # High optimization
make -f Makefile.osx-modern OPT=-g composband     # Debug build
```

## Available Targets

- `composband` - Build executable only
- `install-terminal` - Build and create terminal launcher
- `clean` - Remove build artifacts  
- `help` - Show available options

## Technical Details

### Source Code Fixes Applied

During modernization, the following issues were resolved:

1. **Missing `recharge_pack()` declaration** - Added to `externs.h:1497`
2. **Missing `chaos_patron_reward()` declaration** - Added to `externs.h:2666`  
3. **Missing `kayttonimi()` declaration** - Added to `externs.h:2670`
4. **Path configuration fix** - Updated Makefile paths from `../lib` to `./lib` for root directory execution
5. **Arrow key mapping fix** - Corrected preference mappings in `pref-gcu.prf`, `pref-mac.prf`, and `pref-sdl.prf` to walk by default instead of run
6. **Wizard mode enabled** - Added `-DALLOW_WIZARD` compilation flag to enable wizard and debug modes

### Build System Updates

- **Modern SDK Detection**: Automatically detects current Xcode SDK
- **Architecture Support**: Native compilation for Apple Silicon and Intel
- **Path Configuration**: Configured for root directory execution (`./lib` paths)
- **Terminal Interface**: Uses ncurses for cross-platform compatibility
- **Standardized Naming**: Clean executable naming without confusing suffixes

### File Structure

```
ComPosband/
├── composband                  # Game executable (looks for ./lib)
├── composband-launcher.sh      # Terminal launcher script
├── lib/                        # Game data files (required for execution)
├── src/
│   ├── Makefile.osx-modern     # Modern macOS build system
│   ├── composband              # Development copy (looks for ../lib)
│   └── [source files]
├── BUILD-MODERN-MACOS.md       # This documentation
└── README.md                   # Project overview
```

## Troubleshooting

### Common Issues

**Problem**: `xcrun: error: unable to find utility "clang"`
**Solution**: Install Xcode Command Line Tools: `xcode-select --install`

**Problem**: `ld: library not found for -lncurses`
**Solution**: Install ncurses via Homebrew: `brew install ncurses`

**Problem**: Game shows "Fatal Error" or "Cannot access the './lib/file/news.txt' file"
**Solution**: 
- Ensure you're running from the ComPosband root directory (not `src/`)
- Verify `lib/` directory exists and contains game data files
- Use `./composband-launcher.sh` for proper execution

**Problem**: Build fails with "No such file or directory"
**Solution**: Verify you're in the `src/` directory before building

**Problem**: Executable works from `src/` but not from root directory
**Solution**: This indicates path configuration issue - rebuild with `make clean && make install-terminal`

**Problem**: Arrow keys always make character run instead of walk
**Solution**: This was a key mapping bug in the preference files. The fix has been applied to:
- `lib/pref/pref-gcu.prf` - VT100 arrow key sequences now map to walking commands (`;2`, `;4`, `;6`, `;8`) instead of running commands (`.2`, `.4`, `.6`, `.8`)
- `lib/pref/pref-mac.prf` - Mac-specific arrow key mappings updated to use walking commands
- `lib/pref/pref-sdl.prf` - SDL arrow key mappings updated to use walking commands

The arrow keys now correctly walk by default. To run, use Shift+arrow keys or the `.` command followed by a direction.

**Problem**: Need access to wizard mode or debug features for testing/development
**Solution**: Wizard mode is now enabled by default. In-game commands:
- **Ctrl+W** - Toggle wizard mode (allows cheating and debugging)
- **Ctrl+A** - Enter debug mode (additional debug commands)
- **-w** command line flag - Start game in wizard mode directly

Note: Using wizard mode marks the game as unscored.

### Build Artifacts

After building, you'll find:
- `composband` - The game executable
- `*.o` - Object files (can be removed with `make clean`)

### Performance Notes

- The terminal interface provides excellent performance on modern hardware
- Universal binaries are slightly larger but offer maximum compatibility
- Debug builds (`OPT=-g`) are useful for development but slower

## Integration with Collection

This modernized ComPosband serves as a template for modernizing other orphaned Angband variants. The techniques used here can be applied to similar variants:

1. Update Makefile for modern SDK paths
2. Fix missing function declarations  
3. Add required compiler definitions
4. Create convenient launcher scripts
5. Document the modernization process

## Credits

- **Original ComPosband**: ComPosband Development Team
- **Modernization**: Based on Oangband modernization template
- **Build System**: Adapted from modern Angband build practices

For more information about the broader Angband modernization project, see the main repository documentation.