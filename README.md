# Backend Development Automation Workflow for Healthcare

Automated backend feature development for **clinic management, hospital systems, and healthcare platforms**.

Designed for:
- **Stack:** NestJS + TypeScript + PostgreSQL + Jest
- **Domain:** Healthcare (Clinic/Hospital/Medical Device Management)
- **Compliance:** HIPAA-ready (encryption, audit logs, access control)
- **Sensitivity:** Patient data privacy (PHI handling, secure communication)

## Quick Start

### For Healthcare Features:
1. Read [`docs/HEALTHCARE-PATTERNS.md`](docs/HEALTHCARE-PATTERNS.md) (healthcare rules your team follows)
2. Open [`prompts/MASTER-WORKFLOW.md`](prompts/MASTER-WORKFLOW.md)
3. Provide your feature problem statement
4. Follow Stages 1-8 with healthcare considerations

### Healthcare Checklist:
Before building features that touch patient data:
- [ ] Read [`docs/HIPAA-COMPLIANCE-CHECKLIST.md`](docs/HIPAA-COMPLIANCE-CHECKLIST.md)
- [ ] Follow patterns in [`docs/HEALTHCARE-PATTERNS.md`](docs/HEALTHCARE-PATTERNS.md)
- [ ] Review [`examples/healthcare-appointment-reminders/`](examples/healthcare-appointment-reminders/)
- [ ] Use templates in [`templates/healthcare-entity-template.md`](templates/healthcare-entity-template.md)

## Healthcare Features

**Patient Data Encryption**
- Phone/email encrypted at rest (AES-256)
- Decryption only when necessary
- Never logged in plaintext

**HIPAA Audit Trail**
- Every access to patient data logged
- Logs immutable (never deleted)
- Clinic admin reports available

**Secure Communication**
- SMS/Email without exposing details
- Encrypted tokens for links
- Unsubscribe without authentication

**Timezone Support**
- Store times in UTC
- Display in patient's timezone
- Reminders at patient's local time

## Example: Patient Appointment Reminders

Complete healthcare feature example showing:
- Problem statement -> Spike document -> Task breakdown
- Codebase analysis with healthcare patterns
- Execution prompts with HIPAA compliance
- Generated code with encryption & audit logging
- Full test coverage with security tests
- Verification report flagging healthcare concerns
- Business logic approval from clinic manager

See [`examples/healthcare-appointment-reminders/`](examples/healthcare-appointment-reminders/) for complete walkthrough.

## Files

### Documentation
- [`docs/HEALTHCARE-PATTERNS.md`](docs/HEALTHCARE-PATTERNS.md) - Healthcare development standards
- [`docs/HIPAA-COMPLIANCE-CHECKLIST.md`](docs/HIPAA-COMPLIANCE-CHECKLIST.md) - Compliance verification
- [`docs/WORKFLOW-OVERVIEW.md`](docs/WORKFLOW-OVERVIEW.md) - Detailed stage-by-stage explanation
- [`docs/WORKFLOW-DIAGRAM.md`](docs/WORKFLOW-DIAGRAM.md) - Full state machine diagram
- [`docs/CHECKPOINT-GUIDE.md`](docs/CHECKPOINT-GUIDE.md) - What to check at each checkpoint
- [`docs/MODULE-IDENTIFICATION.md`](docs/MODULE-IDENTIFICATION.md) - How to scope modules
- [`docs/CUSTOMIZATION-GUIDE.md`](docs/CUSTOMIZATION-GUIDE.md) - Adapting the workflow

### Templates
- [`templates/healthcare-entity-template.md`](templates/healthcare-entity-template.md) - Entity creation guide
- [`templates/SPIKE-DOCUMENT-TEMPLATE.md`](templates/SPIKE-DOCUMENT-TEMPLATE.md) - Spike document format
- [`templates/TASK-BREAKDOWN-TEMPLATE.md`](templates/TASK-BREAKDOWN-TEMPLATE.md) - Task breakdown format
- [`templates/CODEBASE-ANALYSIS-TEMPLATE.md`](templates/CODEBASE-ANALYSIS-TEMPLATE.md) - Analysis format
- [`templates/PROMPT-TEMPLATE.md`](templates/PROMPT-TEMPLATE.md) - Prompt format
- [`templates/CHECKPOINT-CHECKLIST.md`](templates/CHECKPOINT-CHECKLIST.md) - Checkpoint format

### Configuration
- [`config/healthcare-rules.json`](config/healthcare-rules.json) - Healthcare/HIPAA rules
- [`config/retry-limits.json`](config/retry-limits.json) - Retry configuration
- [`config/test-frameworks.json`](config/test-frameworks.json) - Test framework settings

### Prompts
- [`prompts/MASTER-WORKFLOW.md`](prompts/MASTER-WORKFLOW.md) - Full 8-stage workflow
- [`prompts/stages/`](prompts/stages/) - Individual stage prompts

### Examples
- [`examples/ecommerce-cart-example/`](examples/ecommerce-cart-example/) - E-commerce cart walkthrough
- [`examples/healthcare-appointment-reminders/`](examples/healthcare-appointment-reminders/) - Healthcare appointment reminders walkthrough

## Architecture

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the full state machine, stage dependency table, retry logic, and design rationale.

## Team Onboarding

1. Read this file
2. Review [`docs/HEALTHCARE-PATTERNS.md`](docs/HEALTHCARE-PATTERNS.md)
3. Study [`examples/healthcare-appointment-reminders/`](examples/healthcare-appointment-reminders/)
4. Try running a simple feature through the workflow
5. Give feedback and iterate on prompts

## Customization

All aspects customizable:
- **Patterns:** Update [`docs/HEALTHCARE-PATTERNS.md`](docs/HEALTHCARE-PATTERNS.md)
- **Compliance:** Update [`docs/HIPAA-COMPLIANCE-CHECKLIST.md`](docs/HIPAA-COMPLIANCE-CHECKLIST.md)
- **Workflow:** Modify prompts in [`prompts/stages/`](prompts/stages/)
- **Config:** Adjust [`config/`](config/) files

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for how to extend.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for how to add stages, customize prompts, and contribute changes.

## License

Released under the [MIT License](LICENSE).
