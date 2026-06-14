# Backend Development Automation Workflow - Build Specification

## Project Overview

Building a **modular, tool-agnostic AI workflow system** that automates backend development from problem statement to tested, verified code. The system is portable across any AI tool (Claude, Gemini, etc.) and any IDE (Cursor, Kiro, etc.).

---

## Repository Structure

```
backend-dev-workflow/
├── README.md                          # Project overview, setup, usage guide
├── ARCHITECTURE.md                    # Workflow state diagram, logic, design decisions
├── CONTRIBUTING.md                    # Guidelines for extending/modifying
├── LICENSE                            # MIT or your choice
├── CHANGELOG.md                       # Version history
│
├── docs/
│   ├── WORKFLOW-OVERVIEW.md          # Detailed workflow explanation
│   ├── WORKFLOW-DIAGRAM.md           # Visual state machine diagram (ASCII or description)
│   ├── CHECKPOINT-GUIDE.md           # What to check at each checkpoint
│   ├── MODULE-IDENTIFICATION.md      # How to identify relevant modules
│   └── CUSTOMIZATION-GUIDE.md        # How teams can customize components
│
├── prompts/
│   ├── README.md                     # How to use individual prompts
│   ├── MASTER-WORKFLOW.md            # Full orchestrator prompt (runs all stages)
│   │
│   └── stages/
│       ├── 01-SPIKE-DOCUMENT-GENERATOR.md
│       ├── 02-TASK-BREAKDOWN.md
│       ├── 03-CODEBASE-ANALYZER.md
│       ├── 04-PROMPT-GENERATOR.md
│       ├── 05-CODE-EXECUTOR.md
│       ├── 06-TEST-RUNNER.md
│       ├── 07-SELF-VERIFIER.md
│       └── 08-BUSINESS-LOGIC-REVIEWER.md
│
├── templates/
│   ├── SPIKE-DOCUMENT-TEMPLATE.md    # Fill-in template for spike documents
│   ├── TASK-BREAKDOWN-TEMPLATE.md    # Task definition template
│   ├── CODEBASE-ANALYSIS-TEMPLATE.md # Analysis output template
│   ├── PROMPT-TEMPLATE.md            # Execution prompt template
│   └── CHECKPOINT-CHECKLIST.md       # Verification checklist
│
├── examples/
│   └── ecommerce-cart-example/
│       ├── 01-PROBLEM-STATEMENT.md
│       ├── 02-SPIKE-DOCUMENT.md
│       ├── 03-TASK-BREAKDOWN.md
│       ├── 04-CODEBASE-ANALYSIS.md
│       ├── 05-GENERATED-PROMPTS.md
│       ├── 06-CODE-OUTPUT.md
│       ├── 07-TEST-RESULTS.md
│       └── 08-FINAL-VERIFICATION.md
│
└── config/
    ├── retry-limits.json             # Configurable retry logic (3-5 retries)
    ├── test-frameworks.json          # Supported test frameworks (Jest, Vitest, etc.)
    └── checkpoint-definitions.json   # Customizable checkpoint rules
```

---

## File Specifications

### 1. README.md
- **Purpose:** Entry point, explains the project
- **Content:**
  - What this workflow is and why
  - Quick start guide
  - How to use (master prompt vs individual stages)
  - Link to ARCHITECTURE.md
  - Link to examples

### 2. ARCHITECTURE.md
- **Purpose:** Complete technical design
- **Content:**
  - State machine diagram (text-based)
  - State descriptions (what we already documented)
  - Checkpoint definitions
  - Retry logic explanation
  - Decision trees
  - Edge cases

### 3. prompts/MASTER-WORKFLOW.md
- **Purpose:** Full end-to-end orchestrator
- **Content:**
  - Instructions for running the complete workflow
  - Sequencing of all 8 stages
  - State transitions
  - How to pass context between stages
  - Example invocation

### 4. prompts/stages/*.md
- **Purpose:** Individual stage prompts (like the Spike Document Generator we just built)
- **Content:** Each stage has detailed instructions, inputs, outputs, decision logic
- **Files needed:**
  - 01-SPIKE-DOCUMENT-GENERATOR.md (already written above)
  - 02-TASK-BREAKDOWN.md
  - 03-CODEBASE-ANALYZER.md
  - 04-PROMPT-GENERATOR.md
  - 05-CODE-EXECUTOR.md
  - 06-TEST-RUNNER.md
  - 07-SELF-VERIFIER.md
  - 08-BUSINESS-LOGIC-REVIEWER.md

### 5. templates/*.md
- **Purpose:** Fill-in templates users can adapt
- **Content:** Structured templates showing expected output format for each stage

### 6. examples/ecommerce-cart-example/
- **Purpose:** Walk-through example showing the full workflow in action
- **Content:** Real problem statement through to final verified code for e-commerce cart feature

### 7. config/*.json
- **Purpose:** Configuration files for customization
- **Content:**
  - Retry limits (currently 3-5, but teams can adjust)
  - Test frameworks (add/remove supported frameworks)
  - Checkpoint rules (add/skip checkpoints per team needs)

---

## Stage Prompt Descriptions (to be written)

### Stage 2: Task Breakdown
- **Input:** Spike document, module scope
- **Output:** Granular task list with dependencies and sub-stages
- **Key Logic:** Break feature into atomic tasks, identify which tasks run sequentially vs parallel, suggest sub-checkpoints

### Stage 3: Codebase Analyzer
- **Input:** Task list, module scope, codebase structure
- **Output:** Analysis report with patterns, concerns, existing code to reuse
- **Key Logic:** Analyse only relevant modules, extract patterns (naming, structure, error handling), flag tech debt

### Stage 4: Prompt Generator
- **Input:** Task, codebase analysis, patterns, test framework
- **Output:** Structured execution prompts with context and constraints
- **Key Logic:** Generate prompts that are language/framework aware, include edge cases, mention test patterns to follow

### Stage 5: Code Executor
- **Input:** Execution prompts
- **Output:** Generated code
- **Key Logic:** Accept code generation, no validation yet (validation happens in testing)

### Stage 6: Test Runner
- **Input:** Generated code, existing test patterns
- **Output:** Test results (pass/fail)
- **Key Logic:** Run tests, identify failures, prepare error context for retry

### Stage 7: Self-Verifier
- **Input:** Passing tests, generated code
- **Output:** Verification report with threats/trade-offs detected
- **Key Logic:** Check for architectural issues, performance concerns, security risks, auto-fix if safe

### Stage 8: Business Logic Reviewer
- **Input:** Verified code, test results
- **Output:** Approval or rejection with feedback
- **Key Logic:** Human reviews business logic correctness only (technical validation already done)

---

## Workflow State Machine (Reference)

States:
1. Problem Statement (input)
2. Spike Document (checkpoint 1)
3. Task Breakdown (checkpoint 2)
4. Codebase Analysis (checkpoint 3)
5. Prompt Generation (checkpoint 4)
6. Code Execution
7. Auto-Test
8. Test Failure Loop (3-5 retries, then escalate)
9. Self-Verification
10. Business Logic Review (checkpoint 5)
11. Task Rethinking (loop back)
12. Complete (output)

Transitions documented in ARCHITECTURE.md

---

## Configuration Options

### Retry Logic (config/retry-limits.json)
```json
{
  "test_failure_retries": 5,
  "self_verification_retries": 3,
  "escalation_strategy": "human"
}
```

### Test Frameworks (config/test-frameworks.json)
```json
{
  "supported": [
    "jest",
    "vitest",
    "mocha",
    "pytest",
    "unittest",
    "rspec"
  ]
}
```

### Checkpoint Definitions (config/checkpoint-definitions.json)
```json
{
  "spike_document": {
    "required": true,
    "checklist": ["problem_statement_clear", "modules_identified", "tech_concerns_flagged"]
  },
  "task_breakdown": {
    "required": true,
    "checklist": ["tasks_granular", "dependencies_mapped"]
  },
  ...
}
```

---

## Example Walkthrough (ecommerce-cart-example)

**Problem:** Build a shopping cart feature for an e-commerce platform

**Files in example:**
1. PROBLEM-STATEMENT.md - User input
2. SPIKE-DOCUMENT.md - Generated spike
3. TASK-BREAKDOWN.md - Task list
4. CODEBASE-ANALYSIS.md - Analysis findings
5. GENERATED-PROMPTS.md - Execution prompts
6. CODE-OUTPUT.md - Generated code
7. TEST-RESULTS.md - Test pass/fail
8. FINAL-VERIFICATION.md - Approved code

---

## How Teams Use This

### Option A: Full Workflow
1. Copy `prompts/MASTER-WORKFLOW.md`
2. Provide problem statement
3. AI runs all 8 stages sequentially
4. Output: tested, verified code

### Option B: Individual Stages
1. Copy specific stage prompt (e.g., `prompts/stages/01-SPIKE-DOCUMENT-GENERATOR.md`)
2. Provide input for that stage
3. Run in isolation
4. Use output as needed

### Option C: Customize
1. Fork repo
2. Modify `config/*.json` to adjust retry limits, frameworks, checkpoints
3. Modify stage prompts to add team-specific patterns
4. Create team-specific examples

---

## Next Steps (For Claude Code)

1. Create all files in the structure above
2. Write stage prompts 2-8 (following the pattern of stage 1)
3. Create templates for each stage output
4. Create example walkthrough
5. Add configuration files
6. Create comprehensive README

---

## Notes for Maintainers

- Keep prompts **language/framework agnostic** where possible
- Document **why** design decisions were made (for future updates)
- Examples should be **realistic** (not toy projects)
- Configuration should be **overridable** per team
- All prompts should have **clear input/output specs**
