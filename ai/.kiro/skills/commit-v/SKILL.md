---
name: commit-v
description: Generate a verbose commit message with title and description body from staged changes and execute the commit. Use when the user types /commit-v.
---

# Commit Verbose (Title + Description)

Generate a commit message with title and detailed description body and execute the commit by default.

## Workflow

1. Run `git diff --cached --stat` and `git diff --cached` to review staged changes
2. If nothing is staged, inform the user and stop
3. Determine the appropriate type and scope following Conventional Commits format
4. Execute the commit with `git commit -m "<title>" -m "<body>"`
5. If the user's prompt contains `dryrun` (in any form, e.g., "dry run", "dry-run"), do NOT execute the commit — only output the proposed message for review

## Rules

- Follow Conventional Commits: `<type>(<scope>): <description>`
- Title: English, starts with lowercase, no trailing period, concise
- Body: Explain what was changed and the reasoning, use bullet points if multiple changes
- Omit scope if changes span multiple areas
