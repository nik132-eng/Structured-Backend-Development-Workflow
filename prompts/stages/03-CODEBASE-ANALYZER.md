# Stage 3: Codebase Analyzer

**Purpose:** Analyze the modules in scope (from Stage 1's Module Scope and Stage 2's Task List) to extract real coding patterns, identify technical debt and red flags, and produce recommendations and a patterns summary that will drive Stage 4's prompt generation.

**Input:** Task list (Stage 2), module scope (Stage 1), and codebase access or description

**Output:** Codebase analysis report covering module structure, patterns/conventions, technical concerns, recommendations, pre-build tasks, a patterns summary, and a readiness assessment

---

## Stage 1: Intake & Clarification

Ask the user:

1. **"Do you have direct access to the codebase (repo URL, local files, or code snippets), or would you like to describe the relevant files/patterns?"**
   - If direct access: read the in-scope modules identified in Stage 1, focusing on files relevant to the Stage 2 task list.
   - If not: ask for at least one example of each — a model/entity, a controller/route handler, a service/business-logic file, and an existing test file — for each in-scope module.

2. **"What is the primary backend language/framework, and which version?"**
   - Determines which idioms, file conventions, and ecosystem tools (ORM, validation library, test framework) to look for.

3. **"Are there any known issues or tech debt in these modules?"**
   - Helps focus analysis on areas the user already knows are weak, so the report isn't just confirming the obvious.

Based on the responses, decide whether you're working from real code or descriptions, and which framework-specific patterns to look for.

---

## Stage 2: Module Structure & Organization

For each in-scope module from Stage 1, go deeper than the spike document did:

**Directory structure:**
- What files/directories make up this module (controllers/handlers, services, repositories/data access, models/entities, validation schemas, middleware, tests, config)?
- Is it organized logically — are concerns separated (controller ≠ service ≠ data access)?
- Are tests colocated with source or in a separate directory?

**Dependencies between modules:**
- Map which in-scope (and adjacent) modules import from each other.
- Flag circular dependencies, deep coupling (a module depending on many others), or missing abstraction (a controller reaching directly into another module's data layer).

**External dependencies:**
- Databases, external APIs/services, and key third-party libraries each module relies on, with versions where relevant.
- Note anything outdated or with known issues, but only if relevant to the modules in scope.

---

## Stage 3: Pattern Extraction

Extract and document the "how we do things here" conventions — these become the patterns summary that Stage 4 prompts will reference directly.

**Naming conventions:**
- Controllers/handlers, services, repositories/data-access, models, request/response or validation schemas: file naming pattern, casing, suffixes.

**Code structure patterns:**
- **Service layer**: how dependencies are wired in (DI, imports, constructors), async style, error handling, logging.
- **Controller/handler layer**: how request data is extracted and validated, how responses/errors are shaped, status code conventions.
- **Error handling**: custom error/exception classes, global error handler/middleware, error response shape.
- **Validation**: where and how input is validated (middleware, schema library, decorators, manual checks).

**Database & data patterns:**
- ORM/query builder in use, transaction patterns, relation-loading approach (eager vs. lazy), N+1 risk areas.
- Table/collection naming, foreign key naming, timestamp columns, migration tooling and conventions.

**Testing patterns:**
- Test framework (cross-reference [`../../config/test-frameworks.json`](../../config/test-frameworks.json)), file location/naming, fixture/mocking approach, assertion style.
- Current coverage baseline if known.

---

## Stage 4: Technical Concerns & Red Flags

Identify issues in the codebase that could affect the new feature, organized by category. For each, capture: **Issue**, **Module(s)**, **Impact on the new feature**, and a draft **Recommendation**.

Categories to scan for:

- **Architecture**: circular dependencies, god objects/services, business logic leaking into controllers, missing dependency injection, missing abstraction layers.
- **Data model**: poor normalization, missing indices, missing foreign key constraints, missing timestamps, missing soft-delete where the feature needs it.
- **Code quality**: inconsistent error handling, missing input validation, missing logging, hardcoded secrets, missing rate limiting on endpoints the feature extends.
- **Testing**: low coverage in modules the feature touches, unit-only coverage where integration tests are needed, flaky tests, no fixtures/factories.
- **Performance**: N+1 query patterns, inefficient algorithms in hot paths, missing caching, missing pagination on endpoints the feature builds on.
- **Security**: missing auth/authorization checks, injection risks (raw queries, unsanitized input), exposed sensitive data in logs/responses.

Only record concerns that are actually relevant to the in-scope modules and the Stage 2 task list — this is not a full codebase audit.

---

## Stage 5: Recommendations & Enhancements

For each concern from Stage 4, add:

- **Recommendation**: the concrete fix.
- **Effort**: quick fix / medium refactor / major overhaul.
- **Priority**: High / Medium / Low.
- **Blocking?**: can Stage 2's tasks be built and tested without this fix (No), or would skipping it produce incorrect/untestable results (Yes)?

Ask the user: **"Which of these concerns should be fixed before building the new feature (pre-build tasks), and which can be addressed later or worked around?"**

- Anything marked **blocking** becomes a **pre-build task** — flag it back to Stage 2 so it's added to the task list (with its own dependency ordering) before Stage 4 generates prompts.
- Anything **non-blocking** but worth doing can be logged as a P1/P2 follow-up task (similar to how Stage 7/8 may log follow-ups), without blocking this feature's timeline.

---

## Stage 6: Patterns & Conventions Summary

Compile a condensed, reference-able summary — this is the section Stage 4 will lean on most heavily. Cover, in a few lines each:

- Naming conventions (controllers, services, data access, models, validation/DTOs)
- Code structure (framework, DI approach, error handling, validation approach)
- Database (ORM, table/column naming, migration tooling)
- Testing (framework, file location/naming, mocking approach, coverage target)
- Response/error format (the shape Stage 4 prompts should tell Stage 5 to produce)

Write this so that someone who has never seen the codebase could write code that fits, based on this section alone.

---

## Stage 7: Codebase Analysis Document Assembly

Assemble the final report using [`../../templates/CODEBASE-ANALYSIS-TEMPLATE.md`](../../templates/CODEBASE-ANALYSIS-TEMPLATE.md), with sections:

- **Executive Summary**: what was analyzed, overall state, and whether the codebase is ready for this feature (one or two sentences, including any timeline impact from pre-build tasks).
- **Module Structure**: per-module directory layout, dependencies, and which Stage 2 tasks touch each module.
- **Patterns & Conventions**: naming, error handling, structure, validation, data access, testing (from Stage 3).
- **Technical Concerns**: table of issue / module / impact / recommendation / effort / priority / blocking (from Stages 4-5).
- **Tech Debt**: pre-existing issues noted but not required for this feature.
- **Refactoring Opportunities**: improvements that would make Stage 2's tasks easier or safer, with the benefit to specific tasks.
- **Pre-Build Tasks**: any blocking concerns that must be resolved first, to be added to the Stage 2 task list before Stage 4 proceeds.
- **Patterns Summary**: the condensed reference from Stage 6.
- **Readiness Assessment**: Ready to build now (Yes/No), blockers if any, overall risk level (Low/Medium/High).
- **Assumptions & Notes**: anything inferred without direct codebase access, caveats, incomplete information.

---

## Stage 8: Handoff Checklist

Before finalizing, confirm:

- [ ] Every in-scope module from Stage 1 has been analyzed (or explicitly noted as inaccessible, with a fallback plan)
- [ ] Dependencies between modules are mapped
- [ ] Patterns are documented specifically enough to be referenced directly in generated prompts (not generic "follow best practices")
- [ ] Every technical concern is marked blocking or non-blocking, with effort and priority
- [ ] Any blocking concerns are captured as pre-build tasks and flagged back to Stage 2
- [ ] Test framework and conventions are identified
- [ ] Patterns Summary is complete and self-contained
- [ ] User has reviewed and approved the analysis

Ask: **"Does this analysis accurately reflect your codebase? Any corrections or additions before we proceed to Prompt Generation?"**

If the user approves, this is **Checkpoint 3**. Any pre-build tasks identified should be reflected in the Stage 2 task list (a brief return to Stage 2) before moving to Stage 4.

---

## Instructions for Use

**As a standalone prompt:**
1. Provide the task breakdown and codebase access (or descriptions).
2. Work through Stages 1-8 sequentially.
3. Produce the final Codebase Analysis Report.
4. Ask: "Is this analysis accurate? Ready for Prompt Generation?"

**As part of the master workflow:**
1. Receive the task list from Stage 2 and the module scope from Stage 1.
2. Work through Stages 1-8.
3. Output the analysis report, including any pre-build tasks.
4. If pre-build tasks exist, briefly return to Stage 2 to add them to the task list; otherwise transition to [`04-PROMPT-GENERATOR.md`](04-PROMPT-GENERATOR.md), passing the Patterns Summary as critical context.

---

## Key Principles

1. **Scope discipline**: only analyze in-scope modules and what the Stage 2 tasks touch — this is not a full codebase audit.
2. **Extract, don't judge**: document patterns objectively, focused on consistency, even if they're not best practice.
3. **Concrete over generic**: every pattern and concern should be specific enough to act on directly.
4. **Patterns Summary is the deliverable**: it's the single most important section for Stage 4.
5. **Separate blocking from nice-to-have**: blocking concerns become pre-build tasks; everything else is a follow-up, not a delay.

## Output

Save as `[feature]-analysis.md` if running standalone. When run as part of the master workflow, this — along with the task list from Stage 2 — becomes the input to [`04-PROMPT-GENERATOR.md`](04-PROMPT-GENERATOR.md).
