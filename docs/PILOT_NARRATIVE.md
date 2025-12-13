# HeaLyri Emergency Flow: Pilot Narrative

**Purpose:** Document how emergencies are handled today vs. what HeaLyri changes  
**Status:** Ready for Ministry/Facility Presentation  
**Date:** December 2024

---

## Executive Summary

HeaLyri transforms emergency healthcare coordination in Zambia from a **manual, fragmented process** into a **coordinated, auditable, data-driven system**. This document tells the story of one complete emergency—from button press to resolution—with data to prove it.

---

## Part 1: How Emergencies Are Handled Today (Without HeaLyri)

### Current Reality

**Scenario:** A patient in Lusaka experiences a medical emergency.

1. **Patient Action:**
   - Calls emergency services (if they know the number)
   - Or calls family/friends
   - Or goes directly to nearest facility
   - **Problem:** No standardized entry point, no location tracking, no urgency classification

2. **Coordination:**
   - Manual phone calls between patient, facility, and transport
   - No real-time visibility
   - No guarantee of facility capacity
   - **Problem:** Delays, miscommunication, facility overload

3. **Transport:**
   - Patient arranges own transport OR
   - Facility sends ambulance (if available) OR
   - Family/friends transport
   - **Problem:** No tracking, no ETA, no coordination

4. **Facility Arrival:**
   - Patient arrives (or doesn't)
   - Facility may or may not be prepared
   - No prior information about patient condition
   - **Problem:** Unprepared facilities, delayed care

5. **Resolution:**
   - Patient treated (or not)
   - No standardized outcome tracking
   - No data for Ministry reporting
   - **Problem:** No audit trail, no improvement data

### Current Pain Points

- ❌ **No centralized coordination**
- ❌ **No real-time visibility**
- ❌ **No data for Ministry reporting**
- ❌ **No audit trail**
- ❌ **No metrics for improvement**

---

## Part 2: What HeaLyri Changes

### The HeaLyri Emergency Flow

**Same Scenario:** A patient in Lusaka experiences a medical emergency.

#### Step 1: Patient Creates Emergency (Button Press)

**Action:**
- Patient opens HeaLyri app
- Taps "Emergency" button
- Selects urgency level (Critical, High, Medium, Low)
- System captures location automatically

**What Happens Behind the Scenes:**
- Emergency document created in Firestore
- Event logged: `emergencyCreated`
- Location stored as GeoPoint
- Timestamp recorded

**Data Captured:**
```json
{
  "patientId": "user-123",
  "patientName": "John Mwanza",
  "location": { "latitude": -15.3875, "longitude": 28.3228 },
  "urgency": "critical",
  "timestamp": "2024-12-15T10:30:00Z",
  "status": "created"
}
```

**Time:** < 30 seconds

---

#### Step 2: Automatic Dispatch (Cloud Function)

**Action:**
- Cloud Function `onEmergencyCreated` triggers automatically
- Finds nearest facility with `emergencyAcceptanceStatus = 'available'`
- Calculates distance using Haversine formula
- Assigns nearest available driver (if within 50km)

**What Happens Behind the Scenes:**
- Emergency status → `dispatched`
- Facility assigned: `assignedFacilityId`
- Driver assigned: `assignedDriverId` (if available)
- Event logged: `emergencyDispatched`
- Event logged: `driverAssigned` (if driver found)

**Data Captured:**
```json
{
  "status": "dispatched",
  "assignedFacilityId": "facility-456",
  "assignedDriverId": "driver-789",
  "dispatchedAt": "2024-12-15T10:30:15Z"
}
```

**Time:** < 15 seconds (automatic)

---

#### Step 3: Facility Notification & Acknowledgment

**Action:**
- Facility sees emergency in Emergency Dashboard
- Facility coordinator taps "Acknowledge Emergency"
- System updates status

**What Happens Behind the Scenes:**
- Emergency status remains `dispatched`
- `acknowledgedAt` timestamp recorded
- `acknowledgedBy` = facility coordinator ID
- Event logged: `facilityAcknowledged`

**Data Captured:**
```json
{
  "acknowledgedAt": "2024-12-15T10:31:00Z",
  "acknowledgedBy": "provider-abc"
}
```

**Time:** < 2 minutes (manual acknowledgment)

---

#### Step 4: Driver Acceptance & In-Transit

**Action:**
- Driver sees assigned emergency in Driver Dashboard
- Driver taps "Accept Emergency"
- Driver updates status as they travel

**What Happens Behind the Scenes:**
- Emergency status → `inTransit`
- Driver status → `onTrip`
- `inTransitAt` timestamp recorded
- Event logged: `driverAssigned` (acceptance)

**Data Captured:**
```json
{
  "status": "inTransit",
  "inTransitAt": "2024-12-15T10:32:00Z"
}
```

**Time:** < 3 minutes (driver acceptance)

---

#### Step 5: Driver Arrival

**Action:**
- Driver arrives at patient location
- Driver taps "Mark as Arrived"

**What Happens Behind the Scenes:**
- Emergency status → `arrived`
- `arrivedAt` timestamp recorded
- Event logged: `emergencyArrived`

**Data Captured:**
```json
{
  "status": "arrived",
  "arrivedAt": "2024-12-15T10:45:00Z"
}
```

**Time:** 13 minutes from emergency creation

---

#### Step 6: Resolution

**Action:**
- Facility treats patient
- Facility coordinator opens "Resolve Emergency" screen
- Selects outcome: Admitted, Referred, Stabilized, or Deceased
- Adds optional notes
- Taps "Resolve Emergency"

**What Happens Behind the Scenes:**
- Emergency status → `resolved`
- `resolvedAt` timestamp recorded
- `resolutionOutcome` = selected outcome
- Driver released (status → `available`)
- Event logged: `emergencyResolved`

**Data Captured:**
```json
{
  "status": "resolved",
  "resolvedAt": "2024-12-15T11:30:00Z",
  "resolutionOutcome": "admitted",
  "resolutionNotes": "Patient admitted to ICU"
}
```

**Time:** 60 minutes from emergency creation (total)

---

## Part 3: The Data Story (What We Can Prove)

### Complete Event Timeline

For every emergency, we have a complete, immutable audit trail:

```
10:30:00 - emergencyCreated
10:30:15 - emergencyDispatched (facility-456)
10:30:20 - driverAssigned (driver-789)
10:31:00 - facilityAcknowledged (provider-abc)
10:32:00 - driverAssigned (acceptance by driver-789)
10:45:00 - emergencyArrived
11:30:00 - emergencyResolved (outcome: admitted)
```

### Response Metrics (Calculated Automatically)

- **Time to Dispatch:** 15 seconds
- **Time to Arrival:** 15 minutes (from creation)
- **Time to Resolution:** 60 minutes (from creation)
- **Driver Response Time:** 13 minutes (from acceptance to arrival)

### Ministry-Ready Data

Every emergency produces:
- ✅ Standardized timestamps
- ✅ Clear resolution outcomes
- ✅ Location accuracy (GeoPoint)
- ✅ Facility response times
- ✅ Driver acceptance times
- ✅ Complete audit trail

---

## Part 4: What This Enables

### For Patients

- **Transparency:** See exactly where help is
- **Confidence:** Know someone is responding
- **Speed:** Automatic dispatch (no phone calls)

### For Facilities

- **Visibility:** See all incoming emergencies
- **Coordination:** Know when transport is arriving
- **Capacity Management:** Track response times

### For Ministry of Health

- **Data:** Standardized emergency response data
- **Metrics:** Response time analytics
- **Audit Trail:** Complete record for every emergency
- **Improvement:** Data-driven optimization

### For Drivers

- **Clear Assignments:** See exactly where to go
- **Status Updates:** Easy status management
- **Release:** Automatic release after resolution

---

## Part 5: The Infrastructure Question

> **"If HeaLyri disappeared tomorrow, would users and facilities feel a real loss?"**

**Answer: Yes.**

Because:
- Facilities rely on it for emergency coordination
- Patients trust it for emergency response
- Ministry uses it for data reporting
- Drivers depend on it for assignments

**This is infrastructure, not just an app.**

---

## Part 6: Pilot Scope

### Initial Deployment

- **Location:** Lusaka (pilot area)
- **Facilities:** 3-5 facilities
- **Drivers:** 5-10 drivers (can be informal initially)
- **Duration:** 4 weeks

### Success Criteria

- ✅ Complete emergency flow works end-to-end
- ✅ All events logged
- ✅ Metrics visible
- ✅ At least 10 resolved emergencies with data

### Next Steps

- Expand to more facilities
- Add automated notifications (push/SMS)
- Integrate with Ministry systems
- Add real-time location tracking

---

## Conclusion

HeaLyri transforms emergency healthcare from **chaos** to **coordination**, from **manual** to **automated**, from **invisible** to **auditable**.

**One emergency. Complete data. Full story.**

This is what infrastructure looks like.

---

**Ready for Ministry Presentation:** ✅  
**Ready for Facility Demo:** ✅  
**Ready for Pilot:** ✅

