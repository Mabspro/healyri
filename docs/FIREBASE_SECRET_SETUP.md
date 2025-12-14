# Firebase Service Account Setup for GitHub Actions

**Last Updated:** December 2024

---

## Overview

The Firebase service account file is required for automated deployment to Firebase Hosting via GitHub Actions.

**⚠️ IMPORTANT:** The service account file contains sensitive credentials and must:
- ✅ Be added to `.gitignore` (already done)
- ✅ Be added to GitHub Secrets (not committed to repo)
- ❌ Never be committed to Git

---

## Current Setup

**Service Account File:** `healyri-af36a-firebase-adminsdk-fbsvc-ea3b7a38c5.json`

**Status:**
- ✅ File exists in project root
- ✅ Added to `.gitignore`
- ⚠️ Needs to be added to GitHub Secrets

---

## Steps to Add to GitHub Secrets

### 1. Read the Service Account File

The file is located at:
```
healyri-af36a-firebase-adminsdk-fbsvc-ea3b7a38c5.json
```

### 2. Copy the Entire Contents

Open the JSON file and copy **all** of its contents (the entire JSON object).

### 3. Add to GitHub Secrets

1. Go to your GitHub repository: `https://github.com/Mabspro/healyri`
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. **Name:** `FIREBASE_SERVICE_ACCOUNT`
5. **Value:** Paste the entire contents of the JSON file
6. Click **"Add secret"**

### 4. Verify Setup

After adding the secret:
- The next push to `main` branch will trigger the workflow
- The "Build Web App" job will build and deploy to Firebase Hosting
- If the secret is missing, the build will succeed but deployment will be skipped

---

## Workflow Behavior

**With Secret Configured:**
- ✅ Builds web app
- ✅ Deploys to Firebase Hosting automatically

**Without Secret:**
- ✅ Builds web app
- ⚠️ Skips deployment (with informative message)
- ✅ Build job still succeeds

---

## Security Notes

1. **Never commit the service account file to Git**
   - It's already in `.gitignore`
   - If it was committed before, remove it from Git history

2. **The file in the project root is for local use only**
   - Keep it for local development/testing
   - Don't share it publicly
   - Consider moving it to a secure location outside the repo

3. **GitHub Secrets are encrypted**
   - Only accessible to repository collaborators with appropriate permissions
   - Not visible in logs or pull requests

---

## Alternative: Use Environment-Specific Files

For better security, consider:
- Moving the file outside the project directory
- Using environment variables for local development
- Using different service accounts for dev/staging/prod

---

## Verification

After adding the secret, verify it works:

1. Push a commit to `main` branch
2. Check GitHub Actions workflow
3. "Build Web App" job should:
   - Build successfully
   - Deploy to Firebase Hosting (if secret is configured)
   - Show deployment URL in logs

---

**Next Steps:** Once the secret is added, web deployments will happen automatically on every push to `main`.

