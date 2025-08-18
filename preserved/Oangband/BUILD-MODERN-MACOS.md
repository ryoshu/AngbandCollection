# Building Oangband on Modern macOS

This document describes how to build Oangband 1.1.0u on modern macOS systems (macOS 10.15+, including Apple Silicon Macs).

## Prerequisites

- Xcode Command Line Tools: `xcode-select --install`
- macOS 10.15 or later (tested on macOS 14.7)

## Quick Build

For a terminal-based version (recommended):

```bash
cd src
make -f Makefile.osx-modern clean
make -f Makefile.osx-modern install-terminal
```

This creates `oangband-terminal` in the parent directory.

## Build Options

### Terminal Version (Curses Interface)
```bash
# Build for current architecture (Apple Silicon or Intel)
make -f Makefile.osx-modern install-terminal

# Build universal binary (both architectures)
make -f Makefile.osx-modern install-terminal UNIVERSAL=1
```

### Available Targets
- `oangband` - Build executable only
- `install-terminal` - Build and install terminal version
- `clean` - Clean build artifacts
- `help` - Show available options

### Build Options
- `UNIVERSAL=1` - Create universal binary (x86_64 + arm64)
- `OPT=-O3` - Change optimization level

## Running the Game

After building, you can run:
```bash
# From the main Oangband directory:
./oangband-terminal

# Or use the launcher script:
./oangband-launcher.sh
```

## Changes from Original

The modern macOS build makes these key changes:

1. **Frontend**: Uses curses (terminal) instead of Carbon (deprecated)
2. **Frameworks**: Removed QuickTime framework (no longer available)
3. **SDKs**: Uses current Xcode SDK path detection
4. **Architecture**: Builds for Apple Silicon by default, with universal option

## Build Process Details

The build process:

1. **Configure**: Uses autotools configuration for dependencies
2. **Compile**: Uses modern clang with current SDK
3. **Link**: Links against ncurses for terminal interface
4. **Install**: Creates standalone executable

## Troubleshooting

### Common Issues

**"Cannot access the './lib/file/news.txt' file!"**
- This happens if the game can't find its data files
- Make sure you're running from the Oangband directory
- The lib/ directory must be present with all game data

**Compilation Errors**
- Ensure Xcode Command Line Tools are installed
- Check that you're using the modern Makefile: `Makefile.osx-modern`

**Architecture Issues**
- For Intel Macs: The build should work automatically
- For Apple Silicon: The build defaults to arm64
- For universal: Use `UNIVERSAL=1` option

## Technical Notes

### Dependencies
- **ncurses**: For terminal interface
- **Standard C libraries**: All available on macOS

### Build System
- **Primary**: Custom Makefile (`Makefile.osx-modern`)
- **Fallback**: Original autotools (configure + make)

### File Structure
```
Oangband/
├── src/                    # Source code and Makefiles
├── lib/                    # Game data files
├── oangband-terminal*      # Built executable
└── oangband-launcher.sh*   # Convenience launcher
```

The game is fully functional and runs in terminal mode with full color support and keyboard controls.