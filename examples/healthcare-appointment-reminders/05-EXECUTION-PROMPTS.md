# Execution Prompts: Patient Appointment Reminders

## T-APR-003: ReminderService - Core Reminder Logic

### Context

**NestJS Service Pattern (from codebase):**

```typescript
@Injectable()
export class AppointmentService {
  constructor(
    private repository: AppointmentRepository,
    private logger: Logger,
  ) {}

  async getAppointment(id: string) {
    this.logger.debug(`Getting appointment ${id}`);
    const appointment = await this.repository.findById(id);
    if (!appointment) {
      throw new NotFoundException('Appointment not found');
    }
    return appointment;
  }
}
```

**Encryption Pattern:**

```typescript
// Decrypt ONLY when needed (right before send)
const decrypted = this.encryptionService.decrypt(patient.encryptedPhone);
// NEVER store decrypted value
// NEVER log plaintext
```

**Database Entities:**

```typescript
// Reminder Job (queued task)
{
  id: UUID,
  appointmentId: UUID,
  patientId: UUID,
  scheduledForTime: DateTime, // UTC
  status: 'QUEUED' | 'SENT' | 'FAILED' | 'UNSUBSCRIBED',
  attempts: number,
  lastError: string,
  sentAt: DateTime,
  createdAt: DateTime,
}

// Audit Log (immutable)
{
  id: UUID,
  action: 'REMINDER_SCHEDULED' | 'SMS_SENT' | 'EMAIL_SENT' | 'FAILED',
  patientId: UUID, // encrypted
  details: JSON,
  createdAt: DateTime,
}
```

### Functional Requirements

1. **scheduleReminder(appointmentId: string): Promise\<ReminderJob\>**
   - Find appointment and patient
   - Check patient preferences (smsEnabled, emailEnabled)
   - Create ReminderJob in database
   - Log to AuditLog
   - Return job

2. **sendReminder(jobId: string): Promise\<void\>**
   - Find job and appointment
   - Get patient (with encrypted phone/email)
   - Check if already sent (idempotent)
   - Decrypt phone/email ONLY now
   - Send via SMS and/or Email (based on preferences)
   - Update job.status = 'SENT'
   - Log to AuditLog
   - Handle failures (increment attempts, retry later)

3. **retryFailedReminders(): Promise\<number\>**
   - Find failed jobs with attempts < 3
   - Retry each one
   - Return count retried

### Healthcare Compliance

**HIPAA Rules:**
1. Patient phone/email decrypted only right before sending
2. Never store decrypted phone/email in service memory
3. All sends logged to AuditLog (encrypted patient ID only)
4. No plaintext PHI in error messages
5. Message content: Generic only ("Your appointment reminder - call clinic")

**Error Messages:**
- WRONG: `Failed to send SMS to 555-123-4567`
- RIGHT: `Failed to send SMS to patient`

### Edge Cases

1. Patient unsubscribed - Skip send, mark job as 'UNSUBSCRIBED'
2. SMS fails, Email enabled - Send Email instead
3. Both fail - Mark as 'FAILED', increment attempts, retry next hour
4. Max retries exceeded - Mark as 'FAILED_PERMANENT', alert clinic
5. Patient timezone handling - Convert appointment time to patient timezone

### Test Requirements

```typescript
describe('ReminderService', () => {
  it('should schedule reminder', async () => {});
  it('should decrypt phone only before sending', async () => {});
  it('should not log plaintext phone', async () => {});
  it('should send generic message', async () => {});
  it('should create audit log', async () => {});
  it('should retry failed sends', async () => {});
  it('should skip unsubscribed patients', async () => {});
  it('should handle SMS failure and try Email', async () => {});
  it('should not exceed max retries', async () => {});
});
```

Coverage target: 95% (PHI handling is critical)

### Validation

**Input validation (DTO):**
- appointmentId: @IsUUID()
- jobId: @IsUUID()

**Business validation:**
- Appointment exists
- Patient exists
- Patient not unsubscribed
- Appointment is 24 hours away (plus/minus 1 hour window)

### Success Criteria

- [ ] scheduleReminder creates job
- [ ] sendReminder sends SMS/Email
- [ ] Phone/email decrypted only before send
- [ ] All sends audited
- [ ] Retries work (max 3 attempts)
- [ ] Unsubscribed patients skipped
- [ ] Generic message only
- [ ] No plaintext PHI in logs/errors
- [ ] 95% test coverage
