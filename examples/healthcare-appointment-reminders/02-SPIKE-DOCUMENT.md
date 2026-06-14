# Spike Document: Patient Appointment Reminders

## Problem Statement

Clinic staff want to reduce no-shows by sending automated reminders to patients 24 hours before their appointment.

## Success Criteria

- SMS sent 24 hours before appointment (respecting patient timezone)
- Email sent 24 hours before appointment
- Respects patient communication preferences
- No patient medical details exposed
- Unsubscribe works without authentication
- Failed sends are retried
- All sends audited (HIPAA compliance)
- Response time < 100ms

## Module Scope

**In-Scope:**
- Patient model with encrypted phone/email
- Appointment model with scheduled time
- ReminderPreference model (communication channels)
- ReminderJob scheduler (queued task)
- SMS service (Twilio integration)
- Email service (SendGrid integration)
- AuditLog for all reminder sends
- Unsubscribe endpoint

**Out-of-Scope:**
- Patient self-service preference management UI
- Appointment rescheduling
- SMS/Email template customization
- Analytics dashboard

## Technical Approach

1. **Scheduler:** Node.js cron job checks for appointments 24 hours away
2. **Queue:** Bull queue manages reminder sends (resilience)
3. **Encryption:** Patient phone/email decrypted only at send time
4. **Logging:** Every send logged to AuditLog table
5. **Retry:** Failed sends retry 3x with exponential backoff
6. **Privacy:** Generic message only ("Your appointment reminder - call clinic")

## Healthcare Concerns

**HIPAA Compliance:**
- Never store plaintext patient phone/email
- All access to phone/email logged (AuditLog)
- Logs immutable (cannot be deleted)
- No PHI in SMS/Email content

**Patient Privacy:**
- Never include medical details ("Don't forget your heart surgery!")
- Unsubscribe must work without exposing patient
- Phone/email not shown in API responses
- Failed sends not exposed to other patients

**Timezone:**
- Patient may be in different timezone than clinic
- Send reminder at patient's local time (not clinic time)
- Use patient.timezone from profile

## Assumptions

- Patient.phone and Patient.email already exist (encrypted)
- Appointment.scheduledAt already exists (UTC)
- Twilio and SendGrid credentials in env variables
- Bull Redis queue already set up
- EncryptionService exists and working
- AuditLogService exists for logging

## Timeline

| Task | Effort |
|------|--------|
| Database schema & models | 1 day |
| Scheduler & queue setup | 1 day |
| SMS/Email integration | 2 days |
| Retry logic & error handling | 1 day |
| Testing (unit + integration) | 2 days |
| **Total** | **7 days** |
