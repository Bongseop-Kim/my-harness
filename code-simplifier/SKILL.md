---
name: code-simplifier
description: Use when recently modified code should be simplified for clarity, consistency, and maintainability without changing behavior, especially after feature work, refactors, or review feedback focused on readability.
---

# Code Simplifier

## Overview

Refine recently changed code so it is easier to read, reason about, and maintain while preserving exact functionality. This skill is not just a cleanup checklist. It is a structured review-and-refine workflow built around a scoped diff, three separate review lenses, and a final integration pass in the main session.

## Workflow

1. Identify the changed scope from `git diff` or recent edits.
2. Read project instructions before editing, especially `CLAUDE.md`, `AGENTS.md`, or nearby conventions in touched files.
3. Choose the execution mode.
4. Review the same scoped code through three separate lenses.
5. Aggregate findings in the main session.
6. Apply the smallest coherent refactor that improves clarity without changing behavior.
7. Run targeted verification for the touched area.
8. Summarize only the meaningful simplifications and any remaining risk.

## Default `/simplify` Flow

Unless the user asks for a different process, follow this three-phase flow.

### Phase 1: Identify Changes

1. Run `git diff` or `git diff HEAD` to collect the changed files and relevant hunks.
2. If there is no git diff, inspect the most recently modified or edited files instead.
3. Keep the scope tight. Do not turn `/simplify` into a whole-repository cleanup pass.

### Phase 2: Run Three Reviews Over the Same Diff

The important rule is that all three reviewers inspect the same overall diff, not three disjoint file slices.

If parallel subagents are available and explicitly allowed for this task, invoke three read-only reviewers in parallel in a single round.

If parallel subagents are not available, perform the same three reviews sequentially yourself before editing.

### Phase 3: Aggregate and Edit in the Main Session

1. Wait for the three review results.
2. Merge the findings in the main session.
3. Ignore false positives. Do not spend time arguing with them.
4. Make the edits yourself in the main session so the final patch stays coherent.
5. Verify and summarize the meaningful improvements.

## Define Scope

Default to code changed in the current session or visible in the local diff. Expand the scope only when:

- a simplification would otherwise leave duplicated or inconsistent logic nearby
- a touched file needs a small supporting cleanup to stay coherent
- the user explicitly asks for a broader pass

If the recent scope is ambiguous, inspect the current diff first instead of scanning the whole codebase.

When the diff is large, rank files by simplification value:

- files with recent feature work
- files with duplicated or branching-heavy logic
- files that now violate nearby project conventions
- files where a small cleanup will improve future edits

When passing context to reviewers, include:

- the full scoped diff
- any local instructions that materially affect style or architecture
- a reminder that they should report findings, not apply edits

## Apply Project Standards

Follow repository-specific instructions first. When standards are documented in `CLAUDE.md` or similar guidance, apply them consistently in the refined code.

Pay particular attention to:

- import style and ordering
- module syntax and file extensions
- function and component declaration style
- explicit types on public or top-level APIs when the project expects them
- existing naming and error-handling patterns
- established React patterns when editing React code

When project guidance conflicts with generic cleanup instincts, follow the project guidance.

If project guidance is missing, prefer explicit code over compact code:

- `function` declarations over unnecessarily indirect forms
- clear `if`/`else` or `switch` over nested ternaries
- small helpers over repeated inline logic
- explicit names over short generic names

## Choose Execution Mode

Use one of these modes before editing.

### Standard Pass

Use for one small diff or one obviously messy area. Perform the three review lenses yourself in sequence.

### Deep Pass

Use when any of these apply:

- the user explicitly asks for a stronger simplification pass
- the changed scope spans multiple files
- the code mixes refactoring, style drift, and control-flow complexity
- a previous simplification pass felt too shallow

In deep pass, do not rely on one overall impression. Deliberately inspect the code through separate lenses and merge the results.

### Parallel `/simplify` Pass

If the environment supports delegation and the user explicitly wants multi-agent or parallel review, split the review into three independent read-only reviewer subtasks and run them in parallel. Each reviewer sees the same diff but through a different lens. They return findings only. The main session owns the patch.

Do not let subagents edit files for this workflow unless the user explicitly asks for that variant.

If parallel review is not available, run the same three lenses sequentially yourself. The important part is the separation of concerns and shared diff context, not the mechanism.

## Three Review Lenses

Every non-trivial pass should examine the code through these lenses before editing.

### 1. Code Reuse

Question: "Did this change recreate something that already exists?"

Look for:

- duplicated helpers or utilities
- inlined logic that should call an existing function
- near-duplicate transformations
- ad hoc formatting or parsing that already has a local abstraction

### 2. Code Quality

Question: "Does this code work but still feel hacky or harder than it should be?"

- unnecessary nesting
- duplicated state
- too many loosely related parameters
- copy-paste logic
- leaky abstractions
- stringly-typed control flow
- unnecessary JSX wrappers
- comments that explain what the code does instead of making the code clear
- repeated logic that should be extracted
- indirection that hides simple behavior
- control flow that is correct but hard to scan

### 3. Efficiency and Operational Weight

Question: "Is this needlessly heavy, redundant, or wasteful?"

Look for:

- duplicated computation
- missed opportunities for safe parallelization
- hot-path bloat
- no-op updates
- check-then-act patterns that invite TOCTOU issues
- memory leaks or retained references
- overly broad work when a tighter scope is available
- hidden side effects
- sequencing assumptions

Across all three lenses, reject any cleanup that is not clearly behavior-preserving.

## Preferred Simplifications

Prefer changes like:

- flattening unnecessary nesting
- replacing indirect or redundant abstractions with explicit code
- extracting small helper functions when it reduces repetition or cognitive load
- consolidating closely related logic that is currently fragmented
- renaming vague variables or functions to reflect intent
- removing comments that only restate obvious code
- replacing nested ternaries with clearer `if`/`else` chains or `switch` statements
- making control flow and data flow more explicit when compact code is harder to read

Choose readability over minimal line count.

Prefer the smallest refactor that resolves a real readability problem. Do not stack unrelated cleanups into one pass just because they are nearby.

## Refinement Procedure

After the three reviews complete:

1. Merge overlapping findings.
2. Drop false positives and low-value nits.
3. Mark the exact blocks worth simplifying.
4. Write down the concrete problem in one sentence for each accepted change.
5. Apply the simplest refactor that fixes that problem.
6. Re-read the result once for clarity and once for behavior risk.

If you cannot clearly explain why a change improves readability, do not make it.

Do not blindly implement every reviewer suggestion. The main session is responsible for judgment and patch coherence.

## Preserve Behavior

Do not change:

- runtime behavior
- output shapes or formatting
- public APIs
- side effects
- error semantics
- data flow relied on by callers
- performance characteristics when they appear intentional or sensitive

Avoid broad rewrites, speculative cleanup, and style churn outside the touched scope.

Do not treat "looks cleaner" as sufficient justification. The burden is to make the code easier to understand without changing what it means.

## Verification

After edits, run the smallest relevant verification available, such as:

- targeted tests for the affected module
- lint or typecheck for the touched files
- build steps only when needed to confirm no regression

If verification cannot be run, say so explicitly and explain why.

For deep or parallel `/simplify` passes, verify both:

- the code still behaves correctly
- the intended simplification actually landed in the final code rather than moving complexity around

## Response Style

Report:

- what was simplified
- which execution mode was used
- how behavior was preserved
- what verification ran
- any remaining uncertainty

Keep the explanation brief unless the user asks for a deeper walkthrough.
