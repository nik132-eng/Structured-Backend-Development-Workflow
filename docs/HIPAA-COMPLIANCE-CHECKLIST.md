# HIPAA Compliance Checklist

Before deploying any feature that touches patient data, verify:

## Data Encryption
- [ ] All phone numbers encrypted at rest (AES-256)
- [ ] All emails encrypted at rest (AES-256)
- [ ] Encryption key in environment variables (never hardcoded)
- [ ] Decryption only in service layer

## Audit Logging
- [ ] All patient data reads logged to audit_logs table
- [ ] All patient data writes logged
- [ ] All patient data deletes logged
- [ ] Logs include: patient_id (encrypted), action, user_id, timestamp, IP
- [ ] Logs cannot be deleted (verify in database constraints)

## API Security
- [ ] No plaintext PHI in responses
- [ ] No plaintext PHI in error messages
- [ ] Authentication required for sensitive endpoints
- [ ] Authorization check (user can only see their own data)

## Logging & Monitoring
- [ ] No plaintext PHI in application logs
- [ ] Audit logs queryable by clinic admin
- [ ] Alerts if >10 unauthorized access attempts
- [ ] Monthly PHI access report generated

## Data Retention
- [ ] Audit logs retained for 6 years
- [ ] Patient data retained according to state law
- [ ] Soft deletes only (never hard delete)
- [ ] Deletion logged to audit trail

## Error Handling
- [ ] All errors handled gracefully
- [ ] No stack traces exposed in production
- [ ] No PHI in error responses
- [ ] Failed operations logged with context

---

## Feature-Specific Checklist

### Patient Appointment Reminders
- [ ] Patient phone decrypted only before SMS send
- [ ] Patient email decrypted only before email send
- [ ] Reminder message contains no medical details
- [ ] Unsubscribe works without exposing patient email
- [ ] Failed reminders logged and retried
- [ ] All reminder send attempts audited

### Patient Profile Updates
- [ ] Phone/email changes audited
- [ ] Old values not exposed in logs
- [ ] Encryption/decryption working correctly
- [ ] Authorized users only can update

### Clinic Admin Dashboard
- [ ] No plaintext PHI displayed
- [ ] Access logs shown (who viewed patient data when)
- [ ] Only authorized staff can access dashboard
