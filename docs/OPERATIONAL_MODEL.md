# HeaLyri: Operational Responsibility Model

**Critical Question:** Who is operationally responsible when an emergency is triggered?

**Answer:** Start semi-manual, build tech to replace humans gradually, never pretend automation exists before it does.

---

## Week 1-2: Manual Operations

### Who Handles What

**Emergency Creation:**
- **System:** Creates emergency document, logs event
- **System:** Sends alert to operations team

**Emergency Routing:**
- **You / Operations Team:** Manually reviews emergency
- **You / Operations Team:** Manually selects facility (based on location, capacity, availability)
- **You / Operations Team:** Manually assigns driver (if needed)
- **System:** Updates emergency document, logs events

**Facility Notification:**
- **System:** Sends notification to facility
- **Facility Coordinator:** Manually acknowledges via phone call or app
- **System:** Logs acknowledgment event

**Driver Notification:**
- **System:** Sends notification to driver
- **Driver:** Manually accepts via phone call or app
- **System:** Logs acceptance event

**Status Updates:**
- **Driver:** Manually updates location/status via app or phone
- **Facility:** Manually updates capacity/status via app or phone
- **System:** Logs all updates as events

**Resolution:**
- **Facility Coordinator:** Manually marks emergency as resolved
- **System:** Logs resolution event, updates state

### Process Flow (Manual)

```
1. Patient triggers emergency
   ↓
2. System creates emergency document
   ↓
3. Alert sent to operations team (you)
   ↓
4. You review emergency:
   - Check location
   - Check urgency
   - Check facility availability
   ↓
5. You manually assign:
   - Facility (call or app)
   - Driver (call or app)
   ↓
6. System notifies:
   - Facility
   - Driver
   ↓
7. Manual acknowledgments:
   - Facility confirms via phone/app
   - Driver confirms via phone/app
   ↓
8. Manual status updates:
   - Driver updates location
   - Facility updates capacity
   ↓
9. Manual resolution:
   - Facility marks resolved
   - You verify and close
```

### Tools Needed

**For Operations Team:**
- Admin dashboard (view emergencies)
- Phone (for facility/driver coordination)
- App (for manual assignments)

**For Facilities:**
- App (acknowledge, update status)
- Phone (backup communication)

**For Drivers:**
- App (accept, update location)
- Phone (backup communication)

### Success Criteria

- [ ] Emergency created within 30 seconds
- [ ] Facility assigned within 2 minutes
- [ ] Driver assigned within 3 minutes (if needed)
- [ ] Facility acknowledges within 5 minutes
- [ ] Driver accepts within 5 minutes
- [ ] Status updates every 2 minutes
- [ ] Resolution within 1 hour

---

## Week 3-4: Semi-Automated

### Who Handles What

**Emergency Creation:**
- **System:** Creates emergency document, logs event
- **System:** Automatically routes to nearest available facility
- **System:** Sends alert to operations team (for oversight)

**Emergency Routing:**
- **System:** Automatically selects facility (geospatial query + capacity check)
- **You / Operations Team:** Manually assigns driver (if system can't find one)
- **System:** Updates emergency document, logs events

**Facility Notification:**
- **System:** Sends notification to facility
- **Facility Coordinator:** Acknowledges via app (automated if capacity available)
- **System:** Logs acknowledgment event

**Driver Notification:**
- **System:** Sends notification to nearest available driver
- **Driver:** Accepts via app (automated if available)
- **System:** Logs acceptance event

**Status Updates:**
- **Driver:** Updates location/status via app (automatic GPS updates)
- **Facility:** Updates capacity/status via app
- **System:** Logs all updates as events

**Resolution:**
- **Facility Coordinator:** Marks emergency as resolved via app
- **System:** Logs resolution event, updates state

### Process Flow (Semi-Automated)

```
1. Patient triggers emergency
   ↓
2. System creates emergency document
   ↓
3. System automatically:
   - Finds nearest facility
   - Checks capacity
   - Routes emergency
   ↓
4. System notifies facility
   ↓
5. Facility acknowledges via app:
   - Automatic if capacity available
   - Manual if capacity limited
   ↓
6. System assigns driver:
   - Automatic if driver available
   - Manual if no driver available
   ↓
7. Driver accepts via app
   ↓
8. Automatic status updates:
   - Driver GPS location
   - Facility capacity
   ↓
9. Facility resolves via app
```

### Tools Needed

**For Operations Team:**
- Admin dashboard (monitor, intervene if needed)
- Phone (backup for manual coordination)

**For Facilities:**
- App (acknowledge, update status, resolve)

**For Drivers:**
- App (accept, GPS tracking, update status)

### Success Criteria

- [ ] Emergency created within 30 seconds
- [ ] Facility automatically assigned within 1 minute
- [ ] Driver automatically assigned within 2 minutes (if available)
- [ ] Facility acknowledges within 3 minutes
- [ ] Driver accepts within 3 minutes
- [ ] Automatic status updates every 30 seconds
- [ ] Resolution within 1 hour

---

## Post-Week 4: Fully Automated (Future)

### Who Handles What

**Emergency Creation:**
- **System:** Creates emergency document, logs event
- **System:** Automatically routes to nearest available facility
- **System:** Automatically assigns nearest available driver

**Emergency Routing:**
- **System:** Automatically selects facility (geospatial + capacity + availability)
- **System:** Automatically selects driver (geospatial + availability)
- **System:** Updates emergency document, logs events

**Facility Notification:**
- **System:** Sends notification to facility
- **System:** Facility auto-acknowledges if capacity available
- **System:** Logs acknowledgment event

**Driver Notification:**
- **System:** Sends notification to driver
- **System:** Driver auto-accepts if available
- **System:** Logs acceptance event

**Status Updates:**
- **System:** Automatic GPS tracking (driver)
- **System:** Automatic capacity updates (facility)
- **System:** Logs all updates as events

**Resolution:**
- **System:** Auto-resolves based on facility input
- **System:** Logs resolution event, updates state

### Human Oversight

**Operations Team:**
- Monitor dashboard
- Intervene only for:
  - System failures
  - Unusual patterns
  - Escalations

### Success Criteria

- [ ] Emergency created within 30 seconds
- [ ] Facility automatically assigned within 30 seconds
- [ ] Driver automatically assigned within 1 minute
- [ ] Facility auto-acknowledges within 1 minute
- [ ] Driver auto-accepts within 1 minute
- [ ] Automatic status updates every 10 seconds
- [ ] Resolution within 1 hour

---

## Operational Roles

### Operations Team (You / Staff)

**Responsibilities:**
- Monitor emergency dashboard
- Manual intervention when needed
- Coordinate with facilities/drivers
- Verify resolution
- Handle escalations

**Tools:**
- Admin dashboard
- Phone
- App

**Availability:**
- Week 1-2: 24/7 (manual operations)
- Week 3-4: Business hours + on-call
- Post-Week 4: Business hours only (automated)

### Facility Coordinators

**Responsibilities:**
- Acknowledge emergencies
- Update facility capacity
- Mark emergencies as resolved
- Coordinate with drivers (if needed)

**Tools:**
- Facility app
- Phone (backup)

**Availability:**
- Business hours (facility-dependent)
- On-call for emergencies

### Drivers

**Responsibilities:**
- Accept emergency assignments
- Update location/status
- Transport patients
- Mark arrival

**Tools:**
- Driver app
- Phone (backup)

**Availability:**
- When marked "available" in app
- On-call for emergencies

---

## Escalation Procedures

### Level 1: System Failure

**Scenario:** System cannot route emergency

**Action:**
1. Alert operations team immediately
2. Manual routing within 2 minutes
3. Log incident for review

### Level 2: Facility Non-Response

**Scenario:** Facility doesn't acknowledge within 5 minutes

**Action:**
1. Alert operations team
2. Try next nearest facility
3. Contact facility directly
4. Log incident

### Level 3: Driver Non-Response

**Scenario:** Driver doesn't accept within 5 minutes

**Action:**
1. Alert operations team
2. Try next nearest driver
3. Contact driver directly
4. Log incident

### Level 4: Critical Emergency

**Scenario:** Urgency = "critical" and no response

**Action:**
1. Immediate operations team alert
2. Manual coordination
3. Direct facility contact
4. Direct driver contact
5. Escalate to Ministry if needed

---

## Training Requirements

### Operations Team

**Week 1:**
- [ ] Emergency dashboard training
- [ ] Manual routing procedures
- [ ] Facility/driver contact protocols
- [ ] Escalation procedures

**Week 2:**
- [ ] Practice scenarios
- [ ] Response time targets
- [ ] Documentation requirements

### Facilities

**Week 1:**
- [ ] App installation and setup
- [ ] Acknowledgment procedures
- [ ] Status update procedures
- [ ] Resolution procedures

**Week 2:**
- [ ] Practice scenarios
- [ ] Response time targets

### Drivers

**Week 1:**
- [ ] App installation and setup
- [ ] Acceptance procedures
- [ ] Location update procedures
- [ ] Arrival procedures

**Week 2:**
- [ ] Practice scenarios
- [ ] Response time targets

---

## Key Principles

1. **Start Manual:** Prove the loop works, even if manual
2. **Automate Gradually:** Replace humans step by step
3. **Never Fake Automation:** If it's manual, say it's manual
4. **Maintain Oversight:** Always have human monitoring
5. **Reliability > Speed:** Better slow and reliable than fast and broken

---

**Last Updated:** December 2024  
**Status:** Ready for Implementation

