# HeaLyri: 4-Week Emergency Flow Execution Plan

**Strategic Direction:** Emergency → Transport → Facility  
**Deadline:** 4 weeks to closed-loop emergency handling  
**Status:** 🚀 Ready to Execute

> **⚠️ IMPORTANT:** This document provides detailed day-by-day planning.  
> **For the master execution checklist with hard gates, see [EXECUTION_CHECKLIST.md](EXECUTION_CHECKLIST.md)**

---

## Executive Commitment

**We commit to:**
- Emergency flow as the wedge (non-negotiable)
- 4-week deadline for closed-loop emergency handling
- Hybrid state + event architecture (formalized now)
- Aggressive feature freeze (emergency + facilities only)
- Ministry-ready data design from day 1

**Definition of Done (4 Weeks):**
✅ Emergency can be created  
✅ Emergency can be routed  
✅ Emergency can be acknowledged  
✅ Emergency can be tracked  
✅ Emergency can be resolved  
✅ Full audit trail exists  

**Anything less = pause point, not milestone.**

---

## Week 1: Emergency Backend Foundation

### Day 1-2: Data Model + Architecture

**State Collections:**
- [ ] Create `emergencies` collection schema
- [ ] Create `drivers` collection schema (if not exists)
- [ ] Update `facilities` with emergency fields

**Event Collections:**
- [ ] Create `events` collection (append-only)
- [ ] Define event types: `emergency_created`, `emergency_dispatched`, `driver_assigned`, `facility_acknowledged`, `emergency_resolved`

**Security Rules:**
- [ ] Update Firestore rules for emergencies
- [ ] Update Firestore rules for events
- [ ] Add role-based access for emergency handlers

**Deliverable:** Complete data model document

### Day 3-4: Core Services

**EmergencyService:**
- [ ] Create emergency
- [ ] Get emergency status
- [ ] Update emergency status
- [ ] List active emergencies

**EventService:**
- [ ] Log event (append-only)
- [ ] Query events by emergency ID
- [ ] Query events by type

**LocationService:**
- [ ] Capture user location
- [ ] Calculate distance to facilities
- [ ] Geospatial queries

**Deliverable:** Working EmergencyService with tests

### Day 5: Integration + Testing

- [ ] Connect EmergencyButton to EmergencyService
- [ ] Create emergency from UI
- [ ] Display emergency status
- [ ] Unit tests (80% coverage target)
- [ ] Integration tests

**Deliverable:** End-to-end emergency creation working

---

## Week 2: Routing + Dispatch

### Day 6-7: Facility Routing

**FacilityService:**
- [ ] Find nearest facility (geospatial)
- [ ] Check facility capacity
- [ ] Check facility emergency acceptance
- [ ] Reserve capacity slot

**EmergencyService:**
- [ ] Route emergency to facility
- [ ] Update emergency with facility assignment
- [ ] Log `emergency_routed` event

**Deliverable:** Emergency routes to nearest available facility

### Day 8-9: Driver Coordination (Semi-Manual)

**DriverService:**
- [ ] List available drivers
- [ ] Find nearest driver
- [ ] Assign driver to emergency
- [ ] Update driver status

**EmergencyService:**
- [ ] Assign driver (manual or automatic)
- [ ] Update emergency with driver assignment
- [ ] Log `driver_assigned` event

**Note:** Start with manual assignment, build automation later

**Deliverable:** Driver can be assigned to emergency

### Day 10: Notification System

**NotificationService:**
- [ ] Send notification to facility
- [ ] Send notification to driver
- [ ] Send status update to patient
- [ ] FCM integration

**Deliverable:** All parties notified of emergency status

---

## Week 3: Real-Time Tracking + Acknowledgment

### Day 11-12: Real-Time Updates

**Real-Time Service:**
- [ ] Firestore listeners for emergency status
- [ ] Driver location updates
- [ ] Facility acknowledgment
- [ ] Patient status updates

**EmergencyService:**
- [ ] Update emergency status in real-time
- [ ] Track driver location
- [ ] Track facility response

**Deliverable:** Real-time status updates working

### Day 13-14: Facility Acknowledgment

**FacilityService:**
- [ ] Acknowledge emergency receipt
- [ ] Update facility capacity
- [ ] Mark emergency as "acknowledged"
- [ ] Log `facility_acknowledged` event

**EmergencyService:**
- [ ] Handle facility acknowledgment
- [ ] Update emergency status
- [ ] Notify patient of acknowledgment

**Deliverable:** Facilities can acknowledge emergencies

### Day 15: Driver Tracking

**DriverService:**
- [ ] Update driver location
- [ ] Update driver status (en route, arrived)
- [ ] Calculate ETA
- [ ] Log driver events

**EmergencyService:**
- [ ] Track driver progress
- [ ] Update patient with driver ETA
- [ ] Handle driver arrival

**Deliverable:** Driver location tracked and displayed

---

## Week 4: Resolution + Audit Trail

### Day 16-17: Emergency Resolution

**EmergencyService:**
- [ ] Mark emergency as resolved
- [ ] Capture resolution outcome
- [ ] Update facility capacity
- [ ] Release driver
- [ ] Log `emergency_resolved` event

**Resolution Data:**
- [ ] Outcome (treated, transferred, declined)
- [ ] Resolution time
- [ ] Facility response time
- [ ] Driver response time
- [ ] Patient feedback (optional)

**Deliverable:** Emergency can be fully resolved

### Day 18-19: Audit Trail + Reporting

**EventService:**
- [ ] Complete event log for each emergency
- [ ] Query events by time range
- [ ] Generate emergency report
- [ ] Export for Ministry (future)

**Ministry-Ready Data:**
- [ ] Standardized timestamps
- [ ] Clear resolution outcomes
- [ ] Location accuracy
- [ ] Facility response times
- [ ] Driver acceptance times

**Deliverable:** Complete audit trail for every emergency

### Day 20: Testing + Pilot Prep

**Testing:**
- [ ] End-to-end test: Create → Route → Acknowledge → Track → Resolve
- [ ] Load testing (10 concurrent emergencies)
- [ ] Error handling tests
- [ ] Offline scenario tests

**Pilot Setup:**
- [ ] 3 facilities onboarded
- [ ] 5 drivers onboarded
- [ ] Test emergency scenarios
- [ ] Documentation for operators

**Deliverable:** Ready for controlled pilot

---

## Operational Responsibility Model

### Week 1-2: Manual Operations

**Who handles emergencies:**
- **You / Development Team** (manual dispatch)
- **Facility Coordinator** (manual acknowledgment)
- **Driver** (manual status updates)

**Process:**
1. Emergency created → Alert sent to you
2. You manually assign facility + driver
3. You notify facility + driver
4. Facility manually acknowledges
5. Driver manually updates status
6. You manually resolve

**Goal:** Prove the loop works, even if manual

### Week 3-4: Semi-Automated

**Who handles emergencies:**
- **System** (automatic routing to nearest facility)
- **You** (manual driver assignment if needed)
- **Facility** (manual acknowledgment via app)
- **Driver** (manual status updates via app)

**Process:**
1. Emergency created → System routes to facility
2. System notifies facility
3. You assign driver (or system if available)
4. Facility acknowledges via app
5. Driver updates status via app
6. System tracks and resolves

**Goal:** Reduce manual steps, maintain reliability

### Post-Week 4: Fully Automated (Future)

**Who handles emergencies:**
- **System** (automatic routing, dispatch, tracking)
- **Facility** (automatic acknowledgment if capacity available)
- **Driver** (automatic acceptance if available)
- **Human oversight** (monitoring dashboard)

**Goal:** Full automation with human oversight

---

## Feature Freeze List

### ❌ FROZEN (No Work Until Emergency Complete)

- Telehealth backend
- Advanced AI triage
- Medication scanning enhancements
- Social sign-in (Facebook)
- Complex onboarding
- Any feature not supporting emergency flow

### ✅ ALLOWED (Emergency + Facilities Only)

- Emergency flow (all aspects)
- Facility directory (real data, search, verification)
- Driver management (for emergency dispatch)
- Basic authentication (for emergency access)
- Location services (for emergency routing)
- Notifications (for emergency coordination)

---

## Success Criteria (4 Weeks)

### Technical
- [ ] Emergency can be created from UI
- [ ] Emergency routes to nearest facility
- [ ] Facility can acknowledge emergency
- [ ] Driver can be assigned and tracked
- [ ] Emergency can be resolved
- [ ] Complete audit trail exists
- [ ] Real-time updates working
- [ ] 80%+ test coverage

### Operational
- [ ] 3 facilities onboarded
- [ ] 5 drivers onboarded
- [ ] Manual process documented
- [ ] Operator training complete
- [ ] Pilot scenarios tested

### Data Quality
- [ ] Standardized timestamps
- [ ] Clear resolution outcomes
- [ ] Location accuracy verified
- [ ] Response times tracked
- [ ] Ministry-ready format

---

## Risk Mitigation

### Risk: 4-week deadline too aggressive
**Mitigation:** Focus on closed loop, not perfection. Manual steps OK.

### Risk: No drivers available
**Mitigation:** Start with facility-only routing. Add drivers in Week 3.

### Risk: Facilities don't respond
**Mitigation:** Build acknowledgment system. Track response rates.

### Risk: Technical complexity
**Mitigation:** Use existing Firebase features. Avoid over-engineering.

### Risk: Operational burden
**Mitigation:** Start manual, automate gradually. Never fake automation.

---

## Daily Standup Template

### What I Completed Yesterday
- [List completed tasks]

### What I'm Working On Today
- [List current tasks]

### Blockers
- [List any blockers]

### Operational Notes
- [Any operational concerns]

---

## Week 4 Deliverable Checklist

**Before Week 5, you must have:**

- [ ] Emergency creation working
- [ ] Emergency routing working
- [ ] Facility acknowledgment working
- [ ] Driver assignment working (even if manual)
- [ ] Real-time tracking working
- [ ] Emergency resolution working
- [ ] Complete audit trail
- [ ] 3 facilities onboarded
- [ ] 5 drivers onboarded (or facility-only if not available)
- [ ] End-to-end test successful
- [ ] Documentation complete

**If any item is missing → PAUSE. Do not expand.**

---

## Post-Week 4: What Happens Next?

### If Closed Loop Complete ✅
- Expand to more facilities
- Add more drivers
- Improve automation
- Add analytics dashboard
- Engage Ministry with data

### If Closed Loop Incomplete ❌
- **STOP**
- Identify gaps
- Fix issues
- Re-test
- Do not add new features

---

## Mindset Shift

**For the next 30 days:**

❌ **NOT:** "We're building a healthcare app"  
✅ **YES:** "We're an emergency-response company that uses Flutter and Firebase"

**This means:**
- Reliability > Features
- Operational readiness > Code perfection
- Real emergencies > Demo scenarios
- Ministry data > User metrics

---

**Last Updated:** December 2024  
**Status:** Ready for Execution  
**Next Review:** End of Week 1

