# Patient Dashboard Refactor - Real Data Integration

## Summary

The Patient Dashboard (`lib/home/home_screen.dart`) has been refactored to use real Firestore data instead of hardcoded mock data. This aligns with the strategic focus on building a reliable, data-driven platform.

## Changes Made

### 1. Created New Models & Services

#### `lib/models/appointment.dart`
- Full `Appointment` model with Firestore serialization
- `AppointmentStatus` enum (pending, confirmed, completed, cancelled, noShow)
- Handles both Timestamp and ISO8601 string formats for dates

#### `lib/services/appointment_service.dart`
- `getUpcomingAppointment()` - Gets next appointment for current user
- `streamUpcomingAppointment()` - Real-time stream of next appointment
- `getUserAppointments()` - Stream of all user appointments
- `createAppointment()` - Create new appointments
- Handles index errors gracefully with helpful logging

#### `lib/services/health_vitals_service.dart`
- `HealthVitals` model (heartRate, steps, sleepHours)
- `getLatestVitals()` - Fetch latest vitals from `users/{uid}/vitals/latest`
- `streamLatestVitals()` - Real-time stream of health vitals

### 2. Refactored Home Screen

#### User Name (`_buildAppBar`)
- ✅ Fetches from `users/{uid}` document, field `name`
- ✅ Falls back to Firebase Auth `displayName`
- ✅ Uses StreamBuilder for real-time updates
- ✅ Shows user photo if available

#### Health Status Card (`_buildHealthStatusCard`)
- ✅ Fetches from `users/{uid}/vitals/latest`
- ✅ Displays: Heart Rate (bpm), Steps (formatted with commas), Sleep (hours)
- ✅ Shows "--" if data doesn't exist
- ✅ Real-time updates via StreamBuilder

#### Upcoming Appointment (`_buildUpcomingAppointment`)
- ✅ Queries `appointments` collection:
  - Filter: `patientId == currentUser.uid`
  - Filter: `dateTime > Now`
  - Filter: `status IN ['pending', 'confirmed']`
  - OrderBy: `dateTime` ASC
  - Limit: 1
- ✅ Shows loading spinner while fetching
- ✅ Shows empty state with "Book Appointment" button if no appointments
- ✅ Displays real appointment data when available
- ✅ Real-time updates via StreamBuilder

## Firestore Schema Requirements

### Appointments Collection
```
appointments/{appointmentId}
  - patientId: string
  - patientName: string (optional)
  - facilityId: string
  - facilityName: string
  - providerId: string (optional)
  - providerName: string (optional)
  - serviceType: string (optional)
  - dateTime: timestamp
  - duration: number (optional, minutes)
  - status: string ("pending" | "confirmed" | "completed" | "cancelled" | "no-show")
  - notes: string (optional)
  - createdAt: timestamp (optional)
  - updatedAt: timestamp (optional)
```

### Health Vitals Subcollection
```
users/{uid}/vitals/latest
  - heartRate: number (optional, bpm)
  - steps: number (optional)
  - sleepHours: number (optional)
  - lastUpdated: timestamp (optional)
```

### Users Collection
```
users/{uid}
  - name: string
  - email: string
  - role: string
  - createdAt: string (ISO8601)
  - isVerified: boolean
```

## Required Firestore Indexes

### Composite Index for Appointments Query

**Collection:** `appointments`

**Fields:**
1. `patientId` (Ascending)
2. `dateTime` (Ascending)
3. `status` (Ascending)

**Purpose:** Efficiently query upcoming appointments for a patient

**How to Create:**
1. Go to Firebase Console → Firestore → Indexes
2. Click "Create Index"
3. Collection ID: `appointments`
4. Add fields in order:
   - `patientId` (Ascending)
   - `dateTime` (Ascending)
   - `status` (Ascending)
5. Click "Create"

**OR** add to `firestore.indexes.json`:
```json
{
  "indexes": [
    {
      "collectionGroup": "appointments",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "patientId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "dateTime",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        }
      ]
    }
  ]
}
```

## Error Handling

### Index Missing Error
If the composite index is not created, the app will:
- Log a warning: `⚠️ Firestore index may be missing...`
- Return `null` for upcoming appointment (shows empty state)
- **Does not crash** - graceful degradation

### Missing Data
- **No user name:** Falls back to Firebase Auth `displayName` or "User"
- **No health vitals:** Shows "--" for all metrics
- **No appointments:** Shows empty state with "Book Appointment" button

### Network Issues
- StreamBuilders handle connection state automatically
- Shows loading states while fetching
- Gracefully handles offline scenarios (if Firestore persistence enabled)

## Testing Checklist

### Manual Verification

1. **User Name:**
   - [ ] Sign in as a Patient
   - [ ] Verify dashboard displays correct name from Firestore
   - [ ] Verify photo displays if available

2. **Appointments:**
   - [ ] Verify "No upcoming appointments" shows when none exist
   - [ ] Create a test appointment in Firestore
   - [ ] Verify appointment appears on dashboard
   - [ ] Verify appointment details are correct (facility, provider, date/time)

3. **Health Vitals:**
   - [ ] Verify "--" shows when no vitals exist
   - [ ] Create test vitals document at `users/{uid}/vitals/latest`
   - [ ] Verify vitals display correctly (heartRate, steps, sleepHours)

4. **Loading States:**
   - [ ] Verify loading spinner appears while fetching appointment
   - [ ] Verify smooth transitions when data loads

5. **Real-time Updates:**
   - [ ] Open dashboard
   - [ ] Create/update appointment in Firestore Console
   - [ ] Verify dashboard updates automatically

## Next Steps

1. **Create Firestore Index** (see above)
2. **Seed Test Data:**
   - Create test appointments for testing
   - Create test health vitals documents
3. **Update Booking Screen:**
   - Refactor `lib/booking/booking_screen.dart` to use `AppointmentService`
   - Remove duplicate `Appointment` model from booking_screen.dart
4. **Provider Dashboard:**
   - Similar refactor for `lib/provider/provider_home_screen.dart`
   - Use real appointment data for providers

## Notes

- The dashboard now uses **real-time streams** for all data
- All data fetching is **non-blocking** with proper loading states
- **Graceful degradation** - app works even if data doesn't exist
- **Error handling** is built-in at the service layer
- **No breaking changes** - existing UI components still work

---

**Status:** ✅ Complete - Dashboard now uses real Firestore data

