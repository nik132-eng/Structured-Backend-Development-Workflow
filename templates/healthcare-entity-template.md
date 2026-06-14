# Healthcare Entity Template

Use this template when creating new entities that touch patient data:

```typescript
import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';
import { Expose } from 'class-transformer';

@Entity('[table_name]')
export class [EntityName] {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  patientId: string;

  // Patient phone (ENCRYPTED) - Never expose plaintext. Decrypt only in service layer.
  @Column('text')
  encryptedPhone: string;

  // Patient email (ENCRYPTED) - Never expose plaintext. Decrypt only in service layer.
  @Column('text')
  encryptedEmail: string;

  @Column('timestamp with time zone')
  createdAt: Date;

  @Column('timestamp with time zone')
  updatedAt: Date;

  // Response DTO - never includes encrypted fields
  @Expose()
  toResponse() {
    return {
      id: this.id,
      patientId: this.patientId,
      createdAt: this.createdAt,
    };
  }
}
```

## Checklist for New Healthcare Entities

- [ ] All PHI fields encrypted (phone, email, SSN, DOB, address)
- [ ] `toResponse()` method excludes all encrypted fields
- [ ] Audit logging added for all CRUD operations
- [ ] Repository methods never return plaintext PHI
- [ ] Migration includes encryption for existing data
- [ ] Tests verify no PHI leaks in responses or logs
