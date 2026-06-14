# Generated Code: Patient Appointment Reminders

## reminder.service.ts

```typescript
import {
  Injectable,
  BadRequestException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { ReminderJobRepository } from './repositories/reminder-job.repository';
import { AppointmentRepository } from '../appointment/repositories/appointment.repository';
import { PatientRepository } from '../patient/repositories/patient.repository';
import { ReminderPreferenceRepository } from './repositories/reminder-preference.repository';
import { EncryptionService } from '../encryption/encryption.service';
import { AuditLogService } from '../audit/audit-log.service';
import { TwilioService } from '../messaging/twilio.service';
import { SendGridService } from '../messaging/sendgrid.service';
import { ReminderJob } from './entities/reminder-job.entity';

@Injectable()
export class ReminderService {
  private readonly logger = new Logger(ReminderService.name);
  private readonly MAX_RETRIES = 3;

  constructor(
    private jobRepository: ReminderJobRepository,
    private appointmentRepository: AppointmentRepository,
    private patientRepository: PatientRepository,
    private preferenceRepository: ReminderPreferenceRepository,
    private encryptionService: EncryptionService,
    private auditLog: AuditLogService,
    private twilioService: TwilioService,
    private sendGridService: SendGridService,
  ) {}

  async scheduleReminder(appointmentId: string): Promise<ReminderJob> {
    this.logger.debug(`Scheduling reminder for appointment ${appointmentId}`);

    const appointment = await this.appointmentRepository.findById(appointmentId);
    if (!appointment) {
      throw new NotFoundException({
        message: 'Appointment not found',
        code: 'APPOINTMENT_NOT_FOUND',
      });
    }

    const patient = await this.patientRepository.findById(appointment.patientId);
    if (!patient) {
      throw new NotFoundException({
        message: 'Patient not found',
        code: 'PATIENT_NOT_FOUND',
      });
    }

    const preferences = await this.preferenceRepository.findByPatientId(patient.id);
    if (preferences?.unsubscribed) {
      throw new BadRequestException({
        message: 'Patient has unsubscribed from reminders',
        code: 'PATIENT_UNSUBSCRIBED',
      });
    }

    const job = new ReminderJob();
    job.appointmentId = appointmentId;
    job.patientId = patient.id;
    job.scheduledForTime = appointment.scheduledAt;
    job.status = 'QUEUED';
    job.attempts = 0;

    const savedJob = await this.jobRepository.save(job);

    this.logger.debug(`Reminder scheduled for patient`);
    await this.auditLog.log({
      action: 'REMINDER_SCHEDULED',
      encryptedPatientId: this.encryptionService.encryptId(patient.id),
      entityId: savedJob.id,
      details: { appointmentId, attempts: 0 },
    });

    return savedJob;
  }

  async sendReminder(jobId: string): Promise<void> {
    this.logger.debug(`Sending reminder for job ${jobId}`);

    const job = await this.jobRepository.findById(jobId);
    if (!job) {
      throw new NotFoundException('Reminder job not found');
    }

    if (job.status === 'SENT') {
      this.logger.debug(`Reminder already sent, skipping`);
      return;
    }

    const appointment = await this.appointmentRepository.findById(job.appointmentId);
    const patient = await this.patientRepository.findById(job.patientId);
    const preferences = await this.preferenceRepository.findByPatientId(patient.id);

    if (preferences?.unsubscribed) {
      job.status = 'UNSUBSCRIBED';
      await this.jobRepository.save(job);
      await this.auditLog.log({
        action: 'REMINDER_SKIPPED_UNSUBSCRIBED',
        encryptedPatientId: this.encryptionService.encryptId(patient.id),
      });
      return;
    }

    let smsFailed = false;
    let emailFailed = false;

    // Decrypt and send SMS
    if (preferences?.smsEnabled) {
      try {
        const decryptedPhone = this.encryptionService.decrypt(patient.encryptedPhone);
        const message = 'Your appointment reminder - please call the clinic';
        await this.twilioService.sendSMS(decryptedPhone, message);

        await this.auditLog.log({
          action: 'SMS_SENT',
          encryptedPatientId: this.encryptionService.encryptId(patient.id),
        });
        this.logger.info(`SMS sent for patient`);
      } catch (error) {
        this.logger.error(`Failed to send SMS: ${error.message}`);
        smsFailed = true;
        job.lastError = error.message;
      }
    }

    // Decrypt and send Email
    if (preferences?.emailEnabled) {
      try {
        const decryptedEmail = this.encryptionService.decrypt(patient.encryptedEmail);
        const subject = 'Appointment Reminder';
        const body = 'This is a reminder to call the clinic about your appointment.';
        await this.sendGridService.sendEmail(decryptedEmail, subject, body);

        await this.auditLog.log({
          action: 'EMAIL_SENT',
          encryptedPatientId: this.encryptionService.encryptId(patient.id),
        });
        this.logger.info(`Email sent for patient`);
      } catch (error) {
        this.logger.error(`Failed to send email: ${error.message}`);
        emailFailed = true;
        job.lastError = error.message;
      }
    }

    const sendFailed = smsFailed || emailFailed;

    if (!sendFailed) {
      job.status = 'SENT';
      job.sentAt = new Date();
      await this.jobRepository.save(job);
      this.logger.info(`Reminder sent successfully`);
    } else if (job.attempts < this.MAX_RETRIES) {
      job.attempts += 1;
      await this.jobRepository.save(job);
      this.logger.warn(`Reminder failed, will retry (attempt ${job.attempts}/${this.MAX_RETRIES})`);
    } else {
      job.status = 'FAILED_PERMANENT';
      await this.jobRepository.save(job);
      this.logger.error(`Reminder failed after max retries`);
    }
  }

  async retryFailedReminders(): Promise<number> {
    this.logger.info(`Starting retry of failed reminders`);

    const failedJobs = await this.jobRepository.findFailed(this.MAX_RETRIES);
    let retried = 0;

    for (const job of failedJobs) {
      try {
        await this.sendReminder(job.id);
        retried++;
      } catch (error) {
        this.logger.error(`Failed to retry job ${job.id}: ${error.message}`);
      }
    }

    this.logger.info(`Retry complete: ${retried} reminders retried`);
    return retried;
  }
}
```
