# Firebase Configuration Guide

## Overview

HeaLyri uses Firebase for hosting, functions, Firestore, and storage. This document explains the configuration and deployment setup.

## Configuration Files

### `firebase.json`

Main Firebase configuration file defining all services:

```json
{
  "functions": {
    "source": "functions",
    "predeploy": ["npm --prefix \"$RESOURCE_DIR\" run build"],
    "runtime": "nodejs20"
  },
  "hosting": {
    "public": "build/web",
    "rewrites": [{"source": "**", "destination": "/index.html"}]
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  }
}
```

### Key Configuration Decisions

#### Functions Runtime: Node.js 20

**Why Node 20 instead of Node 22?**

- **Gen 1 Functions**: Our functions use `firebase-functions/v1` (Gen 1), which has better compatibility with Node 20
- **Deployment Reliability**: Node 22 can cause deployment failures in Gen 1 functions depending on Firebase CLI version and project configuration
- **Safe Default**: Node 20 is the recommended stable runtime for Gen 1 functions
- **Future Migration**: When we migrate to Gen 2 (Cloud Run functions), we can revisit Node 22

**Current Functions:**
- `setUserClaims` - Gen 1 (v1)
- `onEmergencyCreated` - Gen 1 (v1)

#### Hosting Configuration

**Static Web Hosting (Firebase Hosting):**
- ✅ **Correct**: Uses `build/web` (Flutter web build output)
- ✅ **SPA Routing**: Rewrites all routes to `/index.html` for client-side routing
- ✅ **No App Hosting**: We use traditional Firebase Hosting, not App Hosting

**Note:** If you see errors about "App Hosting" or "Artifact Registry", you're accidentally using the wrong service. Use `firebase deploy --only hosting` instead.

## Deployment Commands

### Web Deployment (Hosting)

```bash
# Build Flutter web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

**Result:** App available at `https://healyri-af36a.web.app`

### Functions Deployment

```bash
# Deploy functions only
firebase deploy --only functions

# Or deploy everything
firebase deploy
```

### Separate Deployments (Recommended)

Deploy hosting and functions separately to avoid mixing concerns:

```bash
# Deploy web app
flutter build web --release
firebase deploy --only hosting

# Deploy backend functions
firebase deploy --only functions
```

## Functions Architecture

### Current Functions (Gen 1)

1. **`setUserClaims`**
   - Trigger: `users/{userId}` document creation
   - Purpose: Sets Firebase Auth custom claims based on user role
   - Runtime: Node 20

2. **`onEmergencyCreated`**
   - Trigger: `emergencies/{emergencyId}` document creation
   - Purpose: Auto-dispatch to nearest facility and driver
   - Runtime: Node 20

### Future Migration to Gen 2

When ready to migrate to Gen 2 (Cloud Run functions):

1. Update imports: `firebase-functions/v1` → `firebase-functions/v2`
2. Update function signatures to Gen 2 format
3. Consider updating runtime to `nodejs22` (supported in Gen 2)
4. Test thoroughly before production deployment

## Firebase CLI

### Check Version

```bash
firebase --version
```

**Recommendation:** Keep Firebase CLI updated for best compatibility:

```bash
npm install -g firebase-tools@latest
```

### Login

```bash
firebase login
```

### Select Project

```bash
firebase use healyri-af36a
```

## Troubleshooting

### Functions Deployment Fails

**Error:** "Invalid runtime" or "Runtime not supported"

**Solution:**
- Verify `firebase.json` has `"runtime": "nodejs20"` (not `nodejs22`)
- Update Firebase CLI: `npm install -g firebase-tools@latest`
- Check functions are Gen 1 (using `firebase-functions/v1`)

### Hosting Deployment Fails

**Error:** "Artifact Registry repository not found"

**Solution:**
- You're accidentally using App Hosting instead of Firebase Hosting
- Use `firebase deploy --only hosting` (not App Hosting)
- Delete any App Hosting backends in Firebase Console

### Build Errors

**Error:** TypeScript compilation fails

**Solution:**
```bash
cd functions
npm install
npm run build
```

## Environment Setup

### Development

```bash
# Use development Firebase project
firebase use healyri-dev

# Run emulators locally
firebase emulators:start
```

### Production

```bash
# Use production Firebase project
firebase use healyri-af36a

# Deploy
firebase deploy
```

## Best Practices

1. **Separate Deployments**: Deploy hosting and functions separately
2. **Test Locally**: Use Firebase emulators before deploying
3. **Version Control**: Keep `firebase.json` in Git, but not sensitive config
4. **Runtime Stability**: Use Node 20 for Gen 1 functions until migrating to Gen 2
5. **CLI Updates**: Keep Firebase CLI updated for best compatibility

## References

- [Firebase Functions Documentation](https://firebase.google.com/docs/functions)
- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [Node.js Runtime Support](https://firebase.google.com/docs/functions/manage-functions#set_nodejs_version)
- [Gen 1 vs Gen 2 Functions](https://firebase.google.com/docs/functions/2nd-gen-upgrade)

