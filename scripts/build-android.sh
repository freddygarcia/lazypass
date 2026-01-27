#!/bin/bash
# Build LazyPass Android App
# Usage: ./scripts/build-android.sh [debug|release]

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAZYPASS_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  LazyPass Android Build Script${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

MODE=${1:-release}

echo -e "Build Mode: ${YELLOW}$MODE${NC}"

cd "$LAZYPASS_DIR"

# Execute Build using Tauri CLI
if [ "$MODE" == "debug" ]; then
    echo -e "\n${YELLOW}Building Debug APK...${NC}"
    pnpm tauri android build --debug
else
    echo -e "\n${YELLOW}Building Release APK...${NC}"
    pnpm tauri android build
fi

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Build finished successfully.${NC}"

    # Try to find the output APK
    if [ "$MODE" == "debug" ]; then
        APK_PATH=$(find src-tauri/gen/android -name "*universal-debug*.apk" 2>/dev/null | head -n 1)
    else
        APK_PATH=$(find src-tauri/gen/android -name "*universal-release*.apk" 2>/dev/null | head -n 1)
    fi

    if [ ! -z "$APK_PATH" ]; then
        echo -e "APK Location: ${BLUE}$APK_PATH${NC}"
        APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
        echo -e "APK Size: ${BLUE}$APK_SIZE${NC}"
    fi
else
    echo -e "\n${RED}✗ Build failed.${NC}"
    exit 1
fi
