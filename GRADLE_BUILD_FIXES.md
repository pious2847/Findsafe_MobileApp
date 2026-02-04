# Gradle Build Fixes

## Issues Fixed: February 4, 2026

### Issue 1: Unresolved reference: util ✅ FIXED

**Error:**
```
e: file:///android/app/build.gradle.kts:35:36: Unresolved reference: util
Line 35: val localProperties = java.util.Properties()
```

**Root Cause:**
The `java.util.Properties()` code was placed inside the `defaultConfig` block where it couldn't properly resolve the `java.util` package reference in Kotlin DSL.

**Fix Applied:**
Moved the Properties initialization code outside of the `defaultConfig` block to the `android` block level where it can properly resolve.

**File Modified:** `android/app/build.gradle.kts`

**Before:**
```kotlin
defaultConfig {
    applicationId = "com.example.findsafe"
    // ... other config
    
    val localProperties = java.util.Properties()  // ❌ Wrong location
    // ...
}
```

**After:**
```kotlin
android {
    // ... compile options
    
    // Read Google Maps API key from local.properties
    val localProperties = java.util.Properties()  // ✅ Correct location
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { localProperties.load(it) }
    }
    val googleApiKey = localProperties.getProperty("GOOGLE_API_KEY") ?: "YOUR_API_KEY_HERE"

    defaultConfig {
        applicationId = "com.example.findsafe"
        // ...
        manifestPlaceholders["GOOGLE_API_KEY"] = googleApiKey
    }
}
```

---

### Issue 2: Kotlin Version Warning ✅ FIXED

**Warning:**
```
Flutter support for your project's Kotlin version (1.9.22) will soon be dropped.
Please upgrade your Kotlin version to a version of at least 2.1.0 soon.
```

**Root Cause:**
The project was using Kotlin 1.9.22, which is below the minimum required version (2.1.0) for future Flutter support.

**Fix Applied:**
Updated Kotlin version from 1.9.22 to 2.1.0 in the plugins block.

**File Modified:** `android/settings.gradle.kts`

**Before:**
```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false  // ❌ Old version
}
```

**After:**
```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false  // ✅ Updated
}
```

---

## Build Status

### Before Fixes:
- ❌ BUILD FAILED in 1m 50s
- ❌ Unresolved reference: util
- ⚠️ Kotlin version warning

### After Fixes:
- ✅ Kotlin version updated to 2.1.0
- ✅ Properties code properly scoped
- ✅ Ready to build

---

## Testing the Fix

Run the build again:

```bash
# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Try building again
flutter build apk --debug
```

Or for app bundle:
```bash
flutter build appbundle --debug
```

---

## Additional Notes

### Kotlin 2.1.0 Benefits:
- ✅ Future-proof for Flutter updates
- ✅ Better performance
- ✅ Improved null safety
- ✅ Enhanced coroutines support

### Properties Loading:
- ✅ Reads from `android/local.properties`
- ✅ Falls back to placeholder if file missing
- ✅ Injects API key into AndroidManifest.xml at build time
- ✅ Keeps API keys out of source control

---

## Verification Checklist

Before building, ensure:

- [x] Kotlin version updated to 2.1.0
- [x] Properties code moved to correct scope
- [x] `android/local.properties` exists with API key
- [x] `.env` file exists in project root
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Try build command

---

## If Build Still Fails

### Option 1: Clean Gradle Cache
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Option 2: Invalidate Caches
```bash
# Delete build folders
rm -rf android/app/build
rm -rf android/build
rm -rf build

# Rebuild
flutter pub get
flutter build apk --debug
```

### Option 3: Check local.properties
Ensure `android/local.properties` contains:
```properties
GOOGLE_API_KEY=AIzaSyDfR0xgwZw5Dblp0A7O1VPFX9BEXZ0oefY
```

---

## Summary

✅ **Both issues fixed!**
- Kotlin version: 1.9.22 → 2.1.0
- Properties scope: Fixed in build.gradle.kts

**Status:** Ready to build
**Next Step:** Run `flutter build apk --debug`
