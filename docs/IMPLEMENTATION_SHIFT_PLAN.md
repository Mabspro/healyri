# HeaLyri Implementation Shift Plan

**Date:** December 2024  
**Status:** Ready to Execute  
**Based On:** 
- [Emergency-Direction-Shift-UI-UX.md](Emergency-Direction-Shift-UI-UX.md)
- [Emergency_Cordination_Infrastructure.md](Emergency_Cordination_Infrastructure.md)

---

## Executive Summary

HeaLyri is shifting from a multi-feature healthcare app to an **Emergency Coordination Platform**. This document outlines the careful, phased implementation of this shift.

**Core Principle:** Convert "panic" into "visible commitment + coordinated action"

---

## Current State Assessment

### ✅ What Exists (Good Foundation)

**Backend:**
- ✅ Emergency models (`Emergency`, `EmergencyStatus`, `EmergencyUrgency`)
- ✅ Emergency service (`EmergencyService`) with create, update, stream
- ✅ Event service (`EventService`) for audit trail
- ✅ Location service (`LocationService`)
- ✅ Cloud Functions for dispatch (`onEmergencyCreated`)
- ✅ Firestore collections (`emergencies`, `events`)

**UI:**
- ✅ Emergency screen (`EmergencyScreen`) - basic trigger and status view
- ✅ Patient dashboard (`HomeScreen`) - has emergency button
- ✅ Driver dashboard (`DriverHomeScreen`) - basic structure
- ✅ Provider dashboard (`ProviderHomeScreen`) - basic structure
- ✅ Emergency dashboard for providers (`EmergencyDashboardScreen`)
- ✅ Driver trip screen (`EmergencyTripScreen`)

### ⚠️ What Needs Enhancement

**Patient Experience:**
- Emergency not dominant on dashboard
- No commitment view (immediate reassurance)
- No timeline component
- No trust signals (verified responders/facilities)
- No fallback call/SMS buttons
- Missing quick chips for emergency type

**Driver Experience:**
- Not focused on emergency dispatch
- No incoming request cards
- No accept/decline workflow
- Not "Responder Console" mindset

**Facility Experience:**
- Not focused on receiving emergencies
- No readiness toggle
- Not "Receiving Center" mindset

**General:**
- Non-emergency features still prominent (Telehealth, AI Triage, Med Verification)
- Landing page doesn't reflect emergency coordination focus

---

## Implementation Phases

### Phase 1: Patient Emergency Experience (Week 1)

**Goal:** Make emergency the dominant, trusted action

#### 1.1 Enhance Emergency Screen

**Current:** Basic urgency selection → create → status view

**Target:**
- Quick chips for emergency type (Accident, Breathing, Pregnancy, etc.)
- Location confirmation with "adjust pin"
- "Can you talk?" Yes/No
- "How many people affected?" (1 / 2-5 / 6+)
- **Commitment View** (immediate post-trigger):
  - Status: "Request received"
  - Timer: "Elapsed 00:17"
  - Next step: "Assigning nearest responder..."
  - Fallback: "Call Dispatch" + "SMS Backup"
- **Timeline Component:**
  - Received → Assigned → En route → Arrived → Departed → Arrived facility → Resolved
- **Trust Signals:**
  - Responder card (name, photo, vehicle, verified badge, ETA, call button)
  - Facility card (name, distance, readiness indicator)
- **Safety Microcopy:**
  - "If you are in immediate danger, move to safety if possible."
  - "Keep phone charged; we'll update you in real time."

#### 1.2 Transform Patient Dashboard

**Current:** Emergency button in drawer, mixed with other features

**Target:**
- **Top Section:** "Emergency Status" (if active) or "Emergency Help" (if none)
  - Persistent Emergency FAB
  - Emergency banner: "Need urgent help?"
- **Secondary:** Nearby facilities (3 cards)
- **Tertiary:** "My Coverage" (subscription status)
- **Hidden/Moved:** Telehealth, AI Triage, Med Verification → "Explore" or "Coming soon"

**Dashboard Modules (MVP):**
1. Emergency CTA / active emergency tracker
2. Nearby facilities (3 cards)
3. "My Coverage" (subscription status / employer plan)
4. Profile completeness + trusted contacts

---

### Phase 2: Responder Console (Week 2)

**Goal:** Transform driver dashboard into emergency dispatch interface

#### 2.1 Driver Dashboard Transformation

**Current:** General driver dashboard with earnings, history

**Target:**
- **Primary View:** Active dispatch requests
- **Incoming Request Card:**
  - Emergency details (location, urgency, patient info)
  - Accept/Decline buttons
  - Distance/ETA
- **Active Case View:**
  - Navigate button
  - Call patient button
  - Update Status buttons (On route, Arrived, Transporting, Completed)
- **Status Indicators:**
  - Available / Busy / Offline
  - On route / Arrived / Transporting / Completed

**Driver Modules (MVP):**
1. Incoming request card (Accept/Decline)
2. Active case view (Navigate, Call, Update Status)
3. Training + compliance badge
4. Earnings/credits (optional; show "Activity Summary" even if zero)

---

### Phase 3: Receiving Center (Week 2-3)

**Goal:** Transform facility dashboard into emergency receiving interface

#### 3.1 Facility Dashboard Transformation

**Current:** General provider dashboard with appointments

**Target:**
- **Primary View:** Incoming emergency alerts
- **Incoming Emergency List:**
  - Emergency details (patient, location, urgency, ETA)
  - Accept/Decline buttons
  - Current incoming patient view (ETA, triage)
- **Facility Readiness Toggle:**
  - Simple: "Accepting Emergencies ON/OFF"
- **Case Outcomes:**
  - Outcome reporting after arrival
  - Notes field

**Facility Modules (MVP):**
1. Incoming emergency alert list
2. Current incoming patient view (ETA, triage)
3. Facility readiness toggle (Accepting Emergencies ON/OFF)
4. Case outcomes + notes

---

### Phase 4: UI Component Library (Week 3)

**Goal:** Create reusable components for emergency flows

#### Components to Build:

1. **EmergencyStatusChip**
   - Status: Received / Assigned / En route / Arrived / Resolved
   - Color-coded, consistent styling

2. **TimelineWidget**
   - Visual timeline of emergency stages
   - Shows completed vs pending stages
   - Timestamps for each stage

3. **ResponderCard**
   - Name + photo (or avatar)
   - Vehicle type (taxi/bike/ambulance/tri-wheel)
   - Verified badge
   - ETA
   - Call button

4. **FacilityCard**
   - Facility name
   - Distance
   - Readiness indicator
   - Contact button

5. **FallbackButtons**
   - "Call Dispatch" (always prominent)
   - "SMS Backup" (if enabled)

---

### Phase 5: Feature Freeze & Navigation (Week 3-4)

**Goal:** Hide non-emergency features, update navigation

#### 5.1 Feature Freeze

**Move to "Explore" or "Coming Soon":**
- Telehealth
- AI Triage
- Medication Verification
- Complex appointment booking

**Keep Active:**
- Emergency (dominant)
- Facilities directory
- Basic appointments
- Profile

#### 5.2 Navigation Updates

**Global Navigation (MVP):**
- Home (Role dashboard)
- Emergency (persistent CTA / dedicated screen)
- Facilities
- Profile

**Rule:** Do NOT bury emergency in a menu. It is a persistent CTA (FAB + top banner option).

---

### Phase 6: Landing Page Alignment (Week 4)

**Goal:** Match landing page to emergency coordination focus

#### Landing Page Hierarchy:

1. **Hero:**
   - "Emergency response coordination for Zambia — from hours to minutes."
   - Subhead: "Dispatch + community responders + facilities — connected."
   - Primary CTA: "Join coverage" or "Pilot with us"
   - Secondary CTAs: "For Facilities" / "For Employers" / "For Government"

2. **How it Works (3 steps):**
   - Trigger → Dispatch → Help arrives → Facility ready

3. **Trust & Accountability:**
   - Verified responders
   - Facility network
   - Audit trail + response time tracking

4. **Who It's For:**
   - Families (subscription)
   - Employers (coverage benefit)
   - Facilities (incoming referrals)
   - Government (coordination layer)

5. **Pilot Program:**
   - Lusaka / Copperbelt focus
   - "We're onboarding drivers + facilities"

6. **FAQ:**
   - Offline support (hotline, SMS)
   - Pricing concept
   - Safety and verification

**Remove/De-emphasize:**
- Telehealth marketing
- AI triage marketing
- Medication verification marketing
- (Keep as "Coming later")

---

## Implementation Checklist

### Week 1: Patient Emergency Experience
- [ ] Enhance `EmergencyScreen` with quick chips, location confirmation
- [ ] Add commitment view (immediate reassurance)
- [ ] Add timeline component
- [ ] Add responder card with trust signals
- [ ] Add facility card
- [ ] Add fallback call/SMS buttons
- [ ] Transform `HomeScreen` - make emergency dominant
- [ ] Add persistent Emergency FAB
- [ ] Add emergency status banner

### Week 2: Responder & Facility Transformation
- [ ] Transform `DriverHomeScreen` to Responder Console
- [ ] Add incoming request cards
- [ ] Add accept/decline workflow
- [ ] Add active case view with status updates
- [ ] Transform `ProviderHomeScreen` to Receiving Center
- [ ] Add incoming emergency alerts
- [ ] Add facility readiness toggle
- [ ] Add case outcomes reporting

### Week 3: Components & Freeze
- [ ] Create `EmergencyStatusChip` component
- [ ] Create `TimelineWidget` component
- [ ] Create `ResponderCard` component
- [ ] Create `FacilityCard` component
- [ ] Create `FallbackButtons` component
- [ ] Move non-emergency features to "Explore" or hide
- [ ] Update global navigation

### Week 4: Landing Page & Polish
- [ ] Update landing page hero section
- [ ] Add "How it Works" section
- [ ] Add trust & accountability section
- [ ] Add "Who It's For" section
- [ ] Add pilot program section
- [ ] Update FAQ
- [ ] Remove/de-emphasize non-emergency marketing

---

## Acceptance Criteria

### Emergency Flow is "Done" When:
- ✅ Patient can trigger emergency in <10 seconds
- ✅ Patient sees "request received" within 1 second of submit
- ✅ Responder can be assigned and see case
- ✅ Facility receives alert
- ✅ Status updates propagate to patient view
- ✅ Fallback call works at all steps
- ✅ A complete case timeline is visible after resolution

### Dashboards are "Done" When:
- ✅ Each role sees only what they need to execute the wedge
- ✅ No role requires navigating deep menus during emergency operations
- ✅ Emergency is always visible and accessible

### Landing Page is "Done" When:
- ✅ The first 10 seconds communicates emergency coordination clearly
- ✅ CTAs map to stakeholder types (family/employer/facility/government)
- ✅ "Super app" messaging is not dominant

---

## Next Steps

1. **Start with Phase 1.1:** Enhance Emergency Screen
2. **Then Phase 1.2:** Transform Patient Dashboard
3. **Continue through phases** systematically
4. **Test each phase** before moving to next

---

## Implementation Status

### ✅ Completed Phases

**Day 0.5: State Machine Contract** ✅
- Canonical timestamps wired in Emergency model
- Safe null handling for partial data
- Backward compatibility maintained

**Day 1: Component Kit** ✅
- EmergencyStatusChip
- EmergencyTimelineWidget
- FallbackActionBar
- ResponderCard
- FacilityCard

**Day 2: EmergencyCommitmentView** ✅
- Immediate reassurance widget
- Elapsed timer
- Dynamic next-step messages
- Integrated timeline and cards

**Day 3: EmergencyScreen Upgrade** ✅
- Quick chips for emergency type
- Location confirmation
- "Can you talk?" and "People affected" inputs
- Commitment view integration

**Day 4-5: Patient Dashboard Dominance** ✅
- Emergency-dominant layout
- Active emergency banner
- Context-aware FAB
- Emergency Readiness module
- Non-wedge features moved to Explore tab

**UX Improvements** ✅
- Emergency-focused onboarding
- Role selection messaging
- Sign-in reassurance
- Human-readable locations
- Trust cues and actionable coverage

### 🚧 Current Phase

**Platform Review & Hardcoded Data Removal**
- Facility model created
- FacilityService enhanced
- Seed data system created
- Documentation updated
- **Next:** Remove hardcoded facilities from UI

### 📋 Remaining Work

See [docs/NEXT_STEPS.md](docs/NEXT_STEPS.md) for detailed next steps.

## Notes

- Keep existing backend services (they're good)
- Focus on UI/UX transformation
- Maintain data models (they support the shift)
- Test with real emergency flows
- Ensure offline-first behavior where possible
- **Remove all hardcoded data** - use seed data instead

