📘 HeaLyri Access Control, Feature Gating & Monetization Strategy
🎯 Purpose
To design a modular, role-aware, and scalable access framework that ensures:

A seamless mobile-first experience

High value delivery to patients

Low-friction onboarding for all users

Sustainable monetization for clinics

Clean role-based routing and gating using Firebase

🔑 User Roles & Onboarding Paths
Role	Access Type	Form Factor	Features
👤 Patient	Public → Signed-in → Verified	Mobile-first	Directory, Booking, AI, Profile, Emergency
🏥 Clinic Admin	Role-specific login	Web + Mobile	Scheduling, Appointments, Patient View
🚗 Transport Partner	Mobile-first login	Mobile-only	Accept requests, Toggle availability, SOS dispatch
🔒 Feature Gating Matrix
Feature	Guest (No Login)	Signed-In (Basic)	Verified (Deposit + Clinic)
Facility Directory	✅	✅	✅
Appointment Booking	❌ → Prompt to login	✅	✅
Emergency Button	❌	❌	✅
Yango Dispatch	❌	❌	✅
Telehealth	❌	✅ (trial)	✅
Medication Checker	✅ (basic)	✅	✅
AI Triage Chatbot	1–2 chats/mo	5 chats/mo	Unlimited
🧠 AI Triage Chatbot Access Plan
Tier	Access	Gating Trigger
Public	1–2 chats/month	None
Basic Patient	5 chats/month	Login only
Verified Patient	Unlimited	Emergency Setup + Deposit
Public Health Override	Unlimited	Enabled via Firebase flag during outbreaks
Mechanism: Firestore counters track chats per user. UI displays usage meter.
Incentive CTA: “Unlock unlimited AI health guidance by completing your profile.”

💸 Monetization Pathways
Patients
Emergency Deposit: Held for taxi + clinic readiness (pre-auth, refunded if unused)

Optional Premium Chat Bundle (future)

Micro-subscription (e.g. for priority access to doctors or saved triage history)

Clinics
Commission on Consult Fee: HeaLyri takes % (not treatment fees)

Clinic Dashboard Access: Optional subscription for expanded analytics or integrations

Transport Partners
Per-trip commission split

Future wallet + payout system

🧭 UX Flow Notes
Chatbot, booking, and emergency button should show locks/tooltips if accessed early

Use soft-gating: clicking restricted features prompts users to complete setup (e.g. designate a clinic)

Maintain warm, empowering messaging — not rigid denial

🛠 Technical Summary
Stack	Tool
Auth & Role Control	Firebase Auth + Custom Claims
Data & Gating	Firestore with access state fields (has_deposit, is_verified, chat_count)
UI Gating Logic	Flutter role-based routing + progress modals
Emergency Setup	Structured as its own onboarding step after login
Feature Unlocks	Reflected dynamically per user via Firestore snapshot listener

## Implementation Status

The following access control features have been implemented:

### Custom Claims Implementation ✅

Firebase Custom Claims are now used to securely store user roles and verification status:

```javascript
// Cloud Function sets custom claims on user creation
export const setUserClaims = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snapshot, context) => {
    const customClaims = {
      role: role,
      isPatient: role === 'patient',
      isProvider: role === 'provider',
      isDriver: role === 'driver',
    };
    
    await admin.auth().setCustomUserClaims(userId, customClaims);
  });
```

### Role Verification ✅

Providers and drivers must be verified by administrators:

```javascript
// Cloud Function to verify special roles
export const verifySpecialRole = functionsV2.https.onCall(async (request) => {
  const updatedClaims = {
    ...currentClaims,
    isVerified: isVerified === true,
    verifiedAt: isVerified === true ? new Date().getTime() : null,
  };
  
  await admin.auth().setCustomUserClaims(userId, updatedClaims);
});
```

### Client-Side Role Checking ✅

The app now checks for custom claims first, then falls back to Firestore:

```dart
// Get user role - first checks custom claims, then falls back to Firestore
Future<UserRole?> getUserRole() async {
  // Force token refresh to get the latest custom claims
  await currentUser!.getIdTokenResult(true);
  
  // Get the ID token result which contains custom claims
  final idTokenResult = await currentUser!.getIdTokenResult();
  final claims = idTokenResult.claims;
  
  // Check if role is in custom claims
  if (claims != null && claims['role'] != null) {
    final roleStr = claims['role'] as String;
    // Return role based on claims
  }
  
  // Fall back to Firestore if needed
}
```

### Authentication Flow ✅

The authentication flow now includes:
- Email verification requirement
- Role verification for providers and drivers
- Appropriate screens for each verification state

### Next Steps

1. Implement feature gating based on verification status
2. Add emergency setup flow
3. Implement usage tracking for AI features
4. Add deposit wallet functionality
