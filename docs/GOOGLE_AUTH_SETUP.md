# Google Authentication Setup Guide

## Current Status

✅ **Google Sign-In is configured and working**
- Meta tag added to `web/index.html`
- Client ID configured in `auth_service.dart`
- Only 'email' scope used (avoids People API requirement)

## Configuration

### Web Configuration

**File:** `web/index.html`

```html
<meta name="google-signin-client_id" content="855143760278-hj7ivko8g5fq32aeo90u2j37lt3b7g1s.apps.googleusercontent.com">
```

### Code Configuration

**File:** `lib/services/auth_service.dart`

- Client ID is conditionally set for web only
- Only 'email' scope is requested (no 'profile' scope to avoid People API requirement)
- Firebase Auth provides user name and photo from ID token

## Why Only 'email' Scope?

The 'profile' scope requires the Google People API to be enabled in Google Cloud Console. However, we don't need it because:

1. **Firebase Auth provides user info**: The ID token from Google Sign-In contains the user's display name and photo URL
2. **No additional API needed**: We can get all required information from Firebase Auth's `user` object
3. **Simpler setup**: No need to enable People API in Google Cloud Console

## User Information Available

Even without the 'profile' scope, Firebase Auth provides:
- ✅ Email address
- ✅ Display name (from Google account)
- ✅ Photo URL (from Google account)
- ✅ User ID

All of this comes from the Google ID token, not from the People API.

## Optional: Enable People API (Not Required)

If you want to use the People API in the future (for additional profile information), you can enable it:

1. Go to: https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=855143760278
2. Click "Enable"
3. Wait a few minutes for propagation
4. Then you can add 'profile' scope back to the scopes array

**Note:** This is NOT required for basic Google Sign-In to work.

## Testing

1. Click "Sign in with Google" button
2. Select Google account
3. Grant email permission
4. User should be signed in and redirected to home screen

## Troubleshooting

### Error: "People API has not been used"
- **Solution:** Already fixed - removed 'profile' scope
- Only 'email' scope is used now

### Error: "ClientID not set"
- **Solution:** Ensure meta tag is in `web/index.html`
- Restart Flutter web app after adding meta tag

### Google Sign-In works but user info is missing
- **Check:** Firebase Auth user object has `displayName` and `photoURL`
- These come from the ID token, not from People API

---

**Status:** ✅ Google Sign-In is configured and ready to use

