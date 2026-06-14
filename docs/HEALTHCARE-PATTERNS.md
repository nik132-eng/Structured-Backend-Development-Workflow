# Healthcare Development Patterns - Clinic Management Platform

## HIPAA Compliance

### Rule 1: Never Log PHI in Plaintext
- WRONG: `logger.info('Patient phone: 555-123-4567')`
- RIGHT: `logger.info('Accessed patient data', { encryptedPatientId: '...' })`

### Rule 2: Encrypt PHI at Rest
- All patient phone numbers: AES-256 encrypted
- All patient emails: AES-256 encrypted
- All medical record references: Encrypted ID only

### Rule 3: Immutable Audit Trail
- Every read/write to PHI must be logged
- Logs cannot be deleted (only archived after 6 years)
- Include: action, patient_id (encrypted), user_id, timestamp, IP address

### Rule 4: Patient Data Privacy
- Never expose full phone/email in API response
- Never include medical details in SMS/Email
- Generic messages only: "Your appointment reminder - call clinic"

### Rule 5: Timezone Handling
- Store appointments in UTC
- Patient timezone in profile
- Send reminders in patient's local time

---

## Encryption Pattern

```typescript
// Always use this pattern for PHI
import { EncryptionService } from '@clinic/encryption';

@Injectable()
export class PatientService {
  constructor(
    private repository: PatientRepository,
    private encryptionService: EncryptionService,
    private auditLog: AuditLogService,
  ) {}

  async getPatient(id: string, userId: string) {
    // 1. Log access (encrypted ID only)
    await this.auditLog.logAccess({
      encryptedPatientId: this.encryptionService.encryptId(id),
      action: 'READ',
      userId,
    });

    // 2. Fetch from DB
    const patient = await this.repository.findById(id);

    // 3. Decrypt only in service (never in controller)
    const decrypted = {
      phone: this.encryptionService.decrypt(patient.encryptedPhone),
      email: this.encryptionService.decrypt(patient.encryptedEmail),
    };

    // 4. Return to client WITHOUT plaintext PHI
    return {
      id: patient.id,
      name: patient.name,
      // No phone, no email, no encrypted values
    };
  }
}
```

---

## Response Format (No PHI)

```json
{
  "success": true,
  "data": {
    "id": "patient-uuid",
    "name": "John Doe",
    "hasPhone": true,
    "hasEmail": true
  },
  "meta": {
    "timestamp": "2024-01-15T14:32:00Z"
  }
}
```

---

## Testing Requirements

All tests must verify:

- No plaintext PHI in logs
- No plaintext PHI in responses
- Encryption/decryption working
- Audit trail created for all access

---

## Common Mistakes

| Mistake | Correct Approach |
|---|---|
| Logging full phone number | Log encrypted ID only |
| Returning encrypted phone in response | Decrypt only in service |
| Storing decrypted phone in entity | Return generic response |
| No audit trail for patient data access | Audit all PHI access |
| Not handling timezone conversion | Convert timezone on display |
