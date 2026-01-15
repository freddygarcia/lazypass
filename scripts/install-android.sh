#!/bin/bash
# Install LazyPass APK to connected Android device
# Usage: ./scripts/install-android.sh

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APK_PATH="$PROJECT_DIR/src-tauri/gen/android/app/build/outputs/apk/universal/release/lazypass-release.apk"
PACKAGE_NAME="com.freddygarcia.lazypass"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  LazyPass Android Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if APK exists
if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}Error: APK not found at:${NC}"
    echo -e "${RED}$APK_PATH${NC}"
    echo -e "\n${YELLOW}Run './scripts/build-android.sh' first to build the APK.${NC}"
    exit 1
fi

# Check for connected device
echo -e "\n${YELLOW}Checking for connected devices...${NC}"
DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l | tr -d ' ')

if [ "$DEVICES" -eq 0 ]; then
    echo -e "${RED}Error: No Android device connected${NC}"
    echo -e "${YELLOW}Please connect your device and enable USB debugging.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Device(s) found: $DEVICES${NC}"
adb devices | grep "device$"

# Uninstall existing version
echo -e "\n${YELLOW}Removing existing installation...${NC}"
if adb shell pm list packages | grep -q "$PACKAGE_NAME"; then
    adb uninstall "$PACKAGE_NAME" 2>/dev/null || true
    echo -e "${GREEN}✓ Previous version uninstalled${NC}"
else
    echo -e "${BLUE}ℹ No previous installation found${NC}"
fi

# Install APK
echo -e "\n${YELLOW}Installing LazyPass...${NC}"
adb install "$APK_PATH"
echo -e "${GREEN}✓ Installation complete${NC}"

# Launch app
echo -e "\n${YELLOW}Launching LazyPass...${NC}"
adb shell am start -n "$PACKAGE_NAME/.MainActivity"
echo -e "${GREEN}✓ App launched${NC}"

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Done!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
