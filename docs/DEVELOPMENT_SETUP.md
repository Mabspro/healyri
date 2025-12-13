# HeaLyri - Recommended Development Setup

## Current Status

✅ **Fixed:** Firebase package compatibility issues resolved by updating to latest versions
✅ **Updated:** All Firebase packages to latest compatible versions
✅ **Improved:** Logging, error handling, and input validation implemented

## Recommended Development Environment

### 1. **Primary Development Platform: Chrome Web**

**Why:** 
- Fastest iteration cycle
- Easy debugging with Chrome DevTools
- No symlink issues (Windows Developer Mode not required)
- Hot reload works perfectly

**Command:**
```bash
flutter run -d chrome --web-port=8080
```

### 2. **Alternative: Android Emulator**

**Why:**
- Best for testing mobile-specific features
- Full Firebase functionality
- Better performance testing

**Setup:**
1. Install Android Studio
2. Create an Android Virtual Device (AVD)
3. Run: `flutter run -d <device-id>`

### 3. **Windows Desktop (Optional)**

**Why:**
- Native performance
- Good for testing desktop-specific features

**Requirements:**
- Enable Developer Mode in Windows Settings
- Run: `start ms-settings:developers`
- Enable "Developer Mode" toggle
- Restart terminal/IDE

**Command:**
```bash
flutter run -d windows
```

## Current Package Versions

### Firebase Packages (Updated)
```yaml
firebase_core: ^4.2.1
firebase_auth: ^6.1.2
cloud_firestore: ^6.1.0
firebase_storage: ^13.0.4
firebase_messaging: ^16.0.4
firebase_analytics: ^12.0.4
firebase_performance: ^0.11.1+2
firebase_crashlytics: ^5.0.5
```

### Key Dependencies
```yaml
logger: ^2.0.2+1          # Proper logging
provider: ^6.0.5          # State management
google_fonts: ^6.1.0      # Typography
```

## Development Workflow

### Daily Development
1. **Start Development Server:**
   ```bash
   flutter run -d chrome --web-port=8080
   ```

2. **Hot Reload:** Press `r` in terminal or save file (if auto-save enabled)

3. **Hot Restart:** Press `R` in terminal

4. **Stop:** Press `q` in terminal

### Code Quality Checks
```bash
# Run linter
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test
```

## Troubleshooting

### Issue: Firebase Web Compilation Errors

**Solution:** Already fixed by updating Firebase packages to latest versions.

If you encounter `handleThenable` errors:
1. Ensure you're using Firebase packages v6+ for auth, v13+ for storage
2. Run `flutter clean && flutter pub get`
3. Delete `pubspec.lock` and reinstall: `del pubspec.lock && flutter pub get`

### Issue: Windows Symlink Errors

**Solution:** 
- Use Chrome web for development (recommended)
- Or enable Windows Developer Mode:
  ```powershell
  start ms-settings:developers
  ```

### Issue: Dependency Conflicts

**Solution:**
```bash
# Clean and reinstall
flutter clean
del pubspec.lock
flutter pub get
```

## Project Structure

```
lib/
├── core/                    # Core utilities
│   ├── logger.dart         # Logging service
│   ├── error_handler.dart  # Error handling
│   └── validators.dart     # Input validation
├── services/               # Business logic services
│   └── auth_service.dart
├── auth/                   # Authentication screens
├── home/                   # Home screens
├── shared/                 # Shared components
└── main.dart              # App entry point
```

## Best Practices

### 1. **Logging**
- Use `AppLogger.i()` for info messages
- Use `AppLogger.e()` for errors (auto-reports to Crashlytics)
- Never use `print()` statements

### 2. **Error Handling**
- Use `ErrorHandler.handleError()` for consistent error handling
- Provide user-friendly error messages

### 3. **Input Validation**
- Use `Validators` class for all form inputs
- Validate on both client and server side

### 4. **State Management**
- Use Provider pattern (already set up)
- Keep business logic in services, not UI

## Next Steps for Development

1. ✅ **Completed:**
   - Logging infrastructure
   - Error handling service
   - Input validation
   - Firebase package updates

2. **In Progress:**
   - Service layer architecture
   - Repository pattern
   - Enhanced security rules

3. **Upcoming:**
   - Offline support
   - Caching layer
   - Comprehensive testing

## Performance Tips

1. **Use Chrome DevTools:**
   - Open DevTools (F12)
   - Check Performance tab for bottlenecks
   - Monitor Network tab for API calls

2. **Hot Reload:**
   - Use hot reload (`r`) for UI changes
   - Use hot restart (`R`) for logic changes

3. **Build Optimization:**
   ```bash
   # Release build for performance testing
   flutter build web --release
   ```

## Environment Configuration

### Development
- Use Firebase development project
- Enable debug logging
- Use mock data for testing

### Production
- Use Firebase production project
- Disable debug logging
- Enable Crashlytics
- Use production API endpoints

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Flutter Docs](https://firebase.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Project Review](./PROJECT_REVIEW.md)

---

**Last Updated:** December 2024  
**Status:** ✅ Development environment ready

