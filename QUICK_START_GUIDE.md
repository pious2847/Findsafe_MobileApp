# Quick Start Guide - FindSafe Flutter App

## 🚀 Get Started in 5 Minutes

### Prerequisites
- ✅ Java 21 installed (already confirmed)
- ✅ Flutter SDK (you mentioned you don't have it installed yet)
- Android Studio or Xcode (for building)

---

## 📦 Step 1: Install Flutter (If Not Installed)

### Windows Installation:
1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\src\flutter`
3. Add to PATH: `C:\src\flutter\bin`
4. Run: `flutter doctor` to verify installation

---

## 🔧 Step 2: Project Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Android API Key
Create `android/local.properties` file:
```properties
GOOGLE_API_KEY=AIzaSyDfR0xgwZw5Dblp0A7O1VPFX9BEXZ0oefY
```

### 3. Verify .env File
Your `.env` file should contain:
```env
GOOGLE_API_KEY=AIzaSyDfR0xgwZw5Dblp0A7O1VPFX9BEXZ0oefY
API_URL=https://findsafe-backend.onrender.com/api
```

### 4. iOS Setup (If building for iOS)
```bash
cd ios
pod install
cd ..
```

---

## 🏗️ Step 3: Build the App

### Android Build (Recommended to start)

#### Debug Build:
```bash
flutter build apk --debug
```

#### Release Build:
```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### iOS Build (Requires Mac)

```bash
flutter build ios --release
```

Or open in Xcode:
```bash
open ios/Runner.xcworkspace
```

---

## 🎯 Step 4: Run on Device/Emulator

### Android:
```bash
# List connected devices
flutter devices

# Run on connected device
flutter run

# Run in release mode
flutter run --release
```

### iOS:
```bash
flutter run
```

---

## 📱 Your Project Details

### Package Name
```
com.example.findsafe
```

### Debug Certificate SHA-1
```
65:7F:91:50:33:BD:CF:25:6E:1A:84:07:1D:00:B3:A8:33:F8:0D:96
```

### API Keys Location
- **Android**: `android/local.properties`
- **Flutter**: `.env` file
- **iOS**: Environment variable or hardcoded fallback

---

## ✅ Verification Checklist

Before building, ensure:

- [ ] `flutter pub get` completed successfully
- [ ] `android/local.properties` exists with API key
- [ ] `.env` file exists in project root
- [ ] For iOS: `pod install` completed in `ios/` directory
- [ ] Java 21 is installed and in PATH
- [ ] Flutter SDK is installed and in PATH

---

## 🔍 Troubleshooting

### "Flutter command not found"
- Install Flutter SDK
- Add Flutter to PATH
- Restart terminal

### "Podfile not found" (iOS)
```bash
cd ios
pod install
cd ..
```

### "API Key not found"
- Create `android/local.properties`
- Add: `GOOGLE_API_KEY=your_key_here`

### Build fails with Gradle errors
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### "No connected devices"
- Enable USB debugging on Android device
- Or start Android emulator from Android Studio
- Or use: `flutter emulators --launch <emulator_id>`

---

## 🎉 Success!

If the build completes successfully, you'll have:
- ✅ A working APK for Android
- ✅ Or an iOS app bundle
- ✅ Ready to install on devices or submit to stores

---

## 📞 Next Steps

1. **Test on Physical Device**: Background location works best on real devices
2. **Configure Google Cloud Console**: Add your SHA-1 fingerprint
3. **Test All Features**: Location tracking, notifications, device admin
4. **Create Release Keystore**: For Play Store submission
5. **Submit to Stores**: When ready for production

---

## 🔐 Important Security Notes

**DO NOT commit these files to Git:**
- `.env`
- `android/local.properties`
- `*.jks` (keystore files)
- `ios/Runner/GoogleService-Info.plist` (if using Firebase)

They are already in `.gitignore` ✅

---

## 📚 Useful Commands

```bash
# Check Flutter installation
flutter doctor

# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk

# Build App Bundle (for Play Store)
flutter build appbundle

# List devices
flutter devices

# Check for issues
flutter analyze
```

---

**Ready to build!** 🚀

Run: `flutter pub get && flutter build apk --debug`
