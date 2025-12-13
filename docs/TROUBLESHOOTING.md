# HeaLyri Troubleshooting Guide

**Last Updated:** December 2024

---

## Dart Analyzer Crashes

### Symptom
- "The Dart Analyzer has terminated" popup
- Analyzer keeps restarting
- No code errors but analyzer won't stay running

### Solutions (Try in Order)

#### 1. Restart Dart Extension
- Click "Restart Extension" in the error popup
- Or: Command Palette → "Dart: Restart Analysis Server"

#### 2. Clear Flutter/Dart Caches
```bash
# Clear Flutter cache
flutter clean

# Clear Dart analyzer cache
flutter pub cache repair

# Get dependencies fresh
flutter pub get
```

#### 3. Restart IDE
- Close Cursor/VS Code completely
- Reopen the project
- Let analyzer reinitialize

#### 4. Check for Memory Issues
- Close other heavy applications
- Restart your computer if analyzer keeps crashing
- Check available RAM

#### 5. Check Flutter/Dart SDK
```bash
# Verify Flutter installation
flutter doctor -v

# Check Dart version
dart --version
```

#### 6. Disable/Re-enable Extensions
- Temporarily disable other Dart/Flutter extensions
- Restart analyzer
- Re-enable one by one to find conflicts

---

## Flutter Not in PATH

### Symptom
- `flutter: The term 'flutter' is not recognized`
- Commands work in some terminals but not others

### Solutions

#### Windows PowerShell
```powershell
# Add Flutter to PATH for current session
$env:Path += ";C:\Users\mabsp\flutter\bin"

# Or use full path
C:\Users\mabsp\flutter\bin\flutter.bat run -d chrome
```

#### Permanent Fix
1. Open System Properties → Environment Variables
2. Add `C:\Users\mabsp\flutter\bin` to User PATH
3. Restart terminal/IDE

---

## Web Development Issues

### Blank Page After Changes
- **Solution:** Hard refresh browser (Ctrl+Shift+R)
- Clear browser cache
- Check console for errors

### Port Already in Use
```bash
# Use different port
flutter run -d chrome --web-port=8081
```

### Crashlytics Errors on Web
- **Expected:** Crashlytics is mobile-only
- **Solution:** Errors are harmless, code handles this

---

## Location Service Issues

### Geolocator Deprecation Warnings
- **Status:** ✅ Fixed in latest code
- Uses new `LocationSettings` API
- No action needed if using latest code

### Location Permission Denied
- Check browser permissions
- For mobile: Check device location settings
- Code handles gracefully with fallback to last known location

---

## Firebase Issues

### Authentication Errors
- Check Firebase project configuration
- Verify `firebase_options.dart` is up to date
- Run `flutterfire configure` if needed

### Firestore Permission Denied
- Check `firestore.rules`
- Verify user is authenticated
- Check user role in Firestore

---

## Build Issues

### "Building with plugins requires symlink support"
- **Windows:** Enable Developer Mode
- Run: `start ms-settings:developers`
- Toggle "Developer Mode" ON
- Restart terminal

### Dependency Conflicts
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade
```

---

## Common Quick Fixes

### 1. Full Clean Rebuild
```bash
flutter clean
flutter pub get
flutter run -d chrome --web-port=8080
```

### 2. Restart Everything
1. Kill all Flutter/Dart processes
2. Close IDE
3. Restart computer (if persistent issues)
4. Reopen project

### 3. Check Logs
- View → Output → Select "Dart" or "Flutter"
- Look for specific error messages
- Check browser console (F12) for web issues

---

## Still Having Issues?

1. Check [DEVELOPMENT_SETUP.md](DEVELOPMENT_SETUP.md) for environment setup
2. Review error messages in Output panel
3. Check Flutter/Dart version compatibility
4. Verify all dependencies are installed

---

**Last Updated:** December 2024
