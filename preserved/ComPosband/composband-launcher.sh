#!/bin/bash

# ComPosband Terminal Launcher Script
# Modern macOS build launcher for ComPosband

# Get the directory containing this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Stay in the ComPosband root directory
cd "$DIR"

# Check if the executable exists
if [ ! -f "./composband" ]; then
    echo "Error: ComPosband executable not found!"
    echo "Please run 'cd src && make -f Makefile.osx-modern install-terminal' first."
    exit 1
fi

# Check for lib directory
if [ ! -d "./lib" ]; then
    echo "Error: Game data directory './lib' not found!"
    echo "ComPosband requires the lib directory to run."
    exit 1
fi

# Launch ComPosband with GCU (terminal) interface
echo "Launching ComPosband in terminal mode..."
echo "Press Ctrl+C to quit"
echo ""

# Force GCU mode and pass any command line arguments
exec ./composband -mgcu "$@"