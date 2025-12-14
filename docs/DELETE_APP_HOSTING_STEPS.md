# Quick Steps to Delete App Hosting Backend

## What You're Seeing

You're in the **App Hosting → Domains** section, which shows:
- `healyri--healyri-af36a.us-east4.hosted.app`
- `*.healyri--healyri-af36a.us-east4.hosted.app`

**These are App Hosting domains** - they're part of the backend that needs to be deleted.

## What to Do

### ❌ DON'T Delete the Domains Individually
- The domains are just part of the backend
- Deleting them won't remove the backend
- The backend will still try to build and fail

### ✅ DO Delete the Entire Backend

**Step 1: Go to the Backend Overview**
- In the left sidebar, click **"Backends"** or **"App Hosting"** (the main section, not "Domains")
- You should see a backend named **"healyri"**

**Step 2: Delete the Backend**
- Click on the backend name **"healyri"**
- OR click the three-dot menu (⋮) next to it
- Select **"Delete"** or **"Delete backend"**
- Confirm the deletion

**Step 3: Verify**
- The backend disappears
- The domains will automatically be removed
- No more build errors

## Alternative: If You Can't Find Delete Option

1. Go to Firebase Console: https://console.firebase.google.com/project/healyri-af36a
2. Look for **"App Hosting"** in the left sidebar
3. Click on it (not "Domains")
4. You should see the backend with failed builds
5. Look for a delete/trash icon or three-dot menu

## After Deletion

✅ Your Firebase Hosting app still works: https://healyri-af36a.web.app
✅ No more App Hosting build errors
✅ Future deployments use Firebase Hosting (correct service)

## Summary

**Action:** Delete the entire **App Hosting backend** (not just the domains)
**Result:** Domains are automatically removed, build errors stop
**Your app:** Still works via Firebase Hosting at `healyri-af36a.web.app`

