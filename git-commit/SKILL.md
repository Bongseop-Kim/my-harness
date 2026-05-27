---
name: git-commit
description: Use when the user wants the agent to inspect the current git working tree and create a single commit from existing changes, especially after completing a small task or preparing a clean checkpoint.
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
---

# Git Commit

## Overview

Inspect the current repository state, stage the intended changes, and create one commit that accurately reflects the diff. Keep the workflow narrow and avoid unrelated actions.

## Gather Context

Collect the current state with:

- `git status`
- `git diff HEAD`
- `git branch --show-current`
- `git log --oneline -10`

Use that context to understand:

- which files changed
- whether anything is already staged
- the branch context
- the recent commit style to mirror when useful

## Create the Commit

1. Review the diff and infer the smallest honest summary of the current changes.
2. Stage the files that belong in this single commit.
3. Write one commit message that describes the change clearly and specifically.
4. Create the commit.

Default to a single concise subject line unless the repository convention clearly calls for another format.

## Guardrails

- Do not edit files as part of this skill.
- Do not run unrelated commands.
- Do not split the work into multiple commits unless the user explicitly asks.
- Do not invent changes that are not present in the diff.
- If the working tree contains unrelated changes and separation is ambiguous, stop and ask the user before committing.

## Output Behavior

When executing this skill, perform the staging and commit workflow directly. Prefer tool calls over explanation. If the environment allows tool-only responses for the task, use them.

## Commit Message Guidance

- summarize the actual change, not the process
- match the repo's tone when visible from recent commits
- stay specific enough that `git log --oneline` remains useful
- avoid vague messages such as `update`, `fix stuff`, or `changes`

If the diff is too broad to name honestly in one line, ask for guidance instead of forcing a low-quality commit.
