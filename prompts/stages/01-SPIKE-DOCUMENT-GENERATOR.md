# Stage 1: Spike Document Generator

**Purpose:** Transform a problem statement into a structured technical spike document — identify relevant modules, analyze dependencies, and flag technical concerns — before any task breakdown or code is written.

**Input:** Problem statement from the user (may be incomplete or vague)

**Output:** Structured spike document with module scope, technical concerns, and clarifying questions resolved

---

## Stage 1: Intake & Clarification

You are receiving a problem statement. Your first task is to assess completeness.

Read the problem statement carefully and identify gaps. Check for:
- What needs to be built (feature/endpoint/system)?
- Why is it needed (business context)?
- Who uses it (user personas)?
- When is it needed (timeline/priority)?
- Constraints (performance, security, data sensitivity)?
- Integration points (existing systems it touches)?

If gaps exist, ask clarifying questions. Base the number and depth on complexity:
- Simple problem (straightforward CRUD): ask 1-2 targeted questions
- Moderate problem (multi-step workflow): ask 3-5 questions
- Complex problem (cross-system integration): ask up to 7-8 questions, possibly in grouped batches

Present questions conversationally. After the user answers, regenerate the problem statement internally to ensure clarity.

---

## Stage 2: Module Identification & Dependency Analysis

Once the problem statement is clear, identify which modules in the existing codebase are relevant.

Ask the user: "What is the codebase structure? List the main modules/folders and their purpose." (If they don't know, ask them to describe the architecture or list folder names.)

Once you understand the structure:
1. **Identify Relevant Modules:** Which modules will this feature touch or depend on?
2. **Map Dependencies:** For each module, understand: Does it depend on other modules? Are there circular dependencies? Will this feature introduce new dependencies?
3. **Document the Scope:** Clearly list which modules are in-scope and which are out-of-scope.

Example output format:

```text
In-Scope Modules:
- User Module (for authentication)
- Order Module (core feature)
- Payment Module (external integration point)

Out-of-Scope Modules:
- Notification Module (can be added later)
- Analytics Module (separate concern)

Dependencies:
- Order Module depends on User Module
- Payment Module depends on Order Module
- No circular dependencies detected
```

---

## Stage 3: Technical Concerns & Recommendations

Now assess the existing codebase for technical issues that this feature might expose or that should be addressed:

Ask: "Can you share brief details about the current schema, architecture patterns, or known technical debt in these modules?" (Or: "Do you have access to the codebase? If yes, I can analyze it; if not, describe the current state.")

Based on the answer, identify:

1. **Schema Issues:** Are there normalization problems, missing indices, or design flaws that need fixing before building this feature?
2. **Architectural Misalignment:** Does the proposed feature fit the existing patterns, or will it clash?
3. **Code Quality Concerns:** Are there patterns to follow, or anti-patterns to avoid?
4. **Performance Risks:** Will this feature create bottlenecks given the current setup?
5. **Enhancement Opportunities:** What existing code could be refactored to support this better?

Document as:

```text
Technical Concerns:
1. [Issue] -> [Impact] -> [Recommendation]
2. [Issue] -> [Impact] -> [Recommendation]

Enhancements:
1. [What exists] -> [How it could be improved] -> [Benefit to this feature]
```

---

## Stage 4: Spike Document Assembly

Compile the final spike document using [`../../templates/SPIKE-DOCUMENT-TEMPLATE.md`](../../templates/SPIKE-DOCUMENT-TEMPLATE.md), with these sections:

- **Spike Document Title:** [Feature/Epic Name]
- **Problem Statement (Refined):** Clear, complete description of what needs to be built and why
- **Success Criteria:** Measurable outcomes
- **Module Scope:** In-scope modules, out-of-scope modules, dependencies mapped
- **Technical Approach:** High-level how you'll build this given the constraints and existing code
- **Technical Concerns & Mitigations:** Issues identified, impact, recommended solutions
- **Enhancements to Consider:** Refactoring or improvements that would strengthen the feature
- **Assumptions:** What you're assuming about data, integrations, timelines
- **Open Questions (If Any):** Any clarifications still needed from the user before proceeding

---

## Stage 5: Handoff Checkpoint

Before finishing, confirm:

- [ ] Problem statement is complete and unambiguous
- [ ] Module scope is clearly defined
- [ ] Dependencies are mapped
- [ ] Technical concerns are documented
- [ ] User has reviewed and approved the spike document

If anything is missing, flag it and ask for clarification.

---

## Output

A complete spike document, saved as `[feature]-spike.md` if running standalone. When run as part of the master workflow, this becomes the input to [`02-TASK-BREAKDOWN.md`](02-TASK-BREAKDOWN.md).

## Next Step

Once approved, ask: "Are you happy with this spike document? Any changes before we proceed to Task Breakdown (Stage 2)?"
