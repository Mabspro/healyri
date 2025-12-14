# Quick Build & Deploy Guide

**Last Updated:** December 2024  
**Project:** HeaLyri Emergency Coordination Platform

## Prerequisites

- Flutter SDK: `C:\Users\mabsp\flutter`
- Firebase CLI: Use `npx firebase-tools` (not `firebase` command)
- Node.js: Required for Firebase CLI

---

## Development Workflow

### 1. Kill Running Processes

```powershell
taskkill /F /IM flutter.exe 2>$null
taskkill /F /IM dart.exe 2>$null
taskkill /F /IM chrome.exe /FI "WINDOWTITLE eq *flutter*" 2>$null
```

### 2. Clean Build

```powershell
C:\Users\mabsp\flutter\bin\flutter.bat clean
```

### 3. Get Dependencies

```powershell
C:\Users\mabsp\flutter\bin\flutter.bat pub get
```

### 4. Run Development Server

```powershell
C:\Users\mabsp\flutter\bin\flutter.bat run -d chrome --web-port=8080
```

**Access:** `http://localhost:8080`

---

## Production Build & Deploy

### 1. Build Web Release

```powershell
C:\Users\mabsp\flutter\bin\flutter.bat build web --release
```

**Output:** `build\web\`

### 2. Deploy to Firebase Hosting

```powershell
npx firebase-tools deploy --only hosting
```

**Note:** 
- ✅ Use `firebase deploy --only hosting` (Firebase Hosting)
- ❌ Do NOT use Firebase App Hosting (different service)

### 3. Verify Deployment

Check your Firebase Console → Hosting → View your site

---

## Quick Commands Reference

### Full Clean & Rebuild

```powershell
# Kill processes
taskkill /F /IM flutter.exe 2>$null; taskkill /F /IM dart.exe 2>$null

# Clean
C:\Users\mabsp\flutter\bin\flutter.bat clean

# Get dependencies
C:\Users\mabsp\flutter\bin\flutter.bat pub get

# Build
C:\Users\mabsp\flutter\bin\flutter.bat build web --release

# Deploy
npx firebase-tools deploy --only hosting
```

### Development Restart

```powershell
# Kill processes
taskkill /F /IM flutter.exe 2>$null; taskkill /F /IM dart.exe 2>$null

# Clean
C:\Users\mabsp\flutter\bin\flutter.bat clean

# Get dependencies
C:\Users\mabsp\flutter\bin\flutter.bat pub get

# Start dev server
C:\Users\mabsp\flutter\bin\flutter.bat run -d chrome --web-port=8080
```

---

## Important Notes

### Flutter Path
- **Always use full path:** `C:\Users\mabsp\flutter\bin\flutter.bat`
- Do not rely on `flutter` being in PATH

### Firebase CLI
- **Always use:** `npx firebase-tools`
- Do not use `firebase` command directly (may not be in PATH)

### Firebase Hosting vs App Hosting
- ✅ **Firebase Hosting:** Static web hosting (what we use)
- ❌ **Firebase App Hosting:** Full-stack backend hosting (NOT what we use)

### Deployment Command
- ✅ **Correct:** `npx firebase-tools deploy --only hosting`
- ❌ **Wrong:** `firebase deploy` (may use App Hosting if configured)

---

## Troubleshooting

### Flutter Command Not Found
- Use full path: `C:\Users\mabsp\flutter\bin\flutter.bat`

### Firebase Command Not Found
- Use: `npx firebase-tools` instead of `firebase`

### Build Errors
1. Clean: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Rebuild: `flutter build web --release`

### Deployment Errors
- Ensure you're using `--only hosting` flag
- Check `firebase.json` configuration
- Verify Firebase project is initialized: `npx firebase-tools projects:list`

---

## File Locations

- **Build Output:** `build\web\`
- **Firebase Config:** `firebase.json`
- **Firestore Rules:** `firestore.rules`
- **Firestore Indexes:** `firestore.indexes.json`
- **Cloud Functions:** `functions\src\index.ts`

---

## Git Workflow

### Before Deploying

```powershell
# Commit changes
git add -A
git commit -m "Your commit message"
git push origin main
```

### After Deploying

```powershell
# Tag release (optional)
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

---

## Environment Variables

Currently using default Firebase configuration. For multiple environments, see:
- `lib/config/env.dart` (placeholder)
- Firebase project selection: `npx firebase-tools use <project-id>`

---

## Quick Reference Card

```
┌─────────────────────────────────────────┐
│  DEVELOPMENT                            │
├─────────────────────────────────────────┤
│  Kill: taskkill /F /IM dart.exe          │
│  Clean: flutter clean                   │
│  Get: flutter pub get                   │
│  Run: flutter run -d chrome --web-port=8080 │
│                                         │
│  PRODUCTION                             │
├─────────────────────────────────────────┤
│  Build: flutter build web --release    │
│  Deploy: npx firebase-tools deploy --only hosting │
└─────────────────────────────────────────┘
```

---

**Remember:** Always use full Flutter path and `npx firebase-tools` for Firebase commands!

