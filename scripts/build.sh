#!/bin/bash
# Set BUILD_HASH and BUILD_DATE before building
export BUILD_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
export BUILD_DATE=$(date "+%Y-%m-%d %H:%M:%S")
echo "Building with BUILD_HASH=$BUILD_HASH, BUILD_DATE=$BUILD_DATE"
pnpm tauri build
