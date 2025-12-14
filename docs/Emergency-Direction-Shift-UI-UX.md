Below is a developer-facing UX/UI direction MD you can drop into docs/ (suggested filename: docs/UX_UI_DIRECTION_EMERGENCY_PLATFORM.md). It covers:

UI/UX principles for the “Emergency Coordination Platform” shift

What stays vs what changes in current dashboards

Role-based information architecture

The canonical emergency flow UI (patient + dispatcher + responder + facility)

Landing page alignment (web) so your story matches the product

# HeaLyri UI/UX Direction: Emergency Coordination Platform

**Doc Type:** Developer UX/UI Spec (MVP → Scale)  
**Status:** Canonical UX Direction  
**Last Updated:** Dec 2024  
**Primary Wedge:** Emergency → Transport → Facility  
**Core UX Goal:** Convert "panic" into "visible commitment + coordinated action"

---

## 1) Product UX Thesis

HeaLyri is not “a healthcare app with an emergency button.”
HeaLyri is an **Emergency Coordination Platform** with a healthcare shell.

**UI must communicate three things:**
1) **Immediate commitment** (“Help is being coordinated now.”)  
2) **Trust signals** (verified responders, verified facilities, auditable actions)  
3) **Progress visibility** (timeline, ETAs, handoffs, resolution)

If the user taps Emergency and feels uncertainty, we’ve failed.

---

## 2) Design Principles (Non-Negotiables)

### P0 Principles (must ship)
- **One-tap clarity:** Emergency action is always visible and unambiguous.
- **Parallel reassurance:** After activation, UI must show:
  - Request received
  - Responder assigned (or searching)
  - Facility alerted (or selecting)
  - Live status timeline
- **Offline-first behavior:** If network weak:
  - degrade to call/SMS fallback
  - keep user in flow (don’t dead-end)
- **Action hierarchy:** Emergency is always priority #1 (even for providers/drivers).
- **Time is a first-class UI element:** show elapsed time + stage timestamps.
- **Trust is visual:** verification badges, responder identity, facility readiness signals.

### P1 Principles (scale-ready)
- **Do not over-feature:** freeze telehealth/triage/meds unless they support emergency wedge.
- **Audit by default:** every emergency view should have a “Case Summary” and “Event Log” view.
- **Role-aware UI:** the same emergency has different controls per role.

---

## 3) Information Architecture (IA)

### Global Navigation (MVP)
- Home (Role dashboard)
- Emergency (persistent CTA / dedicated screen)
- Facilities
- Profile

### Role Dashboards
- Patient Dashboard
- Driver Dashboard
- Facility Dashboard
- Dispatcher Dashboard (web-first, internal)

**Rule:** Do NOT bury emergency in a menu. It is a persistent CTA (FAB + top banner option).

---

## 4) The Emergency Experience (Core UX)

### 4.1 Entry Points (Always Available)
- Persistent Emergency FAB
- Emergency banner on dashboard (“Need urgent help?”)
- Long-press emergency shortcut (optional)
- “Call Dispatch” fallback button always visible post-trigger

### 4.2 Emergency Trigger Screen (Patient)
Goal: reduce panic, capture essentials fast.

**MVP inputs (strictly minimal):**
- Confirm location (auto-detected + “adjust pin”)
- “What’s happening?” quick chips:
  - Accident / Injury
  - Breathing / Chest pain
  - Pregnancy / labor
  - Child emergency
  - Violence / safety
  - Other
- “Can you talk?” Yes/No
- “How many people affected?” (1 / 2-5 / 6+)

**Submit button text:**
- “Send Emergency Request”

### 4.3 Post-Trigger Screen: “Commitment View”
This is the emotional center of the app.

**Must show immediately (even before assignment):**
- Status: “Request received”
- Timer: “Elapsed 00:17”
- Next step: “Assigning nearest responder…”
- Fallback: “Call Dispatch” + “SMS Backup” (if enabled)

**Once assigned:**
- Responder card:
  - Name + photo (or avatar)
  - Vehicle type (taxi/bike/ambulance/tri-wheel)
  - Verified badge
  - ETA
  - Call button
- Facility card:
  - “Facility alerted” (or “Selecting facility…”)
  - facility name + distance + readiness indicator (simple for MVP)

**Timeline component (must):**
- Received → Assigned → En route → Arrived → Departed → Arrived facility → Resolved

**Safety microcopy (must):**
- “If you are in immediate danger, move to safety if possible.”
- “Keep phone charged; we’ll update you in real time.”

### 4.4 Emergency Resolution Screen
- Outcome selection (patient/dispatcher/facility can mark):
  - Resolved / Admitted / Referred / Cancelled / No-show / Deceased (admin only)
- Quick feedback:
  - “Did help arrive?” yes/no
  - 1–5 rating for responder and facility
- “Download/Share case summary” (later)
- “Report issue” (must)

---

## 5) Rideshare-Like UX (But Healthcare-Grade)

### Keep rideshare patterns:
- Responder assignment state (“Searching…”, “Matched”)
- Responder profile card + ETA
- Live tracking map (optional MVP; can be Phase 1.5)
- Status steps + notifications

### Upgrade beyond rideshare:
- **Facility pre-alert** (not just destination)
- **Triage tag** (low/medium/high/critical)
- **Audit timeline** (immutable event log behind the scenes)
- **Fallback channels** (call/SMS) as first-class UI

Rideshare optimizes convenience. We optimize consequence.

---

## 6) What Stays vs What Changes (Dashboards)

### 6.1 Patient Dashboard

#### Stays
- Clean, modern entry dashboard
- Facilities directory access
- Profile + verification

#### Changes
- Emergency becomes **dominant**:
  - Top section: “Emergency Status” (if active) or “Emergency Help”
  - Secondary: Facilities
  - Freeze: Telehealth, AI Triage, Med Verification → moved to “Explore” or hidden behind “Coming soon”

**Patient dashboard modules (MVP):**
1) Emergency CTA / active emergency tracker
2) Nearby facilities (3 cards)
3) “My Coverage” (subscription status / employer plan)
4) Profile completeness + trusted contacts

### 6.2 Driver Dashboard

#### Stays
- Driver profile + verification flow
- Driver home screen concept

#### Changes
- Must become “Responder Console”:
  - Primary view: Active dispatch requests
  - Acceptance workflow like rideshare
  - Navigation + call + status update buttons

**Driver modules (MVP):**
1) Incoming request card (Accept/Decline)
2) Active case view (Navigate, Call, Update Status)
3) Training + compliance badge
4) Earnings/credits (optional; even if zero, show “Activity Summary”)

Driver statuses:
- Available / Busy / Offline
- On route / Arrived / Transporting / Completed

### 6.3 Facility Dashboard (Provider)

#### Stays
- Facility profile and admin notion

#### Changes
- Facility becomes a “Receiving Center”
  - Incoming emergency alerts
  - Confirm readiness (basic MVP: Accept/Decline)
  - Outcome reporting after arrival

**Facility modules (MVP):**
1) Incoming emergency alert list
2) Current incoming patient view (ETA, triage)
3) Facility readiness toggle (Simple: Accepting Emergencies ON/OFF)
4) Case outcomes + notes

### 6.4 Dispatcher Dashboard (Web-first Internal Tool)

This is the brain. It can be very simple at MVP.

**Modules (MVP):**
- Live queue of emergencies
- Map view with responders + facilities
- Assignment panel (manual override)
- Event log stream
- One-click “Call patient” / “Call responder” / “Call facility”
- SLA indicators (elapsed time, overdue warnings)

**Key UX principle:** Dispatchers must never lose the active case.

---

## 7) Visual Design Direction

### Tone
- Calm authority
- “Medical-grade” clarity
- High trust, low gimmick

### UI components to standardize
- Status chips (Received / Assigned / En route / Arrived / Resolved)
- Verified badge styles (Responder Verified / Facility Verified)
- Emergency timeline component
- Primary CTA styles (Emergency vs non-emergency CTAs)
- Fallback call/SMS buttons (always prominent)

### Accessibility
- Large tap targets
- High contrast for emergency screens
- Language support path (English first, expand later)
- Avoid dense text during emergencies

---

## 8) Landing Page Alignment (Web)

The landing page must match the new product truth.
No more “healthcare everything” front and center.

### Landing Page Hierarchy (Recommended)
1) **Hero:** “Emergency response coordination for Zambia — from hours to minutes.”
   - Subhead: “Dispatch + community responders + facilities — connected.”
   - Primary CTA: “Join coverage” or “Pilot with us”
   - Secondary CTA: “For Facilities” / “For Employers” / “For Government”

2) **How it Works (3 steps)**
   - Trigger → Dispatch → Help arrives → Facility ready

3) **Trust & Accountability**
   - Verified responders
   - Facility network
   - Audit trail + response time tracking

4) **Who It’s For**
   - Families (subscription)
   - Employers (coverage benefit)
   - Facilities (incoming referrals)
   - Government (coordination layer)

5) **Pilot Program**
   - Lusaka / Copperbelt focus
   - “We’re onboarding drivers + facilities”

6) **FAQ**
   - Offline support (hotline, SMS)
   - Pricing concept
   - Safety and verification

### What to remove/de-emphasize
- Telehealth marketing
- AI triage marketing
- Medication verification marketing
(Keep as “Coming later”)

Landing page goal: make partners say “this is infrastructure.”

---

## 9) MVP UX Scope (4–6 weeks)

### Ship first
- Patient emergency trigger + commitment view + timeline
- Driver accept/decline + status updates
- Facility alert accept/decline + readiness toggle
- Dispatcher queue + manual assignment
- Fallback: call dispatch everywhere

### Defer
- Full maps with live tracking (optional MVP+)
- AI triage (keep minimal prompts)
- Payments inside app (can start with manual subscription confirmation)
- Deep facility capacity modeling

---

## 10) Acceptance Criteria (UX Definition of Done)

Emergency flow is “done” when:
- Patient can trigger emergency in <10 seconds
- Patient sees “request received” within 1 second of submit
- Responder can be assigned and see case
- Facility receives alert
- Status updates propagate to patient view
- Fallback call works at all steps
- A complete case timeline is visible after resolution

Dashboards are “done” when:
- Each role sees only what they need to execute the wedge
- No role requires navigating deep menus during emergency operations

Landing page is “done” when:
- The first 10 seconds communicates emergency coordination clearly
- CTAs map to stakeholder types (family/employer/facility/government)
- “Super app” messaging is not dominant

---

## 11) Implementation Notes (Dev)

- Emergency views must be resilient to partial data:
  - show “searching” states without errors
- Prefer predictable state machines for emergency UI:
  - avoid ad-hoc booleans; use status enum
- Notifications:
  - in-app updates first
  - push later; SMS fallback later
- Keep UI components reusable across roles:
  - EmergencyStatusChip
  - TimelineWidget
  - ResponderCard
  - FacilityCard

---

## 12) Next Artifacts To Produce

- Component library inventory (Flutter widgets list)
- Screen-by-screen wireframes (low-fidelity)
- Copy deck (microcopy for emergency flows)
- UX event schema mapping (UI events ↔ backend event log)

---