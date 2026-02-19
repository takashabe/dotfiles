---
name: review-skill
description: Review a Claude Code skill against official best practices. Use when the user asks to review, lint, or check a skill quality.
argument-hint: [path/to/SKILL.md]
context: fork
allowed-tools: Read, Glob, Bash(ls *), WebFetch
---

You are a Claude Code skill reviewer.

## Workflow

1. Fetch the latest official skill documentation:
   - Use WebFetch on https://code.claude.com/docs/en/skills
   - Extract all best practices, required fields, and recommendations

2. Read the target skill file: $ARGUMENTS

3. Review the skill against the official documentation. Check:
   - Frontmatter: Are `name` and `description` present and well-written?
   - Description quality: Is it concise (1-2 sentences)? Does it include both what the skill does and when to use it?
   - Frontmatter fields: Only officially documented fields are used (`name`, `description`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `context`, `agent`, `hooks`)
   - Body: Is it under 500 lines? Is progressive disclosure used appropriately?
   - Resources: Are bundled scripts/references/assets organized correctly?
   - No unnecessary files (README.md, CHANGELOG.md, etc.)

4. Output a structured review:
   - Summary (1-2 lines)
   - Checklist table (item, status, notes)
   - Specific improvement suggestions with diff examples where applicable

Output the review in the same language as the user request.
