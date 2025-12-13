# Week 2: Dispatch & Acknowledgment - Setup Guide

**Status:** ✅ Implementation Complete  
**Gate:** Week 2 Definition of Done

---

## What Was Built

### 1. Cloud Function: Emergency Dispatch
- **File:** `functions/src/index.ts`
- **Function:** `onEmergencyCreated`
- **Trigger:** Automatically fires when emergency document is created
- **Logic:**
  - Finds nearest facility with `emergencyAcceptanceStatus = 'available'`
  - Falls back to any facility if none available (for pilot)
  - Calculates distance using Haversine formula
  - Updates emergency status to `dispatched`
  - Assigns facility ID
  - Logs dispatch event

### 2. Facility Service
- **File:** `lib/services/facility_service.dart`
- **Features:**
  - Get emergencies assigned to facility
  - Acknowledge emergency
  - Get facility ID for current user

### 3. Facility Dashboard
- **File:** `lib/provider/emergency_dashboard_screen.dart`
- **Features:**
  - View all emergencies assigned to facility
  - See emergency details (urgency, status, patient info)
  - Acknowledge emergencies
  - Real-time updates via StreamBuilder

### 4. Patient UI Updates
- **File:** `lib/emergency/emergency_screen.dart`
- **Features:**
  - Shows "Emergency Received" banner
  - Shows "Facility Notified" banner
  - Real-time status updates
  - Visual status indicators

---

## Required Setup

### 1. Deploy Cloud Function

```bash
cd functions
npm install
npm run build
firebase deploy --only functions:onEmergencyCreated
```

### 2. Update Facilities in Firestore

For facilities to receive emergencies, they need:
- `location` (GeoPoint) - Required for distance calculation
- `emergencyAcceptanceStatus` - Set to `'available'` to receive emergencies

**Example Facility Document:**
```json
{
  "name": "Lusaka General Hospital",
  "type": "hospital",
  "location": {
    "latitude": -15.3875,
    "longitude": 28.3228
  },
  "emergencyAcceptanceStatus": "available",
  "address": {
    "street": "123 Independence Ave",
    "city": "Lusaka",
    "province": "Lusaka Province"
  },
  "contactPhone": "+260 211 123456"
}
```

### 3. Link Provider Users to Facilities

Provider users need `facilityIds` array in their user document:

```json
{
  "name": "Dr. Mulenga",
  "email": "doctor@example.com",
  "role": "provider",
  "facilityIds": ["facility-id-here"]
}
```

---

## Testing the Flow

### As Patient:
1. Create emergency → See "Emergency Received"
2. Wait for dispatch → See "Facility Notified"
3. Status updates in real-time

### As Provider:
1. Open Emergency Dashboard from provider home
2. See assigned emergencies
3. Click "Acknowledge Emergency"
4. Patient sees acknowledgment

---

## Gate 2: Definition of Done

✅ **A second human (facility or operator) acknowledges the emergency, and that acknowledgment is visible to the patient.**

**To Verify:**
1. Create emergency as patient
2. Open provider dashboard
3. Acknowledge emergency
4. Patient UI shows acknowledgment

---

**Next:** Week 3 - Transport & Real-Time Status

