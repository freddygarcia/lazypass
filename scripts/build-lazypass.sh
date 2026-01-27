#!/bin/bash
# Build, sign, and install LazyPass Android APK
# Usage: ./scripts/build-android.sh [--install]

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KEYSTORE="$PROJECT_DIR/src-tauri/release.keystore"
KEYSTORE_PASS="lazypass123"
KEY_ALIAS="lazypass"
ANDROID_SDK="$HOME/Library/Android/sdk"
BUILD_TOOLS="$ANDROID_SDK/build-tools/35.0.0"
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
APK_DIR="$PROJECT_DIR/src-tauri/gen/android/app/build/outputs/apk/universal/release"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  LazyPass Android Build Script${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

cd "$PROJECT_DIR"

# Step 1: Build the release APK
echo -e "\n${YELLOW}[1/4]${NC} Building release APK..."

export BUILD_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
export BUILD_DATE=$(date "+%Y-%m-%d %H:%M:%S")

pnpm tauri android build --target aarch64

if [ ! -f "$APK_DIR/app-universal-release-unsigned.apk" ]; then
    echo -e "${RED}Error: Build failed - APK not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Build complete${NC}"

# Step 2: Create keystore if it doesn't exist
if [ ! -f "$KEYSTORE" ]; then
    echo -e "\n${YELLOW}[2/4]${NC} Creating signing keystore..."
    "$JAVA_HOME/bin/keytool" -genkey -v \
        -keystore "$KEYSTORE" \
        -alias "$KEY_ALIAS" \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -storepass "$KEYSTORE_PASS" \
        -keypass "$KEYSTORE_PASS" \
        -dname "CN=LazyPass, OU=Dev, O=FG, L=City, S=State, C=US"
    echo -e "${GREEN}✓ Keystore created${NC}"
else
    echo -e "\n${YELLOW}[2/4]${NC} Using existing keystore"
    echo -e "${GREEN}✓ Keystore found${NC}"
fi

# Step 3: Zipalign
echo -e "\n${YELLOW}[3/4]${NC} Zipaligning APK..."
"$BUILD_TOOLS/zipalign" -f 4 \
    "$APK_DIR/app-universal-release-unsigned.apk" \
    "$APK_DIR/lazypass-aligned.apk"
echo -e "${GREEN}✓ Zipalign complete${NC}"

# Step 4: Sign the APK
echo -e "\n${YELLOW}[4/4]${NC} Signing APK..."
JAVA_HOME="$JAVA_HOME" "$BUILD_TOOLS/apksigner" sign \
    --ks "$KEYSTORE" \
    --ks-pass "pass:$KEYSTORE_PASS" \
    --key-pass "pass:$KEYSTORE_PASS" \
    --out "$APK_DIR/lazypass-release.apk" \
    "$APK_DIR/lazypass-aligned.apk"
echo -e "${GREEN}✓ Signing complete${NC}"

# Cleanup temp files
rm -f "$APK_DIR/lazypass-aligned.apk"

# Get APK size
APK_SIZE=$(du -h "$APK_DIR/lazypass-release.apk" | cut -f1)

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Build Successful!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  APK Size: ${BLUE}$APK_SIZE${NC}"
echo -e "  Location: ${BLUE}$APK_DIR/lazypass-release.apk${NC}"

# Install if --install flag is passed
if [ "$1" == "--install" ]; then
    echo -e "\n${YELLOW}Installing APK...${NC}"

    # Check if device is connected
    if ! adb devices | grep -q "device$"; then
        echo -e "${RED}Error: No Android device connected${NC}"
        exit 1
    fi

    # Uninstall existing version (ignore errors)
    adb uninstall com.freddygarcia.lazypass 2>/dev/null || true

    # Install new version
    adb install "$APK_DIR/lazypass-release.apk"
    echo -e "${GREEN}✓ Installation complete${NC}"

    # Launch the app
    echo -e "\n${YELLOW}Launching LazyPass...${NC}"
    adb shell am start -n com.freddygarcia.lazypass/.MainActivity
    echo -e "${GREEN}✓ App launched${NC}"
fi

echo ""
