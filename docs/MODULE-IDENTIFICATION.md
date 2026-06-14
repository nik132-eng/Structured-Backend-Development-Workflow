# Module Identification Guide

Stage 1 (Spike Document Generator) and Stage 3 (Codebase Analyzer) both depend on correctly identifying which parts of a codebase are relevant. This guide covers how to do that well, especially in large or unfamiliar codebases.

## How to Identify Relevant Modules

### Start from the verbs, not the nouns

Take the refined problem statement from Stage 1 and list the *actions* the feature requires (e.g., "add item to cart", "validate stock", "create order from cart"). For each action, ask: "which module currently owns this responsibility, or would own it?" This tends to surface modules more reliably than starting from "what data is involved" — data often spans many modules, but responsibilities are usually concentrated.

### Distinguish "touches" from "depends on"

A module is **in-scope** (touched) if this feature adds/modifies code in it. A module is a **dependency** if this feature's code *calls into* it but doesn't change it. Both matter, but they have different implications:

- In-scope modules need Stage 3 analysis (their patterns will be matched by new code).
- Dependency-only modules need just enough Stage 3 analysis to know their *interface* (what functions/endpoints are available to call) — not their internal patterns.

In the cart example (`examples/ecommerce-cart-example/`), `Product` is a dependency (cart code calls `ProductService.checkAvailability`) while `Cart` itself and parts of `Order` are in-scope.

### Use existing entry points as a map

If you have codebase access, the fastest way to find relevant modules is to search for how *similar* existing features are wired:

- Find an existing feature that's structurally similar to the new one (e.g., if adding "Cart", look at how "Order" — another user-owned collection of items — is structured).
- Trace its route -> controller -> service -> model chain. The files in that chain, plus their direct dependencies, are your starting module list.

### When you don't have codebase access

If the AI agent running the workflow can't read the codebase directly (common when running Stage 1 conversationally before any code exists, or when the codebase is on a system the agent can't reach):

- Ask the user for a **directory listing** (`ls -R` or equivalent, possibly filtered) rather than a verbal description — directory structure often reveals the architectural pattern (e.g., `src/{models,services,controllers,routes}/` implies layered MVC) without needing file contents.
- Ask for **one representative file per layer** for the module most similar to the new feature (per "Use existing entry points as a map" above). One real file is worth more than a paragraph describing "the pattern we use."
- If the user genuinely doesn't know the structure (e.g., non-technical stakeholder), proceed with Stage 1 at a higher level of abstraction (module scope described in domain terms — "the part of the system that handles X") and defer precise file-level scope to Stage 3, once someone with codebase access is available.

## Understanding Dependencies

### Mapping dependencies

For each in-scope module, ask:

- What does it call into (other modules' services/functions)? -> these are its dependencies.
- What calls into it? -> these are its dependents. A change here could ripple outward.

### Detecting circular dependencies

A circular dependency (Module A depends on Module B, and Module B depends on Module A) is a flag — not necessarily a blocker, but something Stage 1 should document explicitly, because it usually means:

- The new feature is the *cause* of the cycle (e.g., adding a new dependency edge that completes a cycle) — in which case, consider whether the feature can be implemented via an event/callback instead of a direct call, or whether shared logic should move to a third module both depend on.
- The cycle *already existed* — document it as pre-existing tech debt (Stage 1's "Enhancements to Consider" or Stage 3's "Tech Debt"), but don't let resolving it become unplanned scope for this feature unless it's a blocking concern.

### New dependencies introduced by this feature

Explicitly call out any *new* dependency edges the feature creates (e.g., in the cart example, "Order Module's checkout flow depends on Cart Module" is a new edge). New edges are worth noting because:

- They're the most likely place for Stage 6/7 integration issues.
- They may need a corresponding sub-checkpoint (Stage 2) for extra scrutiny in Stage 3/8.

## Tips for Large Codebases

- **Don't try to analyze everything.** Stage 3's depth should be proportional to how much new code will be written in/around a module, not the module's overall size.
- **Prefer breadth-first for dependency-only modules, depth-first for in-scope modules.** Know *that* a dependency module has a `checkAvailability`-equivalent function before worrying about *how* it's implemented; for in-scope modules, the implementation details are exactly what Stage 4 needs.
- **Re-run Stage 3 scoped, not wholesale, when something changes.** If the codebase changes between Stage 3 and Stage 5 (e.g., another team merges a change to a dependency module), re-run Stage 3 for *just* that module rather than redoing the full analysis.
