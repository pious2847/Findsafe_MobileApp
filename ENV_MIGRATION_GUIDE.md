# Environment Variables Migration Guide

## What Changed

The project has been migrated from using a hardcoded `lib/.env.dart` file to using a proper `.env` file with the `flutter_dotenv` package.

## Setup Instructions

### 1. Install Dependencies

Run the following command to install the new `flutter_dotenv` package:

```bash
flutter pub get
```

### 2. Environment Variables

The `.env` file is already configured with your environment variables:

- `GOOGLE_API_KEY` - Your Google Maps API key
- `API_URL` - Your backend API URL

**Important:** The `.env` file is already in `.gitignore` to keep your secrets safe.

### 3. How to Use

In your Dart code, access environment variables like this:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Access variables
String apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
String apiUrl = dotenv.env['API_URL'] ?? '';
```

### 4. Updated Files

The following files have been updated to use `flutter_dotenv`:

- `lib/main.dart` - Loads the `.env` file on app startup
- `lib/service/auth.dart`
- `lib/service/device.dart`
- `lib/service/location.dart`
- `lib/utilities/directions.dart`
- `lib/utilities/georeverse.dart`

### 5. Adding New Environment Variables

To add new environment variables:

1. Add them to the `.env` file:
   ```
   NEW_VARIABLE=value
   ```

2. Access them in your code:
   ```dart
   String newVar = dotenv.env['NEW_VARIABLE'] ?? '';
   ```

## Benefits

- **Security**: Environment variables are not committed to version control
- **Flexibility**: Easy to change values without modifying code
- **Best Practice**: Standard approach for managing configuration
- **Multiple Environments**: Easy to create `.env.dev`, `.env.prod`, etc.
