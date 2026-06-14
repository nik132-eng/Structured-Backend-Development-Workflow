# Problem Statement: Patient Appointment Reminders

## Feature Request

Clinic Management Platform needs to send appointment reminders to patients via SMS and Email 24 hours before their scheduled appointment.

## Requirements

- Send SMS and Email reminders 24 hours before appointment
- Respect patient communication preferences (SMS only, Email only, or both)
- No patient medical details in reminders (privacy)
- Unsubscribe functionality (opt-out from reminders)
- Handle failed reminders (retry logic)
- Track all reminder sends (audit trail)

## Business Context

- **Who:** Clinic staff and patients
- **Why:** Reduce appointment no-shows (currently ~15% no-show rate)
- **Impact:** Estimated 50% reduction in no-shows, saving ~$200/day per clinic
- **Timeline:** 2-week sprint

## Constraints

- Must be HIPAA compliant (patient data encryption, audit logging)
- SMS via Twilio, Email via SendGrid
- NestJS + TypeScript + PostgreSQL stack
- Must handle patient timezones correctly
- Response time < 100ms for API endpoints
- 95%+ test coverage for healthcare code

## User Stories

1. As a **patient**, I want to receive a reminder 24 hours before my appointment so I don't forget.
2. As a **patient**, I want to choose how I receive reminders (SMS, Email, or both).
3. As a **patient**, I want to unsubscribe from reminders without logging in.
4. As a **clinic admin**, I want to see which reminders were sent and their status.
5. As a **clinic admin**, I want failed reminders to retry automatically.
