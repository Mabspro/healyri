# HeaLyri Next Steps

**Date:** December 2024  
**Status:** Post-Emergency Shift Implementation  
**Based On:** [PLATFORM_REVIEW.md](PLATFORM_REVIEW.md)

---

## Executive Summary

HeaLyri has successfully completed the emergency coordination shift. The platform now has:
- ✅ Emergency-first architecture
- ✅ Reusable UI components
- ✅ Emergency commitment view
- ✅ Patient dashboard dominance
- ⚠️ Hardcoded facility data (needs removal)
- ⚠️ Missing Facility model integration

**Next Phase:** Remove hardcoded data, integrate Facility model, seed production data.

---

## Immediate Actions (This Week)

### 1. Facility Model Integration

**Priority: CRITICAL**

**Tasks:**
- [x] Create `Facility` model (`lib/models/facility.dart`)
- [x] Update `FacilityService` with nearby facilities query
- [ ] Replace hardcoded facilities in `lib/home/home_screen.dart`
- [ ] Replace hardcoded facilities in `lib/facility_directory/facility_directory_screen.dart`
- [ ] Update `lib/ai_triage/triage_chatbot.dart` facility references
- [ ] Remove `lib/emergency/emergency_button.dart` if unused
- [ ] Test facility queries with real Firestore data

**Acceptance Criteria:**
- No hardcoded facility names in UI code
- All facilities come from Firestore
- Distance calculation works correctly
- Nearby facilities sorted by distance

### 2. Seed Data System

**Priority: HIGH**

**Tasks:**
- [x] Create `scripts/seed_facilities.js`
- [ ] Add service account key setup instructions
- [ ] Run seed script to populate Firestore
- [ ] Verify seeded data in Firebase Console
- [ ] Document seed data process

**Acceptance Criteria:**
- At least 5 facilities seeded in Firestore
- All facilities have valid coordinates
- Facilities are verified and ready for use

### 3. Documentation Updates

**Priority: MEDIUM**

**Tasks:**
- [x] Create `docs/PLATFORM_REVIEW.md`
- [x] Create `docs/NEXT_STEPS.md` (this document)
- [ ] Update `README.md` with current state
- [ ] Update `docs/IMPLEMENTATION_SHIFT_PLAN.md` with completed phases
- [ ] Update `docs/EXECUTION_PLAN.md` progress
- [ ] Add Facility collection to `docs/database_schema.md`

**Acceptance Criteria:**
- All docs reflect current code state
- No outdated information
- Clear next steps documented

---

## Short-Term Goals (Next 2 Weeks)

### 4. Enhanced Location Services

**Priority: MEDIUM**

**Tasks:**
- [ ] Implement reverse geocoding for human-readable addresses
- [ ] Replace "Location detected" with actual address/landmark
- [ ] Add "Adjust Pin" map functionality
- [ ] Cache location data for offline use

**Acceptance Criteria:**
- Emergency screen shows readable location (e.g., "Near Independence Ave, Lusaka")
- Users can adjust location on map
- Location persists across app restarts

### 5. Emergency Readiness Integration

**Priority: MEDIUM**

**Tasks:**
- [ ] Connect "Location enabled" to actual permission status
- [ ] Connect "Emergency contacts set" to user's contact list
- [ ] Add battery level check for optimization tip
- [ ] Create emergency setup/review screen

**Acceptance Criteria:**
- Readiness checks reflect actual system state
- Users can set up emergency contacts
- Battery optimization tip shows when battery is low

### 6. Facility Enhancements

**Priority: LOW**

**Tasks:**
- [ ] Add facility availability status (open/closed)
- [ ] Add facility capacity indicators
- [ ] Add facility emergency acceptance status
- [ ] Implement facility search with filters

**Acceptance Criteria:**
- Facilities show real-time availability
- Users can filter by type, services, NHIMA acceptance
- Search works across facility names and addresses

---

## Medium-Term Goals (Next Month)

### 7. Production Data Management

**Priority: MEDIUM**

**Tasks:**
- [ ] Create admin UI for facility management
- [ ] Add facility verification workflow
- [ ] Implement facility onboarding process
- [ ] Add facility ratings/reviews system

**Acceptance Criteria:**
- Admins can add/edit facilities via UI
- Facilities can be verified/unverified
- New facilities can be onboarded
- Users can rate facilities

### 8. Testing Infrastructure

**Priority: HIGH**

**Tasks:**
- [ ] Set up unit test framework
- [ ] Write tests for EmergencyService
- [ ] Write tests for FacilityService
- [ ] Write tests for location calculations
- [ ] Set up integration test environment

**Acceptance Criteria:**
- Test coverage > 60% for services
- All critical paths tested
- CI/CD runs tests automatically

### 9. Performance Optimization

**Priority: LOW**

**Tasks:**
- [ ] Optimize Firestore queries (add indexes)
- [ ] Implement query result caching
- [ ] Add pagination for facility lists
- [ ] Optimize image loading

**Acceptance Criteria:**
- Facility queries < 500ms
- App loads < 2s on 3G
- Smooth scrolling with 100+ facilities

---

## Long-Term Goals (Next Quarter)

### 10. Advanced Emergency Features

**Priority: MEDIUM**

**Tasks:**
- [ ] Real-time driver location tracking
- [ ] ETA calculations with traffic
- [ ] Multi-facility coordination
- [ ] Emergency escalation workflows

### 11. Analytics & Reporting

**Priority: MEDIUM**

**Tasks:**
- [ ] Emergency response time analytics
- [ ] Facility performance metrics
- [ ] Driver performance tracking
- [ ] Ministry reporting dashboard

### 12. Scale Preparation

**Priority: LOW**

**Tasks:**
- [ ] Multi-city support
- [ ] Regional facility management
- [ ] Load testing
- [ ] Disaster recovery planning

---

## Blocked Items

**None currently**

---

## Dependencies

**Facility Model Integration:**
- Blocks: Facility directory updates, nearby facilities display
- Depends on: Facility model creation (✅ done)

**Seed Data:**
- Blocks: Testing with real data, production deployment
- Depends on: Facility model (✅ done), service account setup

---

## Success Metrics

**This Phase Complete When:**
- [ ] Zero hardcoded facility data in codebase
- [ ] All facilities loaded from Firestore
- [ ] Seed data script functional
- [ ] Documentation updated
- [ ] At least 5 facilities in production database

**Next Phase Ready When:**
- [ ] Facility model fully integrated
- [ ] Real facility data in use
- [ ] Location services enhanced
- [ ] Emergency readiness connected to real data

---

## Risk Mitigation

**Risk: Facility Model Integration Delays**
- **Mitigation:** Prioritize this week, test incrementally

**Risk: Seed Data Issues**
- **Mitigation:** Test seed script in dev environment first

**Risk: Breaking Changes**
- **Mitigation:** Update one screen at a time, test after each change

---

**Last Updated:** December 2024  
**Next Review:** After facility model integration
