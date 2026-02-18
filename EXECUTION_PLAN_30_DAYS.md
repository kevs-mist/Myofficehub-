# EXECUTION_PLAN_30_DAYS

Simple 30-day execution checklist for MyOfficeHub.
Rule: complete today's list only. Do not jump ahead.

## Daily Routine (Do This Every Day)
- [ ] Open board and move today's task to `In Progress`
- [ ] Write 3 tests first: happy path, bad input, no network
- [ ] Implement only today's task
- [ ] Run `flutter analyze`
- [ ] Run app smoke test for today's module
- [ ] Commit changes: `Day X: <task>`
- [ ] Update `DAILY_LOG.md` with blockers and fixes

## Day 1 - Scope Freeze
- [ ] Lock V1 scope (Auth, Tenants, Payments, Events, Complaints)
- [ ] Write acceptance criteria per module
- [ ] Create task board columns: Backlog, In Progress, Blocked, QA, Done
- [ ] Done when scope has no open ambiguity

## Day 2 - Environment Validation
- [ ] Verify clean local setup for Flutter/Firebase/Supabase
- [ ] Check `.env`, `.env.production`, `.env.example` key consistency
- [ ] Verify backend config switching works
- [ ] Done when app and backend run from documented steps

## Day 3 - Auth Hardening
- [ ] Verify register/login/logout/forgot-password/email verification
- [ ] Block unverified users from protected routes
- [ ] Normalize auth error messages
- [ ] Done when all auth happy/unhappy paths pass

## Day 4 - Role Enforcement
- [ ] Validate Admin/Tenant role mapping from backend data
- [ ] Validate frontend route guards and backend authorization
- [ ] Attempt privilege escalation tests and patch gaps
- [ ] Done when tenant cannot access admin resources

## Day 5 - Tenants Module
- [ ] Complete admin create/read/update tenant flow
- [ ] Validate payloads and field-level validation
- [ ] Ensure loading/empty/error states exist
- [ ] Done when tenant operations are stable end-to-end

## Day 6 - Events Module
- [ ] Complete admin event create/edit/list
- [ ] Complete tenant event list and RSVP
- [ ] Confirm refresh/realtime consistency
- [ ] Done when event lifecycle works for both roles

## Day 7 - Complaints Module
- [ ] Complete tenant complaint submit flow
- [ ] Complete admin resolve flow
- [ ] Validate status transitions and timestamps
- [ ] Done when complaint lifecycle is stable and role-safe

## Day 8 - Payments Module
- [ ] Validate payment model and UI states
- [ ] Validate tenant payment history/status view
- [ ] Validate admin payment overview accuracy
- [ ] Done when payment views match backend data

## Day 9 - UX Consistency
- [ ] Standardize loading/empty/retry/error states
- [ ] Standardize snackbar/toast copy and severity
- [ ] Verify mobile spacing and touch targets
- [ ] Done when no screen misses core state handling

## Day 10 - Push Notifications
- [ ] Verify FCM permission request and token sync
- [ ] Validate notification preferences
- [ ] Test: event created, complaint update, payment reminder
- [ ] Done when notifications work end-to-end on test devices

## Day 11 - API Contract
- [ ] Normalize response schema and error format
- [ ] Validate status codes across endpoints
- [ ] Update API contract docs
- [ ] Done when frontend uses consistent parsing only

## Day 12 - Security Pass 1
- [ ] Validate rate limiting
- [ ] Validate input checks on all write endpoints
- [ ] Ensure sanitized error responses
- [ ] Validate strict CORS allowlist
- [ ] Done when no obvious OWASP-basic gaps remain

## Day 13 - Supabase RLS Audit
- [ ] Re-check RLS policies for all core tables
- [ ] Validate indexes for frequent queries
- [ ] Run role-based data access tests
- [ ] Done when tenant isolation is confirmed

## Day 14 - Performance Baseline
- [ ] Record startup and key screen load times
- [ ] Record API latency baseline
- [ ] Fix top 3 bottlenecks
- [ ] Done when baseline and target thresholds are documented

## Day 15 - Deployment Dry Run
- [ ] Finalize hosting platform
- [ ] Deploy staging config
- [ ] Validate health checks and logs
- [ ] Done when staging backend is stable for QA

## Day 16 - Production Infra
- [ ] Configure production env vars
- [ ] Configure SSL/HTTPS and domain
- [ ] Configure uptime monitors and alerts
- [ ] Done when alerts fire in test scenario

## Day 17 - Release Config
- [ ] Verify app versioning metadata
- [ ] Validate Android signing setup
- [ ] Validate iOS signing/provisioning prerequisites
- [ ] Done when release builds are repeatable

## Day 18 - Android RC
- [ ] Build release APK and AAB
- [ ] Smoke test on 2 physical Android devices
- [ ] Fix release-only issues
- [ ] Done when Android RC passes core flows

## Day 19 - iOS RC
- [ ] Build iOS release IPA
- [ ] Validate auth, notifications, API reachability on iOS
- [ ] Fix iOS-specific config issues
- [ ] Done when iOS RC passes core flows

## Day 20 - Optional Platforms
- [ ] Build web/windows if in scope
- [ ] Validate routing/auth/backend connectivity
- [ ] Decide go/no-go for each optional platform
- [ ] Done when status is clearly documented

## Day 21 - Automation Pass
- [ ] Add high-value tests for critical flows
- [ ] Ensure smoke scripts are runnable
- [ ] Add CI commands for analyze/test/build
- [ ] Done when regression suite is green

## Day 22 - Bug Bash 1 (Admin)
- [ ] Test auth + admin workflows
- [ ] Log and prioritize findings
- [ ] Fix all blocker/high bugs
- [ ] Done when no blocker/high remains from round 1

## Day 23 - Bug Bash 2 (Tenant)
- [ ] Test tenant workflows + notifications
- [ ] Test edge cases: network fail, expired token, empty states
- [ ] Fix all blocker/high bugs
- [ ] Done when no blocker/high remains from round 2

## Day 24 - Store + Legal
- [ ] Finalize metadata and store assets
- [ ] Finalize privacy policy and support contact
- [ ] Validate in-app terms/privacy screens
- [ ] Done when submission package is complete

## Day 25 - Freeze
- [ ] Freeze all feature work
- [ ] Allow bug fixes and release blockers only
- [ ] Tag release candidate branch/version
- [ ] Done when branch is protected for release quality

## Day 26 - Full Regression
- [ ] Run full regression checklist on release candidate
- [ ] Validate monitoring under test load
- [ ] Confirm crash/error logs are clean
- [ ] Done when regression sign-off is complete

## Day 27 - Go/No-Go
- [ ] Review open risks and known issues
- [ ] Confirm rollback plan and owners
- [ ] Record explicit go/no-go decision
- [ ] Done when stakeholder approval is recorded

## Day 28 - Production Deployment
- [ ] Deploy backend to production
- [ ] Switch app to production backend config
- [ ] Publish Android and iOS builds
- [ ] Done when production is healthy and accessible

## Day 29 - Hypercare 1
- [ ] Monitor uptime, auth failures, API errors, crashes
- [ ] Triage and hotfix critical issues
- [ ] Done when no unresolved production blockers

## Day 30 - Hypercare 2 + Retro
- [ ] Continue monitoring and finalize hotfixes
- [ ] Run retrospective: keep, drop, improve
- [ ] Create next-cycle backlog
- [ ] Done when stable production and next roadmap are ready

## Non-Negotiable Rules
- [ ] No new features after Day 25
- [ ] No secrets in repo
- [ ] No day ends without commit + daily log
- [ ] If blocked for 2+ hours, reduce scope and ship smaller working piece
