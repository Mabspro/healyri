# Seed Data Guide

**Last Updated:** December 2024

---

## Overview

This guide explains how to populate Firestore with initial facility data for HeaLyri. The seed script creates 5 verified facilities in the Lusaka area with complete data including coordinates, services, and operating hours.

---

## Prerequisites

1. **Firebase Project:** `healyri-af36a`
2. **Service Account Key:** `healyri-af36a-firebase-adminsdk-fbsvc-ea3b7a38c5.json` (already in project root)
3. **Node.js:** Installed and available in PATH
4. **Firebase Admin SDK:** Will be installed automatically

---

## Setup Steps

### 1. Install Dependencies

The seed script requires `firebase-admin`. Install it in the scripts directory:

```bash
cd scripts
npm install firebase-admin
```

### 2. Update Seed Script Path

The seed script references `../serviceAccountKey.json`, but our file is named `healyri-af36a-firebase-adminsdk-fbsvc-ea3b7a38c5.json`.

**Option A: Create a symlink or copy (Recommended)**
```bash
# From project root
cp healyri-af36a-firebase-adminsdk-fbsvc-ea3b7a38c5.json scripts/serviceAccountKey.json
```

**Option B: Update the script to use the correct filename**

### 3. Run the Seed Script

```bash
# From project root
node scripts/seed_facilities.js
```

**Expected Output:**
```
Starting facility seed...
✓ Seeded facility: Lusaka General Hospital
✓ Seeded facility: University Teaching Hospital
✓ Seeded facility: Kanyama Clinic
✓ Seeded facility: MedPlus Pharmacy
✓ Seeded facility: Lusaka Medical Center

✅ Successfully seeded 5 facilities
```

---

## Facilities Being Seeded

1. **Lusaka General Hospital**
   - Type: Hospital
   - Location: Independence Ave, Lusaka
   - Services: Emergency, Surgery, Pediatrics, Maternity, Cardiology
   - NHIMA: Accepted
   - Operating: 24/7

2. **University Teaching Hospital**
   - Type: Hospital
   - Location: Nationalist Road, Lusaka
   - Services: Emergency, Surgery, Oncology, Cardiology, Neurology, Trauma
   - NHIMA: Accepted
   - Operating: 24/7

3. **Kanyama Clinic**
   - Type: Clinic
   - Location: Kanyama Road, Lusaka
   - Services: General Medicine, Vaccinations, HIV Testing, Maternal Health, Child Health
   - NHIMA: Accepted
   - Operating: Mon-Fri 08:00-17:00, Sat 09:00-13:00

4. **MedPlus Pharmacy**
   - Type: Pharmacy
   - Location: Cairo Road, Lusaka
   - Services: Prescription Filling, Health Consultations, Medical Supplies, Vaccinations
   - NHIMA: Not Accepted
   - Operating: Mon-Fri 08:00-18:00, Sat 09:00-16:00, Sun 10:00-14:00

5. **Lusaka Medical Center**
   - Type: Hospital
   - Location: Great East Road, Lusaka
   - Services: Emergency, General Medicine, Surgery, Pediatrics, Maternity
   - NHIMA: Accepted
   - Operating: 24/7

---

## Verification

After running the seed script:

1. **Firebase Console:**
   - Go to: https://console.firebase.google.com/project/healyri-af36a/firestore
   - Navigate to `facilities` collection
   - Verify 5 documents exist
   - Check that each has:
     - `isVerified: true`
     - Valid `location` (GeoPoint)
     - `services` array
     - `operatingHours` object

2. **App Verification:**
   - Open the app
   - Navigate to "Facilities" tab
   - Verify facilities appear in the list
   - Check that distances calculate correctly
   - Verify NHIMA badges appear on accepted facilities

---

## Troubleshooting

### Error: "Cannot find module 'firebase-admin'"
**Solution:** Run `npm install firebase-admin` in the `scripts` directory

### Error: "serviceAccountKey.json not found"
**Solution:** Copy the service account file to `scripts/serviceAccountKey.json` or update the script path

### Error: "Permission denied"
**Solution:** Ensure the service account has Firestore write permissions in Firebase Console

### Facilities don't appear in app
**Solution:**
- Check Firestore rules allow read access to `facilities` collection
- Verify `isVerified: true` is set (app filters for verified facilities)
- Check app is using correct Firebase project

---

## Next Steps

After seeding:
- Test facility search and filtering
- Verify distance calculations work
- Test emergency dispatch with real facilities
- Add more facilities as needed

---

## Security Notes

- **Never commit** `serviceAccountKey.json` to Git
- The file is already in `.gitignore`
- Use the same service account file that's configured for GitHub Actions
- Rotate keys if exposed

---

**Related Documentation:**
- `docs/FIREBASE_SECRET_SETUP.md` - Service account setup
- `docs/PLATFORM_REVIEW.md` - Facility model details
- `scripts/seed_facilities.js` - Seed script source

