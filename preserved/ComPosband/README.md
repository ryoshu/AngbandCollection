# ComPosband - Modern macOS Build

![Build Status](https://img.shields.io/badge/macOS-✅%20Operational-brightgreen)
![Architecture](https://img.shields.io/badge/Architecture-Intel%20%7C%20Apple%20Silicon-blue)
![Interface](https://img.shields.io/badge/Interface-Terminal-yellow)
![Status](https://img.shields.io/badge/Status-Ready%20to%20Play-success)

**ComPosband** is a comprehensive Angband variant featuring an extensive class system, multiple races, and deep gameplay mechanics. This modernized version has been updated to build and run on contemporary macOS systems.

## Quick Start

```bash
# Build the game (if not already built)
cd src/
make -f Makefile.osx-modern install-terminal
cd ..

# Launch and play
./composband-launcher.sh
```

**🎮 Ready to Play!** ComPosband is fully operational and ready for dungeon exploration.

## About ComPosband

ComPosband (Composition + PosChengband) is one of the most feature-rich Angband variants, offering:

- **40+ Character Classes**: From traditional warriors to unique classes like Ninja-Lawyers
- **Multiple Races**: Including monster races with unique gameplay
- **Extensive Magic System**: Multiple realms and spell schools
- **Rich Dungeon System**: Varied dungeons with unique challenges
- **Advanced Character Customization**: Comprehensive birth options and progression paths

## Modernization Features

This build has been modernized for contemporary macOS:

### ✅ **Universal Compatibility**
- Native Apple Silicon (M1/M2/M3) support
- Intel Mac compatibility
- Universal binary option available

### ✅ **Modern Build System**
- Current Xcode SDK integration
- Automated dependency detection
- Clean, maintainable Makefile

### ✅ **Terminal Interface**
- Ncurses-based gameplay
- Full keyboard control
- Optimized for modern terminals

### ✅ **Fixed Source Code**
- Resolved missing function declarations
- Updated path configurations
- Modern compiler compatibility
- **Fixed arrow key controls** - Arrow keys now walk instead of run by default

## File Structure

```
ComPosband/
├── 📁 src/                     # Source code and build system
│   ├── 🔧 Makefile.osx-modern  # Modern macOS build configuration
│   ├── 🎮 composband           # Compiled executable
│   └── 📄 [source files]      # Game source code
├── 📁 lib/                     # Game data files
│   ├── 📁 edit/                # Game configuration
│   ├── 📁 file/                # Text files and help
│   ├── 📁 help/                # In-game documentation
│   └── 📁 pref/                # User preferences
├── 🚀 composband-launcher.sh   # Convenient game launcher
├── 📖 BUILD-MODERN-MACOS.md    # Detailed build instructions
└── 📋 README.md                # This file
```

## Build Options

### Standard Build
```bash
make -f Makefile.osx-modern composband
```

### Universal Binary (Intel + Apple Silicon)
```bash
make -f Makefile.osx-modern UNIVERSAL=1 composband
```

### Optimized Build
```bash
make -f Makefile.osx-modern OPT=-O3 composband
```

## Documentation

- **[BUILD-MODERN-MACOS.md](BUILD-MODERN-MACOS.md)** - Complete build instructions and troubleshooting
- **In-game Help** - Press `?` in-game for comprehensive help system
- **Original Documentation** - See `lib/file/` directory for original ComPosband docs

## Requirements

- **macOS 10.15+** (Catalina or later)
- **Xcode Command Line Tools** (`xcode-select --install`)
- **Terminal** (for gameplay)

## Gameplay

ComPosband features the classic Angband formula with extensive enhancements:

1. **Character Creation**: Choose from dozens of races and classes
2. **Dungeon Exploration**: Descend through procedurally generated levels
3. **Combat System**: Tactical turn-based combat with multiple attack options
4. **Magic System**: Multiple spell realms with hundreds of spells
5. **Equipment**: Extensive artifact and equipment system
6. **Quests**: Random and fixed quests throughout the game

### Controls

- **Movement**: Arrow keys or numpad (walks by default)
- **Running**: Shift+arrow keys or `.` followed by direction
- **Commands**: Single letter commands (press `?` for help)
- **Inventory**: `i` to view inventory, `w` to wield, `d` to drop
- **Spells**: `m` to cast spells (if your class can cast)
- **Save/Quit**: `Ctrl+X` to save and quit

## Technical Details

### Modernization Changes

1. **Header Fixes**: Added missing function declarations for `recharge_pack()`, `chaos_patron_reward()`, and `kayttonimi()`
2. **Build System**: Updated for modern Xcode tools and SDK paths
3. **Architecture Support**: Added Apple Silicon compatibility
4. **Path Configuration**: Fixed executable paths for root directory execution
5. **Naming Standardization**: Clean executable naming without confusing suffixes
6. **Key Mapping Fix**: Corrected arrow key preference mappings in `pref-gcu.prf`, `pref-mac.prf`, and `pref-sdl.prf` to walk by default instead of run
7. **Wizard Mode**: Enabled wizard and debug modes with `-DALLOW_WIZARD` compilation flag for testing and development

### Performance

- **Native Performance**: Optimized compilation for your CPU architecture
- **Terminal Efficiency**: Lightweight ncurses interface for excellent responsiveness
- **Memory Usage**: Efficient memory management typical of Angband variants

## Integration with Angband Collection

This modernized ComPosband serves as:

- **Preservation**: Maintains access to this historically significant variant
- **Template**: Demonstrates modernization techniques for other variants
- **Reference**: Shows successful integration of complex Angband codebases

## Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Build fails with "command not found" | Install Xcode Command Line Tools |
| Missing ncurses library | Install via Homebrew: `brew install ncurses` |
| "Fatal Error" or missing lib files | Run from ComPosband root directory, not `src/` |
| Game crashes on startup | Verify `lib/` directory exists and is complete |
| Display issues | Try different terminal apps or adjust terminal settings |
| Arrow keys make character run instead of walk | **Fixed!** - Arrow keys now walk by default as expected |

For detailed troubleshooting, see [BUILD-MODERN-MACOS.md](BUILD-MODERN-MACOS.md).

## Credits

- **ComPosband Development Team**: Original game development
- **Angband Community**: Foundational game engine and community support
- **Modernization**: Part of the Angband Collection preservation project

## License

ComPosband maintains its original licensing terms. See source code files for specific copyright information.

---

**Ready to explore the depths? Launch ComPosband and begin your adventure!**

```bash
./composband-launcher.sh
```