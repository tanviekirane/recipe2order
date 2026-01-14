# Recipe2Order

Plan your week's recipes and generate a consolidated shopping list for easy grocery ordering!

## Features (Planned)

- Input recipes via text or URL
- AI-powered ingredient extraction using on-device ML
- Aggregate ingredients across multiple recipes
- Generate shareable shopping lists
- Future: Video recipe parsing, grocery API integrations

## Prerequisites

Before running this app, ensure you have the following installed:

### 1. Flutter SDK
- **Version:** 3.38.x or later
- **Installation:** https://docs.flutter.dev/get-started/install

Verify installation:
```bash
flutter --version
```

### 2. For Android Development
- **Android Studio** with Android SDK
- **Android Emulator** or physical device with USB debugging enabled
- Run `flutter doctor` to verify Android toolchain

### 3. For iOS Development (macOS only)
- **Xcode** (latest version from App Store)
- **CocoaPods:** `sudo gem install cocoapods`
- Run `flutter doctor` to verify Xcode installation

## Getting Started

### 1. Clone the repository
```bash
git clone <repository-url>
cd recipe2order
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run the app

#### Option A: Using VS Code (Recommended)
1. Open the project in VS Code
2. Install the "Flutter" extension if not already installed
3. Select a device from the bottom status bar
4. Press `F5` or go to Run > Start Debugging

#### Option B: Using Command Line

**Check available devices:**
```bash
flutter devices
```

**Run on Android Emulator:**
```bash
# Start an emulator first (if not running)
flutter emulators --launch <emulator_id>

# Run the app
flutter run
```

**Run on iOS Simulator (macOS only):**
```bash
# Open iOS Simulator
open -a Simulator

# Run the app
flutter run
```

**Run on Connected Physical Device:**
```bash
flutter run -d <device_id>
```

**Run on Chrome (Web - for quick testing):**
```bash
flutter run -d chrome
```

### 4. Hot Reload & Hot Restart
- **Hot Reload:** Press `r` in terminal (or save file in IDE) - preserves state
- **Hot Restart:** Press `R` in terminal - resets state

## Development Commands

```bash
# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Build APK (Android)
flutter build apk

# Build iOS (macOS only)
flutter build ios

# Clean build artifacts
flutter clean
```

## Project Structure

```
recipe2order/
├── lib/
│   └── main.dart          # App entry point
├── test/
│   └── widget_test.dart   # Widget tests
├── android/               # Android platform files
├── ios/                   # iOS platform files
├── pubspec.yaml           # Dependencies & metadata
└── README.md              # This file
```

## Troubleshooting

### Flutter not found
Add Flutter to your PATH:
```bash
# Windows (PowerShell)
$env:Path += ";C:\path\to\flutter\bin"

# macOS/Linux
export PATH="$PATH:/path/to/flutter/bin"
```

### Android SDK not found
1. Open Android Studio > Settings > SDK Manager
2. Install Android SDK and accept licenses:
   ```bash
   flutter doctor --android-licenses
   ```

### iOS build issues (macOS)
```bash
cd ios
pod install
cd ..
flutter clean
flutter run
```

### Check overall setup
```bash
flutter doctor -v
```

## License

MIT License - see LICENSE file for details.
