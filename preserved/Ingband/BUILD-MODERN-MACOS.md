# Building Ingband on Modern macOS

This document describes how to build Ingband on modern macOS systems (macOS 10.15+, including Apple Silicon Macs).

## Prerequisites

- Xcode Command Line Tools: `xcode-select --install`
- macOS 10.15 or later

## Quick Build

For a terminal-based version (recommended):

```bash
cd src
make -f Makefile.osx-modern clean
make -f Makefile.osx-modern install-terminal
```

This creates `ingband-terminal` in the parent directory.

## Build Options

### Terminal Version (Curses Interface)
```bash
# Build for current architecture (Apple Silicon or Intel)
make -f Makefile.osx-modern install-terminal

# Build universal binary (both architectures)
make -f Makefile.osx-modern install-terminal UNIVERSAL=1
```

### Available Targets
- `ingband` - Build executable only
- `install-terminal` - Build and install terminal version
- `clean` - Clean build artifacts
- `help` - Show available options

### Build Options
- `UNIVERSAL=1` - Create universal binary (x86_64 + arm64)
- `OPT=-O3` - Change optimization level

## Running the Game

After building:
```bash
# From the main Ingband directory:
./ingband-terminal
```

## Changes from Original

The modern macOS build makes these key changes:

1. **Frontend**: Uses curses (terminal) instead of platform-specific GUIs
2. **Compiler**: Uses modern clang with current SDK
3. **Architecture**: Builds for Apple Silicon by default, with universal option
4. **SDKs**: Uses current Xcode SDK path detection

## Troubleshooting

### Common Issues

**"Cannot access the './lib/file/news.txt' file!"**
- Make sure you're running from the Ingband directory (where lib/ is)
- The lib/ directory must be present with all game data

**Compilation Errors**
- Ensure Xcode Command Line Tools are installed
- Check that you're using the modern Makefile: `Makefile.osx-modern`

**Architecture Issues**
- For Intel Macs: The build should work automatically
- For Apple Silicon: The build defaults to arm64
- For universal: Use `UNIVERSAL=1` option
