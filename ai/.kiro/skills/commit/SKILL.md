---
name: commit
description: Generate a commit message (title only) from staged changes and execute the commit. Use when the user types /commit.
---

# Commit (Title Only)

Generate a concise commit message and execute the commit.

## Workflow

1. Run `git diff --cached --stat` and `git diff --cached` to review staged changes
2. If nothing is staged, inform the user and stop
3. Determine the appropriate type and scope following Conventional Commits format
4. Output the commit message (title only) for the user to review — do NOT execute `git commit`

## Rules

- Follow Conventional Commits: `<type>(<scope>): <description>`
- Description in English, starts with lowercase, no trailing period
- Keep it concise — one line only, no body/description
- Omit scope if changes span multiple areas
