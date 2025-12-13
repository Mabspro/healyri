# HeaLyri Deployment Guide

This guide provides step-by-step instructions for deploying HeaLyri to various platforms.

## Prerequisites

- Flutter SDK installed (3.0+)
- Firebase CLI installed (`npm install -g firebase-tools`)
- Firebase project created and configured
- Git repository set up
- Appropriate credentials and certificates

---

## ⚠️ Important: Firebase Hosting vs App Hosting

**HeaLyri uses Firebase Hosting (not App Hosting).**

- ✅ **Firebase Hosting**: Static web hosting (what we use)
- ❌ **Firebase App Hosting**: Full-stack hosting with Artifact Registry (not needed)

If you see an error about `artifactRegistry` or `firebaseapphosting-images`, you're accidentally using App Hosting. Use `firebase deploy --only hosting` instead.

See [HOSTING_DEPLOYMENT_FIX.md](HOSTING_DEPLOYMENT_FIX.md) for details.

---

## 1. Environment Setup

### 1.1 Firebase Projects

Create separate Firebase projects for different environments:

```bash
# Development
firebase projects:create healyri-dev

# Staging
firebase projects:create healyri-staging

# Production
firebase projects:create healyri-prod
```

### 1.2 Firebase CLI Login

```bash
firebase login
firebase use healyri-af36a  # or your project ID
```

### 1.3 Environment Variables

Create environment-specific configuration files (not committed to Git):

```bash
# Development
cp .env.example .env.development

# Production
cp .env.example .env.production
```

---

## 2. Web Deployment (Firebase Hosting)

### 2.1 Build Web App

```bash
# Build for production
flutter build web --release

# Build with specific base href (if needed)
flutter build web --release --base-href /healyri/
```

### 2.2 Deploy to Firebase Hosting

```bash
# Deploy hosting only
firebase deploy --only hosting

# Deploy everything (hosting + functions + firestore rules)
firebase deploy

# Deploy to specific project
firebase use healyri-prod
firebase deploy --only hosting
```

### 2.3 Preview Deployment

```bash
# Create preview channel
firebase hosting:channel:deploy preview-branch-name

# List preview channels
firebase hosting:channel:list
```

### 2.4 Custom Domain

1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Follow DNS configuration instructions
4. Wait for SSL certificate provisioning

---

## 3. Android Deployment

### 3.1 Generate Release Keystore

```bash
keytool -genkey -v -keystore android/app/keystore/healyri-release.keystore \
  -alias healyri -keyalg RSA -keysize 2048 -validity 10000
```

**Important:** Store the keystore file and passwords securely. You cannot recover them if lost.

### 3.2 Configure Keystore

1. Create `keystore.properties` at the project root (same level as `android/` folder):
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=healyri
storeFile=keystore/healyri-release.keystore
```

**Note:** The `storeFile` path is relative to `android/app/` (where `build.gradle.kts` is located), so `keystore/healyri-release.keystore` correctly resolves to `android/app/keystore/healyri-release.keystore`.

2. Ensure `keystore.properties` is in `.gitignore`

### 3.3 Build Release APK

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Build split APKs by ABI
flutter build apk --split-per-abi --release
```

### 3.4 Google Play Store Deployment

1. **Create App in Play Console**
   - Go to Google Play Console
   - Create new app
   - Fill in store listing details

2. **Upload App Bundle**
   - Go to Production → Create new release
   - Upload `build/app/outputs/bundle/release/app-release.aab`
   - Fill in release notes
   - Review and roll out

3. **Internal Testing**
   - Upload to Internal testing track first
   - Test with internal testers
   - Then promote to Production

---

## 4. iOS Deployment

### 4.1 Configure Signing

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to Signing & Capabilities
4. Select your Team
5. Enable "Automatically manage signing"

### 4.2 Update Bundle Identifier

1. In Xcode, change Bundle Identifier from `com.example.healyri` to `com.healyri.app`
2. Update in `ios/Runner/Info.plist`:
```xml
<key>CFBundleIdentifier</key>
<string>com.healyri.app</string>
```

### 4.3 Build for iOS

```bash
# Build iOS app (requires Mac)
flutter build ios --release

# Build without codesigning (for CI/CD)
flutter build ios --release --no-codesign
```

### 4.4 App Store Deployment

1. **Archive in Xcode**
   - Open `ios/Runner.xcworkspace`
   - Product → Archive
   - Wait for archive to complete

2. **Upload to App Store Connect**
   - In Organizer, click "Distribute App"
   - Select "App Store Connect"
   - Follow upload wizard

3. **Submit for Review**
   - Go to App Store Connect
   - Complete app information
   - Submit for review

---

## 5. Cloud Functions Deployment

### 5.1 Build Functions

```bash
cd functions
npm install
npm run build
```

### 5.2 Deploy Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:onEmergencyCreated

# Deploy with environment variables
firebase functions:config:set app.environment="production"
firebase deploy --only functions
```

---

## 6. Firestore Rules and Indexes

### 6.1 Deploy Security Rules

```bash
# Deploy rules
firebase deploy --only firestore:rules

# Test rules locally
firebase emulators:start --only firestore
```

### 6.2 Deploy Indexes

```bash
# Deploy indexes
firebase deploy --only firestore:indexes

# Note: Some indexes may need to be created manually in Firebase Console
```

---

## 7. CI/CD with GitHub Actions

### 7.1 Set Up Secrets

In GitHub repository settings, add secrets:
- `FIREBASE_SERVICE_ACCOUNT`: Firebase service account JSON
- `KEYSTORE_PASSWORD`: Android keystore password
- `KEY_PASSWORD`: Android key password

### 7.2 Get Firebase Service Account

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Download JSON file
4. Add content to GitHub secret `FIREBASE_SERVICE_ACCOUNT`

### 7.3 Workflow Triggers

The workflow (`.github/workflows/build-and-deploy.yml`) automatically:
- Runs on push to `main` branch
- Runs on pull requests
- Can be manually triggered

---

## 8. Environment-Specific Deployment

### 8.1 Development

```bash
# Switch to dev project
firebase use healyri-dev

# Build with dev config
flutter build web --release --dart-define=ENVIRONMENT=development

# Deploy
firebase deploy --only hosting
```

### 8.2 Staging

```bash
# Switch to staging project
firebase use healyri-staging

# Build with staging config
flutter build web --release --dart-define=ENVIRONMENT=staging

# Deploy
firebase deploy --only hosting
```

### 8.3 Production

```bash
# Switch to production project
firebase use healyri-prod

# Build with production config
flutter build web --release --dart-define=ENVIRONMENT=production

# Deploy
firebase deploy --only hosting
```

---

## 9. Post-Deployment Checklist

- [ ] Verify web app is accessible
- [ ] Test authentication flows
- [ ] Verify Firebase services are working
- [ ] Check error logs in Firebase Console
- [ ] Monitor performance metrics
- [ ] Test on multiple devices/browsers
- [ ] Verify analytics are tracking
- [ ] Check crash reports (if any)
- [ ] Test emergency flow end-to-end
- [ ] Verify all API endpoints are working

---

## 10. Rollback Procedures

### 10.1 Web Rollback

```bash
# List previous deployments
firebase hosting:clone healyri-prod:live healyri-prod:rollback

# Or revert in Firebase Console
# Hosting → Releases → Select previous version → Rollback
```

### 10.2 App Rollback

- **Android:** Upload previous APK/AAB version in Play Console
- **iOS:** Submit previous build in App Store Connect

---

## 11. Monitoring and Maintenance

### 11.1 Monitor Firebase Console

- **Analytics:** User engagement, feature usage
- **Crashlytics:** Error reports and crashes
- **Performance:** App performance metrics
- **Hosting:** Traffic and bandwidth usage

### 11.2 Set Up Alerts

- Firebase Console → Alerts
- Set up alerts for:
  - High error rates
  - Performance degradation
  - Unusual traffic patterns
  - Cost thresholds

### 11.3 Regular Maintenance

- Weekly: Review error logs and crash reports
- Monthly: Review analytics and performance metrics
- Quarterly: Security audit and dependency updates

---

## 12. Troubleshooting

### 12.1 Build Failures

```bash
# Clean build
flutter clean
flutter pub get
flutter build web --release
```

### 12.2 Deployment Failures

- Check Firebase CLI is logged in: `firebase login:list`
- Verify project selection: `firebase use`
- Check Firebase project permissions
- Review Firebase Console for error messages

### 12.3 Common Issues

**Issue:** "Firebase project not found"
- Solution: Verify project ID and permissions

**Issue:** "Build fails with missing dependencies"
- Solution: Run `flutter pub get` and `npm install` in functions/

**Issue:** "Hosting deployment fails"
- Solution: Ensure `build/web` directory exists after `flutter build web`

---

## 13. Security Best Practices

1. **Never commit:**
   - Keystore files
   - `.env` files with secrets
   - `keystore.properties`
   - Firebase service account keys

2. **Use environment variables:**
   - Store secrets in GitHub Secrets
   - Use Firebase Functions config for server-side secrets

3. **Regular security audits:**
   - Review Firestore security rules
   - Update dependencies regularly
   - Monitor for security vulnerabilities

---

## 14. Cost Optimization

### 14.1 Firebase Free Tier Limits

- **Hosting:** 10 GB storage, 360 MB/day transfer
- **Firestore:** 1 GB storage, 50K reads/day
- **Functions:** 2M invocations/month
- **Storage:** 5 GB storage, 1 GB/day transfer

### 14.2 Monitor Usage

- Firebase Console → Usage and Billing
- Set up billing alerts
- Optimize queries and indexes
- Use caching where appropriate

---

## Quick Reference

```bash
# Full deployment (web)
flutter build web --release && firebase deploy --only hosting

# Full deployment (everything)
flutter build web --release && firebase deploy

# Android release build
flutter build appbundle --release

# iOS release build (Mac only)
flutter build ios --release
```

---

**Need Help?** Contact the development team or refer to:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Deployment Guide](https://flutter.dev/docs/deployment)
- [Production Readiness Guide](PRODUCTION_READINESS.md)

