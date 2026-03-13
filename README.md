# Angband Variants Collection

A preservation archive of orphaned Angband variants, modernized to compile on contemporary macOS.

## About This Collection

This repository preserves orphaned Angband variants that have no active upstream repository, and ports them to run on modern systems:

- **52 historical variants** preserved in `/preserved/`, sourced from defunct archives and old releases
- **45 of 52 compile on modern macOS** (Apple Silicon and Intel) via ncurses terminal interface
- **Per-variant build docs** and Makefiles included for each buildable variant
- Links to actively maintained variants are listed below for reference

## Repository Structure

- `/preserved/` - Preserved orphaned variants with modern build support (52 variants)
- `/scripts/` - Build automation and maintenance utilities

---

## Active Variants (External)

These variants have active development elsewhere and are **not** included in this archive:

* AlexAngband - https://github.com/NickMcConnell/AlexAngband
* Angband - https://github.com/angband/angband
* Anquestria - https://github.com/NickMcConnell/Anquestria
* BEAngband - https://github.com/NickMcConnell/BEAngband
* Borgband - https://github.com/NickMcConnell/borgband
* CatHAngband - https://github.com/NickMcConnell/CatHAngband
* CthAngband - https://github.com/Gurbintroll/Cthangband
* DrAngband - https://github.com/NickMcConnell/DrAngband
* DungeonCity - https://github.com/NickMcConnell/DungeonCity
* DvEband - https://github.com/d-band
* FAangband - https://github.com/NickMcConnell/FAangband
* FAangbandCE - https://github.com/NickMcConnell/FAangband (Same as FAangband)
* FAngband - https://github.com/NickMcConnell/FAangband (Same as FAangband)
* FayAngband - https://github.com/NickMcConnell/FAangband (Same as FAangband)
* FrogComposband - https://github.com/sulkasormi/frogcomposband
* FuryBand - https://github.com/Geozop/Furyband
* GWAngband - https://github.com/NickMcConnell/GWAngband
* Gumband - https://github.com/gumband
* HallsOfMist - https://github.com/NickMcConnell/HallsOfMist
* Hellband - https://github.com/konijn/hellband
* Hengband - https://github.com/hengband/hengband
* Hengband-development - https://github.com/hengband/hengband (Same as Hengband)
* Hengband-stable - https://github.com/hengband/hengband (Same as Hengband)
* Ironband - https://github.com/NickMcConnell/Ironband
* IsoFunband - https://github.com/IsoFunband/IsoFunband
* IsoUnangband - https://github.com/DGoldDragon28/Unangband (Related to Unangband)
* JLEpatchedAngband - https://github.com/NickMcConnell/JLEpatchedAngband
* Langband - https://github.com/NickMcConnell/Langband
* Mangband - https://github.com/mangband/mangband
* NPPAngband - https://github.com/nppangband/NPPAngband
* NTAngband - https://github.com/NTAngband/NTAngband
* NewAngband - https://github.com/NickMcConnell/NewAngband
* NewArtAngband - https://github.com/NickMcConnell/NewArtAngband
* OmnibandTk - https://github.com/OmnibandTk/OmnibandTk
* Oposband - https://github.com/sulkasormi/oposband
* PAngband - https://github.com/NickMcConnell/PAngband
* PCAngband - https://github.com/NickMcConnell/PCAngband
* PWMAngband - https://github.com/draconisPW/PWMAngband
* PernMangband - https://github.com/mangband/mangband (Variant of Mangband)
* Ponyband - https://github.com/NickMcConnell/Ponyband
* Portralis - https://github.com/NickMcConnell/Portralis
* PosChengband - https://github.com/NickMcConnell/poschengband
* Posband - https://github.com/NickMcConnell/poschengband (Likely shortened name for PosChengband)
* PrfnoffAngband - https://github.com/prfnoff/Angband
* PrfnoffZangband - https://github.com/Pryanoff/PryanoffZangband
* QAngband - https://github.com/NickMcConnell/QAngband
* QuAngband - https://github.com/NickMcConnell/QuAngband
* Quickband - https://github.com/nppangband/NPPAngband_QT (Related to NPPAngband)
* Rangband - https://github.com/NickMcConnell/Rangband
* SBFband - https://github.com/SBFband
* STAngband - https://github.com/jeffrey-rosen/STAngband
* Sangband - https://github.com/NickMcConnell/Sangband
* Sil-Q - https://github.com/sil-quirk/sil-q
* SillyBand - https://github.com/NickMcConnell/SillyBand
* Steamband - https://github.com/myshkin/steamband
* TinyAngband - https://github.com/iksh/TinyAngband
* ToME - https://git.net-core.org/tome/t-engine4.git (Official repository on GitLab)
* ToME-SX - https://github.com/AmyBSOD/ToME-SX
* ToME-ah - https://git.net-core.org/tome/t-engine4.git (Official repository on GitLab, variant of ToME)
* TouhouAngband - https://github.com/Cryomaniac13/hengband-touhou-katteban-en
* UnAngband - https://github.com/DGoldDragon28/Unangband
* Yin-YAngband - Likely part of https://github.com/NickMcConnell/AngbandPlus
* Z+Angband - Hosted on SourceForge: https://sourceforge.net/projects/zangband/
* Zaiband - https://github.com/zaiband/zaiband
* Zangband - https://github.com/jjnoo/Zangband
* Zceband - https://github.com/NickMcConnell/Zceband
* sCthangband - https://github.com/Gurbintroll/Cthangband (Variant of Cthangband)

---

## Preserved Variants (Historical Archive)

These variants have no known active development and are preserved locally in `/preserved/`. **45 of 52** now compile on modern macOS (Apple Silicon and Intel) using ncurses terminal interface.

| Variant | macOS Build | Warnings | Known Issues |
|---------|:-----------:|:--------:|--------------|
| Angband64 | Builds | 650 | High warning count from legacy K&R-style code |
| Angband65 | Builds | 30 | |
| Animeband | Builds | 237 | |
| BAngband | Skipped | — | Moria-derived codebase, needs custom build system |
| Chengband | Builds | 454 | High warning count from complex variant features |
| ChocolateAngband | Builds | 61 | Required `externs.h` and `init2.c` fixes |
| ComPosband | Builds | 195 | |
| Conglomoband | Fails | — | Requires Lua (`lua.h` not found); source fixes applied but Lua dependency unresolved |
| Craftband | Builds | 22 | Required `main-gcu.c` fix |
| D11Angband | Builds | 146 | |
| DaJAngband | Builds | 271 | Required `Makefile.src` and `main-gcu.c` fixes |
| Diabloband | Builds | 60 | |
| Discband | Builds | 313 | |
| Easyband | Fails | — | Linker error: missing `run_step` symbol; incomplete source archive |
| Entroband | Builds | 146 | |
| EricAngband | Builds | 244 | Required `externs.h`, `load1.c`, `load2.c` fixes |
| EyAngband | Builds | 65 | |
| Frazband | Builds | 380 | High warning count |
| Friendband | Builds | 13 | |
| GSNband | Builds | 316 | Required `FILES.C` and `SPELLS1.C` fixes |
| GilAngband | Builds | 4 | Required `cmd5.c` fix |
| Goingband | Builds | 180 | |
| Ingband | Builds | 58 | |
| IronHells | Skipped | — | Client/server architecture, not a standalone build |
| IsoAngband | Builds | 132 | |
| Iso-PernAngband | Skipped | — | No source files in archive |
| Jackalband | Builds | 7 | |
| Jackband | Builds | 36 | |
| Kamband | Fails | — | Requires Lua (`lua_strlibopen` linker error) |
| Kangband | Builds | 188 | Required `wizard2.c` fix |
| MJBand | Builds | 184 | |
| Minimal | Builds | 22 | |
| Multiband | Builds | 230 | |
| Neoband | Builds | 28 | |
| NuAngband | Builds | 256 | Required `defines.h` fix |
| Oangband | Builds | 179 | Template variant for modernization process |
| PernAngband | Builds | 508 | High warning count; required fixes to `birth.c`, `cmd3.c`, `generate.c`, `monster2.c`, `store.c`, `variable.c`, `xtra2.c` |
| PsiAngband | Builds | 260 | |
| PziAngband | Builds | 272 | |
| Questband | Builds | 146 | |
| RandomBand | Builds | 453 | High warning count |
| RePosband | Builds | 49 | |
| RobertAngband | Builds | 225 | |
| Sil | Builds | 87 | |
| TFork | Fails | — | Requires Lua/tolua (`tolua.h` not found) |
| TOband | Builds | 792 | Highest warning count; required `autopick.c` fix |
| TeamAngband | Builds | 189 | |
| Utumno | Skipped | — | C++ codebase, needs separate modernization approach |
| Weird | Builds | 169 | |
| XAngband | Builds | 376 | |
| XBand | Builds | 157 | Required `externs.h`, `h-define.h`, `wild2.c` fixes |
| Xygos | Builds | 14 | |
| eband | Builds | 31 | Required `main-gcu.c` and `z-file.c` fixes |

**Summary:** 45 build, 4 fail, 3 skipped

---

## Modern macOS Build Support

Each buildable variant includes a `Makefile.osx-modern` and `BUILD-MODERN-MACOS.md` with instructions.

### Quick Build (any supported variant)

```bash
cd preserved/<VariantName>/src
make -f Makefile.osx-modern clean
make -f Makefile.osx-modern install-terminal
cd ..
./<variantname>-terminal
```

### Key Modernization Details

- Frontend: Carbon/QuickTime GUI replaced with ncurses terminal interface
- Compiler: Clang with current Xcode SDK, `-std=gnu99`
- Architecture: Native build for current arch, `UNIVERSAL=1` for fat binaries
- Build scripts in `/scripts/`: `generate-makefile.sh`, `batch-modernize.sh`, `verify-builds.sh`

---

## Usage

```bash
# Clone the archive
git clone https://github.com/ryoshu/AngbandCollection.git
cd AngbandCollectionRepo/preserved/

# Build and play any supported variant
cd Oangband/src
make -f Makefile.osx-modern clean
make -f Makefile.osx-modern install-terminal
cd ..
./oangband-terminal
```

---

## Statistics

- **Preserved historical variants:** 52
- **Buildable on modern macOS:** 45
- **Active variants listed (external):** 67

## Contributing

Found an orphaned Angband variant that should be preserved, or have a fix for one of the failing builds? Please submit a pull request or open an issue!