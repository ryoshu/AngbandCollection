# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a public archive and registry of Angband variants and related roguelike games. The repository serves as both a discovery hub and preservation archive for the Angband ecosystem.

## Architecture Strategy

Pure registry + selective preservation approach:

1. **Primary registry** - README.md serves as the canonical discovery hub with links to authoritative repos
2. **Selective preservation** - Only truly orphaned variants are stored locally in `/preserved/`
3. **Utility scripts** - Tools in `/scripts/` for link validation and orphan management
4. **Fast discovery** - Users can quickly browse all variants without downloading gigabytes

## Repository Structure

```
/scripts/
  validate-links.sh     # Check all GitHub links are alive  
  fetch-orphans.sh     # Download variants without homes
/preserved/            # Only truly orphaned variants
  Angband64/
  GSNband/
  [other orphaned variants]
/README.md            # Primary registry with links + metadata
```

- README.md contains ALL variants with authoritative repo links where available
- `/preserved/` contains only variants with no active authoritative repository
- `/scripts/` contains maintenance utilities
- No local copies of variants that have active upstream repositories

## Common Development Tasks

### Adding a new variant
1. Check if an authoritative repo exists
2. If yes: Add to README.md with link only
3. If no: Add to `/preserved/` directory and list in README.md

### Moving variant from local to linked
1. Verify authoritative repo exists and is actively maintained
2. Update README.md with link
3. Remove from `/preserved/` directory 
4. Commit the removal

### Preserving an orphaned variant
1. Use `scripts/fetch-orphans.sh` to download from source
2. Place in `/preserved/` directory
3. Add to README.md without link

### Validating repository health
- Run `scripts/validate-links.sh` to check all external links
- Review variants in `/preserved/` for potential new upstream homes

## Repository Management Principles

- README.md is the single source of truth for discovery
- Only preserve locally what cannot be found elsewhere
- Prefer links to live repositories over static copies
- Keep the repository lightweight for fast cloning
- Maintain scripts for automated validation and maintenance