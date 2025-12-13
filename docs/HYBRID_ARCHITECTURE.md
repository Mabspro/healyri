# HeaLyri: Hybrid State + Event Architecture

**Purpose:** Formalize the hybrid architecture for healthcare-grade auditability and trust  
**Status:** Implementation Ready

---

## Architecture Overview

HeaLyri uses a **Hybrid State + Event Architecture**:

- **State Collections:** Current snapshot of entities (users, facilities, emergencies)
- **Event Collections:** Append-only log of all actions (audit trail)

**Why This Matters:**
- ✅ Enables auditability
- ✅ Enables post-incident review
- ✅ Enables Ministry reporting
- ✅ Enables future ML/triage improvements
- ✅ Enables trust

**This is not premature architecture — this is healthcare-grade architecture.**

---

## State Collections (Current Snapshot)

### Users
```javascript
users/{userId}
  - name: string
  - email: string
  - role: "patient" | "provider" | "driver" | "admin"
  - phoneNumber: string
  - location: geopoint (last known)
  - isVerified: boolean
  - createdAt: timestamp
  - updatedAt: timestamp
```

### Facilities
```javascript
facilities/{facilityId}
  - name: string
  - type: "hospital" | "clinic" | "pharmacy"
  - location: geopoint
  - address: map
  - contactPhone: string
  - emergencyAcceptanceStatus: "available" | "limited" | "unavailable"
  - currentCapacity: number
  - maxCapacity: number
  - isVerified: boolean
  - createdAt: timestamp
  - updatedAt: timestamp
```

### Drivers
```javascript
drivers/{driverId}
  - userId: string (reference to users)
  - vehicleType: string
  - vehicleNumber: string
  - status: "available" | "on-trip" | "offline"
  - currentLocation: geopoint
  - isVerified: boolean
  - createdAt: timestamp
  - updatedAt: timestamp
```

### Emergencies (State)
```javascript
emergencies/{emergencyId}
  - patientId: string
  - location: geopoint
  - urgency: "low" | "medium" | "high" | "critical"
  - status: "active" | "dispatched" | "in-transit" | "arrived" | "resolved"
  - facilityId: string (assigned)
  - driverId: string (assigned, optional)
  - createdAt: timestamp
  - dispatchedAt: timestamp
  - acknowledgedAt: timestamp
  - resolvedAt: timestamp
  - resolutionOutcome: "treated" | "transferred" | "declined" | "cancelled"
  - notes: string
```

### Appointments
```javascript
appointments/{appointmentId}
  - patientId: string
  - facilityId: string
  - providerId: string (optional)
  - dateTime: timestamp
  - status: "pending" | "confirmed" | "completed" | "cancelled" | "no-show"
  - createdAt: timestamp
  - updatedAt: timestamp
```

---

## Event Collections (Append-Only)

### Events (Master Log)
```javascript
events/{eventId}
  - type: string (event type)
  - emergencyId: string (if emergency-related)
  - userId: string (who triggered)
  - timestamp: timestamp
  - data: map (event-specific data)
  - metadata: map (system metadata)
```

### Event Types

#### Emergency Events
```javascript
// Emergency Created
{
  type: "emergency_created",
  emergencyId: "...",
  userId: "...",
  timestamp: timestamp,
  data: {
    location: geopoint,
    urgency: "critical",
    patientId: "..."
  }
}

// Emergency Routed
{
  type: "emergency_routed",
  emergencyId: "...",
  userId: "system",
  timestamp: timestamp,
  data: {
    facilityId: "...",
    routingReason: "nearest_available"
  }
}

// Driver Assigned
{
  type: "driver_assigned",
  emergencyId: "...",
  userId: "system" | "...",
  timestamp: timestamp,
  data: {
    driverId: "...",
    assignmentMethod: "automatic" | "manual",
    estimatedArrival: timestamp
  }
}

// Facility Acknowledged
{
  type: "facility_acknowledged",
  emergencyId: "...",
  userId: "...", // facility coordinator
  timestamp: timestamp,
  data: {
    facilityId: "...",
    acknowledgmentTime: timestamp,
    capacityReserved: boolean
  }
}

// Driver Status Update
{
  type: "driver_status_update",
  emergencyId: "...",
  userId: "...", // driver
  timestamp: timestamp,
  data: {
    status: "en_route" | "arrived" | "picked_up",
    location: geopoint,
    eta: timestamp
  }
}

// Emergency Resolved
{
  type: "emergency_resolved",
  emergencyId: "...",
  userId: "...", // facility coordinator
  timestamp: timestamp,
  data: {
    resolutionOutcome: "treated" | "transferred" | "declined",
    resolutionTime: timestamp,
    facilityResponseTime: number (seconds),
    driverResponseTime: number (seconds),
    totalResponseTime: number (seconds)
  }
}
```

#### Appointment Events
```javascript
// Appointment Created
{
  type: "appointment_created",
  appointmentId: "...",
  userId: "...",
  timestamp: timestamp,
  data: { ... }
}

// Appointment Confirmed
{
  type: "appointment_confirmed",
  appointmentId: "...",
  userId: "...",
  timestamp: timestamp,
  data: { ... }
}

// Appointment Cancelled
{
  type: "appointment_cancelled",
  appointmentId: "...",
  userId: "...",
  timestamp: timestamp,
  data: {
    reason: string,
    cancelledBy: "patient" | "provider" | "system"
  }
}
```

---

## Implementation Pattern

### Creating an Emergency

```dart
// 1. Create state document
final emergency = await emergencyService.createEmergency(
  patientId: userId,
  location: currentLocation,
  urgency: 'critical',
);

// 2. Log event (append-only)
await eventService.logEvent(
  type: 'emergency_created',
  emergencyId: emergency.id,
  userId: userId,
  data: {
    'location': currentLocation,
    'urgency': 'critical',
  },
);
```

### Updating Emergency Status

```dart
// 1. Update state document
await emergencyService.updateStatus(
  emergencyId: emergencyId,
  status: 'dispatched',
  facilityId: facilityId,
);

// 2. Log event
await eventService.logEvent(
  type: 'emergency_routed',
  emergencyId: emergencyId,
  userId: 'system',
  data: {
    'facilityId': facilityId,
    'routingReason': 'nearest_available',
  },
);
```

### Querying Events

```dart
// Get all events for an emergency (audit trail)
final events = await eventService.getEventsByEmergency(emergencyId);

// Get events by type
final emergencyEvents = await eventService.getEventsByType('emergency_created');

// Get events by time range (for Ministry reporting)
final recentEvents = await eventService.getEventsByTimeRange(
  startTime: startDate,
  endTime: endDate,
);
```

---

## Security Rules

### Events Collection (Append-Only)

```javascript
match /events/{eventId} {
  // Anyone can read events (for audit trail)
  allow read: if true;
  
  // Only system can create events (via Cloud Functions)
  allow create: if false; // Only Cloud Functions
  
  // Events are immutable (no updates/deletes)
  allow update, delete: if false;
}
```

### Emergencies Collection

```javascript
match /emergencies/{emergencyId} {
  // Patient can read their own emergencies
  allow read: if isAuthenticated() && 
    (resource.data.patientId == request.auth.uid || 
     hasRole('admin') || 
     hasRole('provider'));
  
  // Patient can create emergency
  allow create: if isAuthenticated() && 
    request.resource.data.patientId == request.auth.uid;
  
  // System and admins can update
  allow update: if isAuthenticated() && 
    (hasRole('admin') || 
     request.resource.data.status == resource.data.status || // Status changes via Cloud Functions
     resource.data.facilityId in getFacilityAdminIds());
  
  // No deletes (only mark as resolved)
  allow delete: if false;
}
```

---

## Ministry-Ready Data Format

### Emergency Report (Export Format)

```json
{
  "emergencyId": "...",
  "patientId": "...", // Anonymized for export
  "location": {
    "latitude": 0.0,
    "longitude": 0.0,
    "accuracy": "high" | "medium" | "low"
  },
  "urgency": "critical",
  "timeline": {
    "createdAt": "2024-12-01T10:00:00Z",
    "dispatchedAt": "2024-12-01T10:02:00Z",
    "acknowledgedAt": "2024-12-01T10:05:00Z",
    "arrivedAt": "2024-12-01T10:15:00Z",
    "resolvedAt": "2024-12-01T11:00:00Z"
  },
  "responseTimes": {
    "dispatchTime": 120, // seconds
    "facilityResponseTime": 180, // seconds
    "driverResponseTime": 600, // seconds
    "totalResponseTime": 3600 // seconds
  },
  "facility": {
    "facilityId": "...",
    "name": "...",
    "type": "hospital"
  },
  "driver": {
    "driverId": "...",
    "vehicleType": "..."
  },
  "resolution": {
    "outcome": "treated",
    "notes": "..."
  }
}
```

### Aggregate Statistics (Ministry Dashboard)

```json
{
  "period": {
    "start": "2024-12-01T00:00:00Z",
    "end": "2024-12-31T23:59:59Z"
  },
  "totals": {
    "emergencies": 150,
    "resolved": 145,
    "averageResponseTime": 1800, // seconds
    "facilitiesInvolved": 12,
    "driversInvolved": 25
  },
  "byUrgency": {
    "critical": 50,
    "high": 60,
    "medium": 30,
    "low": 10
  },
  "byOutcome": {
    "treated": 120,
    "transferred": 20,
    "declined": 5
  }
}
```

---

## Implementation Checklist

### Week 1
- [ ] Create `events` collection schema
- [ ] Create `EventService` with append-only logging
- [ ] Update Firestore security rules for events
- [ ] Log first event (emergency_created)

### Week 2
- [ ] Implement all emergency event types
- [ ] Add event logging to all emergency state changes
- [ ] Create event query methods

### Week 3
- [ ] Add appointment event types
- [ ] Implement event aggregation queries
- [ ] Create event export format

### Week 4
- [ ] Generate Ministry-ready reports
- [ ] Test event audit trail completeness
- [ ] Document event schema

---

## Benefits of This Architecture

### For Development
- Clear separation of concerns
- Easy to debug (full event log)
- Testable (events are deterministic)

### For Operations
- Complete audit trail
- Post-incident review capability
- Performance metrics

### For Ministry
- Standardized data format
- Compliance-ready
- Public health insights

### For Trust
- Transparent operations
- Accountability
- Data integrity

---

**Last Updated:** December 2024  
**Status:** Ready for Implementation

