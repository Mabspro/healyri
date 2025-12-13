# Quick Deployment Guide

## 🚀 Deploy Web App to Firebase Hosting

```bash
# 1. Build the web app
flutter build web --release

# 2. Deploy to Firebase Hosting
firebase deploy --only hosting
```

Your app will be live at: `https://healyri-af36a.web.app`

## 📱 Generate Android Release Build

```bash
# 1. Create keystore (first time only)
keytool -genkey -v -keystore android/app/keystore/healyri-release.keystore \
  -alias healyri -keyalg RSA -keysize 2048 -validity 10000

# 2. Configure keystore.properties (see android/keystore.properties.example)

# 3. Build release APK
flutter build apk --release

# Or build App Bundle (for Play Store)
flutter build appbundle --release
```

## 🍎 Generate iOS Release Build

```bash
# 1. Open in Xcode
open ios/Runner.xcworkspace

# 2. Configure signing in Xcode
# 3. Build in Xcode: Product → Archive
```

## ⚙️ Set Up CI/CD

1. **Get Firebase Service Account:**
   - Firebase Console → Project Settings → Service Accounts
   - Generate new private key
   - Copy JSON content

2. **Add GitHub Secret:**
   - GitHub → Settings → Secrets → Actions
   - Add secret: `FIREBASE_SERVICE_ACCOUNT` (paste JSON content)

3. **Push to main branch:**
   - CI/CD will automatically run on push to `main`
   - Check Actions tab for build status

## 📋 Next Steps

1. **Generate Android Keystore** (see above)
2. **Configure iOS Signing** in Xcode
3. **Review and customize:**
   - `docs/PRIVACY_POLICY.md`
   - `docs/TERMS_OF_SERVICE.md`
4. **Set up separate Firebase projects** for dev/staging/prod
5. **Deploy web app** for testing

For detailed instructions, see [docs/DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md)

