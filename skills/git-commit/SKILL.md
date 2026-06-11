---
name: git-commit
description: 'Fast git commit with conventional commit message. Speed is the only goal — minimal diff analysis, no deep code understanding, single-line message, immediate execution. Use when user asks to commit changes, create a git commit, or mentions "/commit".'
license: MIT
allowed-tools: Bash
---

# Fast Git Commit

## Goal

**Speed only.** Do NOT deeply analyze code. Do NOT read files. Generate a good-enough conventional commit message from minimal context and commit immediately. No questions, no confirmation, no extra passes.

## Workflow (2 commands total)

### 1. One combined look (single Bash call)

```bash
git status --porcelain && git diff --stat HEAD && git diff HEAD | head -200
```

- File names + stat are usually enough to pick type/scope. Only skim the truncated diff if the type is unclear.
- Never run a full `git diff` without truncation. Never inspect file contents beyond this.

### 2. Stage + commit (single Bash call)

```bash
git add <changed files by name> && git commit -m "<type>(<scope>): <description>"
```

- If files are already staged, commit only those — skip `git add`.
- If nothing is staged, stage ALL changed files by name in one `git add` (do not split into multiple logical commits — one commit, done).
- Skip `.env`, `credentials.json`, `*.pem`, key files when staging.

## Message Rules

- Format: `<type>(<scope>): <description>` — single line only. No body, no footer, unless the user explicitly asks.
- Types: `feat` `fix` `docs` `style` `refactor` `perf` `test` `build` `ci` `chore` `revert`
- Scope: top-level directory or module name from the file paths. Omit if mixed/unclear — don't deliberate.
- Description: present tense, imperative, <72 chars.
- When type is ambiguous between two options, pick the more likely one and move on. Never ask the user.

## Hard Rules

- Max 2 Bash calls in the happy path. No Read/Grep/exploration tools.
- NEVER update git config, force push, hard reset, or skip hooks (--no-verify).
- If a pre-commit hook fails: fix minimally, re-stage, create a NEW commit (never --amend).
- Do not push unless asked.
