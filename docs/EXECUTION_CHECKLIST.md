# HeaLyri — 4-Week Emergency Wedge Execution Plan

**Wedge:** Emergency → Transport → Facility  
**Operating Principle:** Closed loop or nothing

> **⚠️ Context:** This plan addresses the "Air Gap" identified in [PROJECT_REVIEW.md](PROJECT_REVIEW.md) and validated by [EXTERNAL_VALIDATION.md](EXTERNAL_VALIDATION.md). The Emergency Button is currently a UI facade with zero backend logic. This checklist closes that gap.

---

## WEEK 0 (Pre-Week): Commitment Gate (48 hours)

### Objective
Lock the strategy so execution is not diluted.

### Checklist

- [ ] Emergency flow formally chosen as sole wedge
- [ ] Telehealth, AI triage, medication enhancements explicitly frozen
- [ ] Target pilot scope defined:
  - [ ] City/area (e.g., Lusaka)
  - [ ] Initial facilities (e.g., 3–5)
  - [ ] Initial drivers (even if informal/manual)
- [ ] Named Operational Owner for emergencies (even if it's you initially)

### 🔒 Definition of Done (Gate 0)

**Everyone involved can answer, without hesitation:**
> "When the emergency button is pressed, who is responsible?"

**If that answer is fuzzy → stop here.**

---

## WEEK 1: Emergency Backend Foundation (Create the Spine)

### Objective
Make emergencies real backend objects, not UI illusions.

### Technical Checklist

- [ ] Create `emergencies` collection (Firestore)
- [ ] Create `events` (or `audit_log`) append-only collection
- [ ] Define emergency lifecycle states:
  - [ ] `created` → `dispatched` → `in_transit` → `arrived` → `resolved`
- [ ] Implement `EmergencyService` (no UI logic inside)
- [ ] Capture:
  - [ ] `patientId`
  - [ ] `timestamp`
  - [ ] `location` (GeoPoint)
  - [ ] `urgency` level
- [ ] Firestore security rules updated for emergencies
- [ ] Every emergency creation logs an event

### Product Checklist

- [ ] Emergency button now creates a Firestore document
- [ ] UI reflects real backend state (even if crude)

### 🔒 Definition of Done (Gate 1)

**You can open Firestore and see a real emergency record with an event trail after pressing the emergency button.**

**If Firestore is empty → week not complete.**

---

## WEEK 2: Dispatch & Acknowledgment (Close the First Loop)

### Objective
Ensure an emergency is seen and acknowledged by another actor.

### Technical Checklist

- [ ] Cloud Function triggered on `emergency.created`
- [ ] Dispatch logic implemented (even if simple):
  - [ ] Nearest facility OR
  - [ ] Predefined facility OR
  - [ ] Manual assignment flag
- [ ] Facility notification mechanism:
  - [ ] Firestore flag, push, SMS, or manual dashboard
- [ ] Facility acknowledgment recorded:
  - [ ] Status changes to `dispatched` or `acknowledged`
- [ ] Event logged for:
  - [ ] `dispatch`
  - [ ] `acknowledgment`

### Product / Ops Checklist

- [ ] At least one facility can:
  - [ ] See an incoming emergency
  - [ ] Acknowledge it
- [ ] Patient UI updates:
  - [ ] "Emergency received"
  - [ ] "Facility notified"

### 🔒 Definition of Done (Gate 2)

**A second human (facility or operator) acknowledges the emergency, and that acknowledgment is visible to the patient.**

**If the patient cannot tell someone else is involved → stop.**

---

## WEEK 3: Transport & Real-Time Status (Make It Feel Real)

### Objective
Introduce movement and time — this is where trust is born.

### Technical Checklist

- [ ] Driver entity exists (even if minimal)
- [ ] Emergency can be assigned a driver (manual or automatic)
- [ ] Driver acceptance recorded
- [ ] Status transitions logged:
  - [ ] `in_transit`
  - [ ] `arrived`
- [ ] Location updates supported (polling is OK initially)
- [ ] All transitions emit events

### Product Checklist

- [ ] Patient sees:
  - [ ] "Driver assigned"
  - [ ] ETA or "on the way"
- [ ] Facility sees:
  - [ ] Incoming emergency + ETA
- [ ] Driver has:
  - [ ] Destination
  - [ ] Basic confirmation flow

### 🔒 Definition of Done (Gate 3)

**A human can point to the screen and say:**
> "Help is on the way, and we can see it moving."

**If it feels abstract or fake → it's not done.**

---

## WEEK 4: Resolution, Auditability & Pilot Readiness

### Objective
Turn emergencies into completed, reviewable cases.

### Technical Checklist

- [ ] Emergency can be marked `resolved`
- [ ] Resolution outcome captured:
  - [ ] `admitted`
  - [ ] `referred`
  - [ ] `stabilized`
  - [ ] `deceased` (yes, this matters)
- [ ] Full event timeline queryable
- [ ] Basic retry / failure handling added
- [ ] Unit tests for:
  - [ ] `EmergencyService`
  - [ ] Dispatch logic
- [ ] Performance sanity check (latency, failures)

### Product / Strategy Checklist

- [ ] Emergency response metrics visible:
  - [ ] Time to dispatch
  - [ ] Time to arrival
  - [ ] Resolution time
- [ ] Simple internal dashboard or report
- [ ] Pilot narrative prepared:
  - [ ] "Here's how emergencies are handled today"
  - [ ] "Here's what HeaLyri changes"

### 🔒 Definition of Done (Gate 4 — Final)

**You can walk a Ministry official or facility director through:**
> one complete emergency — from button press to resolution — with data to prove it.

**If you cannot tell the story with evidence, you are not ready.**

---

## 🚦 Absolute Stop Rules (Red Flags)

**Pause execution immediately if:**

- [ ] You start adding new features unrelated to emergency
- [ ] You optimize UI before closing backend loops
- [ ] You add AI before reliability
- [ ] You can't explain the system to a non-technical stakeholder

---

## The Meta-Definition of Done (The Only One That Really Matters)

> **If HeaLyri disappeared tomorrow, would users and facilities feel a real loss?**
>
> **If yes → you're building infrastructure.**  
> **If no → you're still building features.**

---

**Last Updated:** December 2024  
**Status:** Ready for Execution  
**Next Action:** Complete Week 0 Commitment Gate

