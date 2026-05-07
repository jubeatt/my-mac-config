---
name: commitA
description: Generate a commit message with title and description body from staged changes and execute the commit. Use when the user types /commitA.
---

# Commit (Title + Description)

Generate a commit message with title and detailed description body, then execute the commit.

## Workflow

1. Run `git diff --cached --stat` and `git diff --cached` to review staged changes
2. If nothing is staged, inform the user and stop
3. Determine the appropriate type and scope following Conventional Commits format
4. Output the commit message (title + body) for the user to review — do NOT execute `git commit`

## Rules

- Follow Conventional Commits: `<type>(<scope>): <description>`
- Title: English, starts with lowercase, no trailing period, concise
- Body: Explain what was changed and the reasoning, use bullet points if multiple changes
- Omit scope if changes span multiple areas
