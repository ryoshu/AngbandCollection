#!/bin/bash
# Oangband Terminal Launcher
# This script launches Oangband in a properly configured terminal environment

# Get the directory where this script is located
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the source directory where the binary is located
cd "$DIR/src"

# Export library path for game data
export ANGBAND_PATH="$DIR/lib"

# Launch Oangband in terminal mode
echo "Starting Oangband 1.1.0u..."
echo "Press Ctrl+C to quit"
echo ""

# Run the game
exec ./oangband "$@"