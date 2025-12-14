# HeaLyri Next Steps - Refined Plan

**Date:** December 2024  
**Status:** Post-Emergency Shift Implementation  
**Based On:** Platform Review + UX Feedback

---

## Executive Summary

HeaLyri has successfully completed the emergency coordination shift. The platform now has:
- ✅ Emergency-first architecture
- ✅ Reusable UI components
- ✅ Emergency commitment view
- ✅ Patient dashboard dominance
- ✅ Navigation aligned with emergency-first
- ✅ All facility data from Firestore
- ✅ Welcome screen animations smooth
- ⚠️ Zambia accents not yet added

**Next Sprint:** Add Zambia accents, update triage_chatbot, populate seed data, enhance trust signals.

---

## Recommended Sprint (This Week) - HIGH IMPACT

### 1. Remove Appointments Surface (CRITICAL)

**Priority: CRITICAL** - Removes cognitive dissonance

**Tasks:**
- [x] Remove "Appointments" from drawer menu
- [x] Move appointments to "Explore → Coming Soon" (if needed)
- [x] Update drawer to focus on emergency-relevant items
- [x] Verify no appointment references in primary navigation

**Acceptance Criteria:**
- Drawer shows no appointment booking options
- Navigation clearly communicates emergency-first
- No competing product identities

### 2. Rename Bottom Navigation Tabs

**Priority: CRITICAL** - Aligns navigation with wedge

**Current:** Home / Find / Explore / Profile  
**New:** Home / Facilities / Coverage / Profile

**Tasks:**
- [x] Rename "Find" → "Facilities"
- [x] Rename "Explore" → "Coverage" (or "Readiness")
- [x] Update tab icons if needed
- [x] Update navigation logic

**Acceptance Criteria:**
- Navigation clearly reflects emergency coordination
- No "Find" or generic "Explore" labels
- Tabs map to emergency wedge features

### 3. Unify Facility Model (CRITICAL)

**Priority: CRITICAL** - Removes hardcoded data

**Tasks:**
- [x] Delete `HealthcareFacility` class from `facility_directory_screen.dart`
- [x] Convert `FacilityDirectoryScreen` to use `Facility` model + `FacilityService`
- [x] Replace hardcoded facilities in `home_screen.dart` with `FacilityService.getNearbyFacilities()`
- [ ] Update `triage_chatbot.dart` to use FacilityService
- [x] Test with real Firestore data

**Acceptance Criteria:**
- Zero hardcoded facility names in UI
- All facilities come from Firestore
- Single Facility model used everywhere
- Distance calculation works correctly

### 4. Make Emergency Readiness Real

**Priority: HIGH** - Builds trust

**Tasks:**
- [x] Connect "Location enabled" to actual permission status
- [x] Connect "Emergency contacts set" to user's contact list (or Firestore)
- [ ] Add battery level check for optimization tip (tip shown, but no actual battery check)
- [x] Gate readiness checks off actual system state (not hardcoded green)

**Acceptance Criteria:**
- Readiness checks reflect actual system state
- Users can see what needs setup
- Battery tip shows when battery is low
- Trust-building through transparency

### 5. Fix Welcome Screen Animation Jank

**Priority: HIGH** - Improves first impression

**Tasks:**
- [x] Remove `IntrinsicHeight` (causes re-layout jank)
- [x] Use separate `AnimationController` for pulse (not reuse entrance controller)
- [x] Replace `Spacer()` with `SizedBox()` in scroll contexts
- [x] Use fixed heights for hero block and carousel
- [ ] Test on multiple screen sizes (responsive design implemented, needs device testing)

**Acceptance Criteria:**
- No layout jumps or re-measurement
- Smooth animations throughout
- No animation controller conflicts
- Works on all screen sizes

### 6. Add Zambia Accents (Subtle)

**Priority: MEDIUM** - Local identity without overdoing

**Tasks:**
- [ ] Add Zambia accent colors to theme (subtle, not dominant)
- [ ] Apply accents to:
  - Verified badges
  - NHIMA acceptance chips
  - Emergency status chips
  - Small accent strokes/dividers
- [ ] Keep base palette clean and modern
- [ ] Test that it "whispers Zambia" not "shouts"

**Acceptance Criteria:**
- Zambia identity visible but subtle
- Modern medical UI maintained
- Accents enhance, don't distract
- Works across all screens

---

## Immediate Actions (This Week)

### Priority 1: Navigation & Identity
1. Remove appointments from drawer ✅ (in progress)
2. Rename bottom nav tabs ✅ (in progress)
3. Update drawer menu items

### Priority 2: Facility Model Unification
1. Delete HealthcareFacility class
2. Convert FacilityDirectoryScreen
3. Replace hardcoded facilities in HomeScreen
4. Test with seed data

### Priority 3: UX Polish
1. Fix Welcome screen animations
2. Make Emergency Readiness real
3. Add Zambia accents

---

## Short-Term Goals (Next 2 Weeks)

### 7. Enhanced Location Services

**Priority: MEDIUM**

**Tasks:**
- [ ] Implement reverse geocoding for human-readable addresses
- [ ] Replace "Location detected" with actual address/landmark
- [ ] Add "Adjust Pin" map functionality
- [ ] Cache location data for offline use

**Acceptance Criteria:**
- Emergency screen shows readable location
- Users can adjust location on map
- Location persists across app restarts

### 8. Seed Data System

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

### 9. Trust Signals Enhancement

**Priority: MEDIUM**

**Tasks:**
- [ ] Add verified responder badge
- [ ] Add facility readiness indicator
- [ ] Add "dispatch center" identity
- [ ] Ensure offline fallback always visible (Call/SMS)

**Acceptance Criteria:**
- Trust signals visible throughout emergency flow
- Users feel system is reliable
- Offline options always accessible

---

## Medium-Term Goals (Next Month)

### 10. Production Data Management

**Priority: MEDIUM**

**Tasks:**
- [ ] Create admin UI for facility management
- [ ] Add facility verification workflow
- [ ] Implement facility onboarding process
- [ ] Add facility ratings/reviews system

### 11. Testing Infrastructure

**Priority: HIGH**

**Tasks:**
- [ ] Set up unit test framework
- [ ] Write tests for EmergencyService
- [ ] Write tests for FacilityService
- [ ] Write tests for location calculations
- [ ] Set up integration test environment

### 12. Performance Optimization

**Priority: LOW**

**Tasks:**
- [ ] Optimize Firestore queries (add indexes)
- [ ] Implement query result caching
- [ ] Add pagination for facility lists
- [ ] Optimize image loading

---

## Success Metrics

**This Sprint Complete When:**
- [x] No appointments in primary navigation
- [x] Bottom nav reflects emergency wedge
- [x] Zero hardcoded facility data
- [x] Single Facility model used everywhere
- [x] Welcome screen animations smooth
- [x] Emergency Readiness shows real state
- [ ] Zambia accents added subtly

**Next Phase Ready When:**
- [x] Navigation clearly emergency-first
- [x] All facilities from Firestore
- [ ] Seed data populated (script created, needs to be run)
- [ ] Trust signals enhanced
- [x] UX polished and smooth

---

## Risk Mitigation

**Risk: Navigation Changes Break User Flow**
- **Mitigation:** Test thoroughly, update all navigation references

**Risk: Facility Model Integration Issues**
- **Mitigation:** Update one screen at a time, test after each

**Risk: Animation Fixes Cause New Issues**
- **Mitigation:** Test on multiple devices, keep backup of working version

---

**Last Updated:** December 2024  
**Next Review:** After sprint completion
