---
name: commit-s
description: Generate a concise commit message (title only) from staged changes and execute the commit. Use when the user types /commit-s.
---

# Commit Simple (Title Only)

Generate a concise commit message (title only) and execute the commit by default.

## Workflow

1. Run `git diff --cached --stat` and `git diff --cached` to review staged changes
2. If nothing is staged, inform the user and stop
3. Determine the appropriate type and scope following Conventional Commits format
4. Execute the commit with `git commit -m "<message>"`
5. If the user's prompt contains `dryrun` (in any form, e.g., "dry run", "dry-run"), do NOT execute the commit — only output the proposed message for review

## Rules

- Follow Conventional Commits: `<type>(<scope>): <description>`
- Description in English, starts with lowercase, no trailing period
- Keep it concise — one line only, no body/description
- Omit scope if changes span multiple areas
