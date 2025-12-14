# HeaLyri GitHub Enhancements
**Purpose:** Keep development fast while solo-building, but establish a clear path to “emergency-grade” reliability once testers/users are onboarded.

## Guiding Principles
1. **Solo velocity first, without chaos.**
2. **Emergency-critical code gets stricter first** (dispatch, status transitions, location, notifications).
3. **Progressive hardening**: add controls only when they pay for themselves.
4. **One pipeline** (GitHub Actions), one source of truth (this doc).

---

## Current State (Solo Builder Mode)
**Status:** ✅ Allowed and recommended until onboarding external testers.

### Branching & Deploy
- `main` is the working branch.
- Direct pushes to `main` are acceptable (single developer).
- Deployments can run from `main`.

### Required Habits (Solo Mode)
These are “soft gates” you self-enforce:
- Run locally before pushing:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
- Keep emergency flow stable:
  - If a change touches `lib/emergency/` or `functions/src/emergency*`, test manually.

---

## Immediate Improvements (Low Effort, High Return)
**Time cost:** ~30–90 minutes total.  
**Goal:** Reduce breakage risk without slowing solo iteration.

### 1) Add PR + Issue Templates (even if you don’t use PRs yet)
**Why:** You’ll reuse these the moment a tester reports something.

Create:
- `.github/pull_request_template.md`
- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/emergency_incident.md`

**Bug Report must include:**
- Device/platform
- Connectivity state (offline / 2G / Wi-Fi)
- Steps + expected vs actual
- Screenshot/logs

**Emergency Incident template must include:**
- Time of incident
- Emergency ID
- What failed (dispatch? status update? facility alert?)
- Impact scope
- Mitigation + follow-up action

### 2) Add Dependabot (weekly)
**Why:** Flutter + Firebase packages shift fast. You want alerts early.

Create `.github/dependabot.yml` for:
- `pub` ecosystem
- GitHub Actions updates

### 3) “Basic CI” workflow (non-blocking at first)
**Why:** Catch obvious breaks early.

Create one workflow:
- Trigger: `push`
- Steps:
  - `flutter analyze`
  - `flutter test`
- Mark as informational initially (no branch protection required yet).

---

## Future Hardening Roadmap
This section is a clear trigger-based plan (not time-based). You enable items as soon as the trigger happens.

---

### Stage 1 — First External Testers Onboarded
**Trigger:** Anyone besides you is testing the app (even 3–5 people).

#### 1) Branch Protection on `main` (lightweight)
Enable in GitHub Settings:
- Require status checks to pass (CI)
- Disable force pushes
- Require linear history (optional)

**Solo-friendly compromise:**
- Still allow direct pushes if needed,
- but prefer PRs for emergency-critical changes.

#### 2) Separate “staging” environment
- Add `staging` branch OR keep `main` but deploy to a staging Firebase project first.
- Recommended:
  - `main` → staging deploy
  - `release/*` or tagged release → production deploy (later)

#### 3) Release Notes discipline (lightweight)
- GitHub Releases for milestones:
  - `v0.1 Emergency MVP`
  - `v0.2 Dispatch + Facility Readiness`
- Include “Emergency flow changes” section.

---

### Stage 2 — First Real Emergencies or Pilot Partner
**Trigger:** A real pilot (clinic, employer, ministry program) OR real emergencies handled.

#### 1) Sentry (recommended)
You already have Firebase Performance + Crashlytics; Sentry adds:
- Web error tracking
- Release health
- Commit/PR correlation

Set up:
- Sentry project
- GitHub integration
- Slack alerts for new issues

#### 2) Coverage reporting (targeted)
Don’t chase 90% everywhere.
Enforce coverage on **core emergency domain only**:
- Emergency creation
- Dispatch assignment
- Status transitions
- Facility readiness + notification triggers

Add Codecov only when you have meaningful tests.

#### 3) CodeQL + Secret Scanning
- Add CodeQL workflow (weekly + on push to main)
- Ensure secret scanning is enabled in repo Security settings

---

### Stage 3 — Scaling Beyond One City / More Developers
**Trigger:** 2+ devs OR multiple cities OR paid contracts.

#### 1) Strong branch strategy
- `main` (production)
- `develop` (staging)
- `feature/*`
- `hotfix/*`

#### 2) Incident Response Runbook in `docs/`
Add:
- `docs/INCIDENT_RESPONSE.md`
- `docs/POSTMORTEM_TEMPLATE.md`

#### 3) Uptime monitoring
- UptimeRobot/Pingdom on:
  - Hosting endpoint
  - Cloud Function health endpoint (if you add one)
- Alerting to Slack

---

## Emergency-Critical Definition
These areas are “life-path code” and get stricter rules first:

### Emergency-Critical Areas
- `lib/emergency/**`
- `lib/services/emergency_service.dart`
- `functions/src/emergency*.ts`
- Firestore rules for `emergencies`, `events`
- Facility readiness + notification triggers

### Required checks (once Stage 1 begins)
- CI pass
- Manual “trigger → assign → update status” smoke test
- Offline simulation test (at least once per release)

---

## Recommended GitHub Actions (Minimal Set)
When you’re ready (Stage 1+), maintain only these:

1. **ci.yml**
- `flutter analyze`
- `flutter test`

2. **deploy-hosting.yml**
- Build web: `flutter build web --release`
- Deploy hosting: `firebase deploy --only hosting`

3. **deploy-functions.yml**
- Deploy functions: `firebase deploy --only functions`

(Optionally combine 2 & 3 later.)

---

## Notes on Firebase Hosting vs App Hosting
HeaLyri does **not** need Firebase App Hosting to be downloadable in Zambia.
- Downloadability comes from **Android/iOS distribution** (Play Store/TestFlight/APK), not App Hosting.
- Firebase Hosting is for the **web version** and is sufficient.

---

## Owner
- **Owner:** Mabs (solo)
- Update this file whenever:
  - You add a new integration
  - You add a new stage trigger
  - You change the deployment strategy
