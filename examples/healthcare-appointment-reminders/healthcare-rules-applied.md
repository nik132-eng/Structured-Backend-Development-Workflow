# Healthcare Rules Applied to This Feature

## HIPAA Rule #1: Never Log PHI in Plaintext

**APPLIED:**
- Patient phone decrypted only right before Twilio send
- Patient email decrypted only right before SendGrid send
- Audit logs never contain plaintext phone/email
- Only encrypted ID logged

## HIPAA Rule #2: Encrypt PHI at Rest

**APPLIED:**
- Patient.encryptedPhone and Patient.encryptedEmail fields
- AES-256 encryption
- Decryption key from environment variable

## HIPAA Rule #3: Immutable Audit Trail

**APPLIED:**
- AuditLog table with constraints preventing deletion
- All reminder sends logged: action, encrypted patient ID, timestamp
- Cannot be modified (HIPAA requirement)

## HIPAA Rule #4: Patient Data Privacy

**APPLIED:**
- Generic message: "Your appointment reminder - please call clinic"
- No medical details in SMS/Email
- No patient phone/email exposed in API responses

## HIPAA Rule #5: Timezone Handling

**APPLIED:**
- Appointments stored in UTC
- Patient.timezone in profile
- Reminders converted to patient's local time
- Sent at patient's local time
