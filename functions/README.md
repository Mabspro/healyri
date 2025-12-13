# HeaLyri Firebase Functions

This directory contains the Firebase Cloud Functions for the HeaLyri healthcare platform. These functions handle authentication, role-based access control, and user verification.

## Table of Contents

- [Overview](#overview)
- [Functions](#functions)
- [Setup](#setup)
- [Deployment](#deployment)
- [Testing](#testing)
- [Security Rules](#security-rules)

## Overview

The HeaLyri platform uses Firebase Cloud Functions to handle server-side logic, particularly for authentication and access control. These functions are written in TypeScript and use the Firebase Admin SDK to interact with Firebase services.

## Functions

### `setUserClaims`

This function is triggered when a new user document is created in Firestore. It sets custom claims based on the user's role.

```typescript
export const setUserClaims = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snapshot, context) => {
    // Set custom claims based on user role
  });
```

### `updateUserRole`

This HTTP callable function allows administrators to update a user's role.

```typescript
export const updateUserRole = functionsV2.https.onCall(async (request) => {
  // Update user role and set custom claims
});
```

### `verifySpecialRole`

This HTTP callable function allows administrators to verify provider and driver accounts.

```typescript
export const verifySpecialRole = functionsV2.https.onCall(async (request) => {
  // Verify provider or driver account
});
```

## Setup

1. Install Node.js and npm
2. Install Firebase CLI: `npm install -g firebase-tools`
3. Clone the repository
4. Navigate to the functions directory: `cd functions`
5. Install dependencies: `npm install`
6. Build the project: `npm run build`

## Deployment

To deploy the functions to Firebase:

```bash
# Login to Firebase
firebase login

# Select your project
firebase use healyri

# Deploy all functions
firebase deploy --only functions

# Deploy a specific function
firebase deploy --only functions:setUserClaims
```

## Testing

You can test the functions locally using the Firebase Emulator Suite:

```bash
# Start the emulators
firebase emulators:start

# Run tests
npm test
```

## Security Rules

Make sure to set up appropriate security rules in Firebase to secure your functions:

```javascript
// Example Firestore security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to users collection for authenticated users
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Only allow admin users to access the admin collection
    match /admin/{document=**} {
      allow read, write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

## Admin Dashboard

To verify provider and driver accounts, you'll need to create an admin dashboard that calls the `verifySpecialRole` function. This dashboard should be secured with appropriate authentication and authorization.

Example code to call the function from a client application:

```typescript
import { getFunctions, httpsCallable } from 'firebase/functions';

const functions = getFunctions();
const verifySpecialRole = httpsCallable(functions, 'verifySpecialRole');

// Call the function
verifySpecialRole({ userId: 'user123', isVerified: true })
  .then((result) => {
    console.log('User verified successfully:', result.data);
  })
  .catch((error) => {
    console.error('Error verifying user:', error);
  });
```

## Next Steps

1. Implement additional functions for feature gating
2. Add functions for usage tracking (e.g., AI chatbot usage)
3. Implement payment processing functions
4. Add functions for emergency services coordination
