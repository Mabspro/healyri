# Firebase Hosting Deployment Fix

## The Problem

You're seeing this error:
```
error in artifactRegistry.GetRepository: generic::not_found: repository not found: 
namespaces/healyri-af36a/repositories/firebaseapphosting-images
```

**This error occurs because you're trying to use Firebase App Hosting, but we configured Firebase Hosting instead.**

## Understanding the Difference

### Firebase Hosting (What We Configured) ✅
- **Traditional static web hosting**
- Simple file-based deployment
- Perfect for Flutter web apps
- Already configured in `firebase.json`
- **This is what you should use**

### Firebase App Hosting (What's Causing the Error) ❌
- **Newer service for full-stack apps**
- Requires Artifact Registry setup
- More complex, designed for Node.js/backend apps
- **Not needed for your Flutter web app**

## Solution: Use Firebase Hosting

### Option 1: Delete the App Hosting Backend (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `healyri-af36a`
3. In the left sidebar, look for **"App Hosting"** (if it exists)
4. If you see an App Hosting backend, delete it
5. You don't need it for a Flutter web app

### Option 2: Deploy Using Firebase Hosting (Correct Method)

**Step 1: Build the Web App**

```bash
# Make sure Flutter is in your PATH, or use full path
flutter build web --release
```

**Step 2: Deploy to Firebase Hosting**

```bash
# Deploy only hosting (not App Hosting)
firebase deploy --only hosting

# Or deploy everything (hosting + functions + firestore rules)
firebase deploy
```

**Step 3: Verify Deployment**

After deployment, your app will be available at:
- `https://healyri-af36a.web.app`
- `https://healyri-af36a.firebaseapp.com`

## Your Current Configuration

Your `firebase.json` is correctly configured for Firebase Hosting:

```json
{
  "hosting": {
    "public": "build/web",
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

This is perfect for a Flutter web app. You just need to:
1. Build the app: `flutter build web --release`
2. Deploy: `firebase deploy --only hosting`

## Troubleshooting

### If Flutter Command Not Found

**Windows:**
```powershell
# Add Flutter to PATH (if not already)
$env:Path += ";C:\path\to\flutter\bin"

# Or use full path
C:\path\to\flutter\bin\flutter.exe build web --release
```

**Or use the Flutter SDK path directly:**
- Find where Flutter is installed
- Use the full path to `flutter.exe`

### If Firebase CLI Not Found

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize (if not already done)
firebase init hosting
```

### If Build Fails

1. **Check Flutter version:**
   ```bash
   flutter --version
   ```
   Should be 3.24.0 or compatible

2. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter build web --release
   ```

3. **Check for errors:**
   ```bash
   flutter analyze
   ```

## Quick Deployment Checklist

- [ ] Flutter is installed and in PATH
- [ ] Firebase CLI is installed (`firebase --version`)
- [ ] Logged into Firebase (`firebase login`)
- [ ] Project is initialized (`firebase use healyri-af36a`)
- [ ] Web app builds successfully (`flutter build web --release`)
- [ ] `build/web` directory exists and contains files
- [ ] Deploy command runs: `firebase deploy --only hosting`

## Summary

**The error you're seeing is from Firebase App Hosting, which you don't need.**

**Solution:**
1. Ignore/delete the App Hosting backend in Firebase Console
2. Use `firebase deploy --only hosting` instead
3. Your app will deploy to Firebase Hosting (the correct service)

Your configuration is already correct - you just need to deploy using the right command!

