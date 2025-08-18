# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a public archive and registry of Angband variants and related roguelike games. The repository serves as both a discovery hub and preservation archive for the Angband ecosystem.

## Architecture Strategy

The repository follows a hybrid approach:

1. **Authoritative repos** - Listed in README.md with links to their official GitHub/GitLab locations
2. **Orphaned/dead variants** - Kept as local copies for historical preservation when no authoritative repo exists
3. **Metadata-driven** - README.md serves as the primary registry with status indicators

## Repository Structure

- Each top-level directory represents one Angband variant
- Variants with authoritative repos should eventually be removed and exist only as links in README.md
- Variants without authoritative homes remain as local preservation copies
- README.md contains the canonical list with links where available

## Common Development Tasks

### Adding a new variant
1. Check if an authoritative repo exists
2. If yes: Add to README.md with link, do not add local copy
3. If no: Add local copy to preserve the variant

### Converting local copy to link
1. Verify authoritative repo exists and is maintained
2. Add link to README.md
3. Remove local directory
4. Update git to reflect removal

### Validating links
Use scripts to periodically check that linked repositories are still accessible and maintained.

## Repository Management

- Keep local copies minimal - only for preservation of orphaned variants
- Prioritize linking to authoritative sources over local storage
- Maintain README.md as the primary discovery mechanism
- Avoid duplicating actively maintained codebases locally