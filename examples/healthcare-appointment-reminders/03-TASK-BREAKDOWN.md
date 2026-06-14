# Task Breakdown: Patient Appointment Reminders

## Task Overview

8 tasks to build the appointment reminder system with HIPAA compliance.

---

### T-APR-001: Create Database Schema

**Description:** Create tables for appointment reminders, preferences, logs

**Acceptance Criteria:**
- [ ] reminder_preferences table created (encrypted phone/email)
- [ ] reminder_jobs table created (queued jobs)
- [ ] audit_logs table created (immutable)
- [ ] Indices on user_id, scheduled_at, created_at
- [ ] Foreign key constraints in place
- [ ] Migrations written

**Dependencies:** None
**Effort:** 1 day

---

### T-APR-002: Create ReminderPreference Model & DTO

**Description:** Model for patient communication preferences

**Acceptance Criteria:**
- [ ] ReminderPreference entity with encryptedPhone, encryptedEmail
- [ ] Flags: smsEnabled, emailEnabled, unsubscribed
- [ ] DTOs for create/update/response
- [ ] Response DTO never includes encrypted fields
- [ ] Repository with findByPatientId()

**Dependencies:** T-APR-001
**Effort:** 1 day

---

### T-APR-003: Create ReminderService (Core Logic)

**Description:** Business logic for creating, sending, logging reminders

**Acceptance Criteria:**
- [ ] scheduleReminder(appointmentId) - enqueues job
- [ ] sendReminder(jobId) - sends SMS/Email
- [ ] Decrypts phone/email ONLY before sending
- [ ] Generic message only (no medical details)
- [ ] Failed sends logged with reason
- [ ] All sends audited

**Dependencies:** T-APR-002
**Effort:** 2 days

---

### T-APR-004: Implement Scheduler (Cron Job)

**Description:** Check for appointments 24 hours away, queue reminders

**Acceptance Criteria:**
- [ ] Cron job runs every hour
- [ ] Finds appointments within 24-25 hour window
- [ ] Respects patient timezone
- [ ] Creates ReminderJob for each appointment
- [ ] Handles already-sent reminders (idempotent)
- [ ] Logs start/end of job

**Dependencies:** T-APR-003
**Effort:** 1.5 days

---

### T-APR-005: Implement Twilio SMS Integration

**Description:** Send SMS reminders via Twilio

**Acceptance Criteria:**
- [ ] TwilioService created
- [ ] Decrypts patient phone
- [ ] Sends generic message
- [ ] Handles Twilio errors gracefully
- [ ] Logs send attempt (encrypted phone only)
- [ ] Rate limiting respected

**Dependencies:** T-APR-003
**Effort:** 1.5 days

---

### T-APR-006: Implement SendGrid Email Integration

**Description:** Send email reminders via SendGrid

**Acceptance Criteria:**
- [ ] SendGridService created
- [ ] Decrypts patient email
- [ ] Sends generic message (no medical details)
- [ ] Handles SendGrid errors gracefully
- [ ] Logs send attempt (encrypted email only)
- [ ] Unsubscribe link includes encrypted token

**Dependencies:** T-APR-003
**Effort:** 1.5 days

---

### T-APR-007: Create Unsubscribe Endpoint

**Description:** Allow patients to unsubscribe without authentication

**Acceptance Criteria:**
- [ ] GET /reminders/unsubscribe/:token endpoint
- [ ] Token is encrypted patient ID (cannot decrypt without key)
- [ ] Updates ReminderPreference.unsubscribed = true
- [ ] Logs unsubscribe to AuditLog
- [ ] Returns generic success message
- [ ] Works without authentication

**Dependencies:** T-APR-002, T-APR-006
**Effort:** 1 day

---

### T-APR-008: Write Comprehensive Tests

**Description:** Unit, integration, and security tests

**Acceptance Criteria:**
- [ ] Unit tests for ReminderService
- [ ] Integration tests for SMS/Email flows
- [ ] Security tests: no plaintext PHI in logs/responses
- [ ] Encryption/decryption roundtrip tests
- [ ] Audit trail verification tests
- [ ] 90%+ code coverage
- [ ] HIPAA checklist verified

**Dependencies:** All previous tasks
**Effort:** 2 days

---

## Timeline

- **Sequential:** 11 days
- **With parallelism (T-005, T-006 parallel):** 10 days

## Sub-Checkpoints

1. **After T-APR-002:** ReminderPreference model works, no plaintext PHI
2. **After T-APR-004:** Scheduler finds correct appointments in all timezones
3. **After T-APR-006:** SMS/Email send with generic messages only
4. **After T-APR-007:** Unsubscribe works, audit logged

## Healthcare Notes

- Never decrypt phone/email except when sending
- All PHI access audited
- Immutable audit logs
- No plaintext in errors
- Generic messages only
