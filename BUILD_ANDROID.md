# Building Lazypass for Android

## Prerequisites
- **Android Studio** (or Command Line Tools)
- **Android SDK** (Platforms 33+, Build Tools, Platform Tools)
- **NDK** (Side-by-side)
- **Rust target**: `aarch64-linux-android`, `armv7-linux-androideabi`, `i686-linux-android`, `x86_64-linux-android`

## Setup
If you haven't already initialized the Android project structure (or if the automated init failed):

```bash
npm run tauri android init
```
Follow the prompts to install the Android SDK if needed.

## Running in Emulator / Device
To run the app on a connected device or emulator with live reload:

```bash
npm run tauri android dev
```

## Building APK/AAB
To build a signed (or unsigned debug) APK:

```bash
npm run tauri android build
```
The output will be in `src-tauri/gen/android/app/build/outputs/apk/`.

## Troubleshooting
- **SDK not found**: Ensure `ANDROID_HOME` or `ANDROID_SDK_ROOT` environment variables are set.
- **Gradle errors**: Open `src-tauri/gen/android` in Android Studio to easier debug build issues.
