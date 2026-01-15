#!/bin/bash
# Sign an unsigned APK with the LazyPass keystore
# Usage: ./scripts/sign-apk.sh [input-apk] [output-apk]

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KEYSTORE="$PROJECT_DIR/src-tauri/release.keystore"
KEYSTORE_PASS="lazypass123"
KEY_ALIAS="lazypass"
ANDROID_SDK="$HOME/Library/Android/sdk"
BUILD_TOOLS="$ANDROID_SDK/build-tools/35.0.0"
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default paths
DEFAULT_INPUT="$PROJECT_DIR/src-tauri/gen/android/app/build/outputs/apk/universal/release/app-universal-release-unsigned.apk"
DEFAULT_OUTPUT="$PROJECT_DIR/src-tauri/gen/android/app/build/outputs/apk/universal/release/lazypass-release.apk"

INPUT_APK="${1:-$DEFAULT_INPUT}"
OUTPUT_APK="${2:-$DEFAULT_OUTPUT}"
TEMP_ALIGNED="/tmp/lazypass-aligned.apk"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  LazyPass APK Signer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if input APK exists
if [ ! -f "$INPUT_APK" ]; then
    echo -e "${RED}Error: Input APK not found:${NC}"
    echo -e "${RED}$INPUT_APK${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Input:${NC}  $INPUT_APK"
echo -e "${YELLOW}Output:${NC} $OUTPUT_APK"

# Create keystore if needed
if [ ! -f "$KEYSTORE" ]; then
    echo -e "\n${YELLOW}Creating signing keystore...${NC}"
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
fi

# Zipalign
echo -e "\n${YELLOW}Zipaligning...${NC}"
"$BUILD_TOOLS/zipalign" -f 4 "$INPUT_APK" "$TEMP_ALIGNED"
echo -e "${GREEN}✓ Zipalign complete${NC}"

# Sign
echo -e "\n${YELLOW}Signing...${NC}"
JAVA_HOME="$JAVA_HOME" "$BUILD_TOOLS/apksigner" sign \
    --ks "$KEYSTORE" \
    --ks-pass "pass:$KEYSTORE_PASS" \
    --key-pass "pass:$KEYSTORE_PASS" \
    --out "$OUTPUT_APK" \
    "$TEMP_ALIGNED"
echo -e "${GREEN}✓ Signing complete${NC}"

# Cleanup
rm -f "$TEMP_ALIGNED"

# Verify signature
echo -e "\n${YELLOW}Verifying signature...${NC}"
JAVA_HOME="$JAVA_HOME" "$BUILD_TOOLS/apksigner" verify "$OUTPUT_APK"
echo -e "${GREEN}✓ Signature verified${NC}"

# Show APK info
APK_SIZE=$(du -h "$OUTPUT_APK" | cut -f1)

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Signing Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  APK Size: ${BLUE}$APK_SIZE${NC}"
echo -e "  Location: ${BLUE}$OUTPUT_APK${NC}"
echo ""
