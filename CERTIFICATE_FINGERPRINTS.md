# Android Certificate Fingerprints

## Debug Certificate (Development)

### SHA-1 Fingerprint
```
65:7F:91:50:33:BD:CF:25:6E:1A:84:07:1D:00:B3:A8:33:F8:0D:96
```

### SHA-256 Fingerprint
```
C8:82:E3:CC:81:A0:BE:48:74:26:43:AE:46:C6:DE:30:3B:C4:51:F1:22:C8:A0:B0:D8:FA:BD:4C:41:18:D0:36
```

### Keystore Details
- **Location**: `C:\Users\CODE-D\.android\debug.keystore`
- **Alias**: `androiddebugkey`
- **Password**: `android`
- **Key Password**: `android`
- **Valid Until**: June 22, 2053

---

## Where to Use These Fingerprints

### 1. Google Maps API (Google Cloud Console)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **APIs & Services** > **Credentials**
4. Click on your Android API key (or create one)
5. Under **Application restrictions**, select **Android apps**
6. Click **Add an item**
7. Enter:
   - **Package name**: `com.example.findsafe`
   - **SHA-1 certificate fingerprint**: `65:7F:91:50:33:BD:CF:25:6E:1A:84:07:1D:00:B3:A8:33:F8:0D:96`

### 2. Firebase (if using Firebase)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon)
4. Scroll to **Your apps** section
5. Click on your Android app
6. Scroll to **SHA certificate fingerprints**
7. Click **Add fingerprint**
8. Paste the SHA-1: `65:7F:91:50:33:BD:CF:25:6E:1A:84:07:1D:00:B3:A8:33:F8:0D:96`

### 3. Google Sign-In / OAuth
If you're using Google Sign-In, add the SHA-1 to your OAuth 2.0 credentials in Google Cloud Console.

---

## Creating a Release Keystore (For Production)

When you're ready to publish your app, create a release keystore:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important**: 
- Store the release keystore securely
- Never commit it to version control
- Keep the password safe - you'll need it for every app update

Then get the SHA-1 for the release keystore:
```bash
keytool -list -v -keystore upload-keystore.jks -alias upload
```

---

## Quick Commands Reference

### View Debug Certificate
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### View Release Certificate (when created)
```bash
keytool -list -v -keystore android\app\upload-keystore.jks -alias upload
```

---

## Notes

- The **debug certificate** is automatically used when you run `flutter run` or build debug APKs
- You'll need to add the **release certificate** SHA-1 to Google services before publishing to Play Store
- Each developer on your team will have a different debug certificate
- The release certificate should be the same across your team and stored securely
