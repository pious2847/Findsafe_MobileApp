@echo off
echo Fixing JVM target compatibility issues in Flutter plugins...

set CACHE_DIR=%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev

echo Searching for audioplayers_android plugin...
for /d %%d in ("%CACHE_DIR%\audioplayers_android-*") do (
    echo Found: %%d
    set PLUGIN_DIR=%%d\android
    echo Checking if build.gradle exists in %%d\android
    if exist "%%d\android\build.gradle" (
        echo Modifying %%d\android\build.gradle
        echo. >> "%%d\android\build.gradle"
        echo // Added by fix script >> "%%d\android\build.gradle"
        echo android { >> "%%d\android\build.gradle"
        echo     compileOptions { >> "%%d\android\build.gradle"
        echo         sourceCompatibility JavaVersion.VERSION_1_8 >> "%%d\android\build.gradle"
        echo         targetCompatibility JavaVersion.VERSION_1_8 >> "%%d\android\build.gradle"
        echo     } >> "%%d\android\build.gradle"
        echo     kotlinOptions { >> "%%d\android\build.gradle"
        echo         jvmTarget = '1.8' >> "%%d\android\build.gradle"
        echo     } >> "%%d\android\build.gradle"
        echo } >> "%%d\android\build.gradle"
        echo Fixed audioplayers_android plugin
    ) else (
        echo build.gradle not found in %%d\android
    )
)

echo Searching for flutter_background plugin...
for /d %%d in ("%CACHE_DIR%\flutter_background-*") do (
    echo Found: %%d
    set PLUGIN_DIR=%%d\android
    echo Checking if build.gradle exists in %%d\android
    if exist "%%d\android\build.gradle" (
        echo Modifying %%d\android\build.gradle
        echo. >> "%%d\android\build.gradle"
        echo // Added by fix script >> "%%d\android\build.gradle"
        echo android { >> "%%d\android\build.gradle"
        echo     compileOptions { >> "%%d\android\build.gradle"
        echo         sourceCompatibility JavaVersion.VERSION_1_8 >> "%%d\android\build.gradle"
        echo         targetCompatibility JavaVersion.VERSION_1_8 >> "%%d\android\build.gradle"
        echo     } >> "%%d\android\build.gradle"
        echo     kotlinOptions { >> "%%d\android\build.gradle"
        echo         jvmTarget = '1.8' >> "%%d\android\build.gradle"
        echo     } >> "%%d\android\build.gradle"
        echo } >> "%%d\android\build.gradle"
        echo Fixed flutter_background plugin
    ) else (
        echo build.gradle not found in %%d\android
    )
)

echo Done! Now try running 'flutter clean' and 'flutter run' again.
