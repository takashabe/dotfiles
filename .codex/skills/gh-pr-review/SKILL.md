---
name: gh-pr-review
description: Review GitHub pull requests using the gh CLI. Use when a user asks for a PR review, architectural feedback, or wants a structured checklist and summary based on gh pr view/diff/comments or gh api pull request comments.
---

# GH PR Review

## Overview

Perform a structured PR review using gh commands and a consistent checklist.
Provide concise findings and questions tailored to the PR scope.

## Workflow

1. Identify the repo and PR number
   - Accept a PR URL or explicit `owner/repo` + PR number.
   - Ask only if missing.

2. Fetch PR metadata
   - `gh pr view <num> --repo owner/repo`
   - Use title/body, labels, reviewers, and stats to frame scope.

3. Fetch the diff
   - `gh pr diff <num> --repo owner/repo`
   - If diff is large, focus on critical files or API/DB changes first.

4. Fetch discussion context (optional)
   - `gh pr view <num> --repo owner/repo --comments`
   - `gh api repos/owner/repo/pulls/<num>/comments` for line threads.
   - Use when the user asks about a specific discussion or rationale.

5. Apply the standard review checklist
   - **Purpose/Scope**: Confirm intent and changes match the stated goal.
   - **Correctness**: Identify logic errors, edge cases, or state inconsistencies.
   - **Domain/Model**: Check invariants, naming, and aggregate boundaries.
   - **Data/DB**: Validate constraints, NULL rules, FK integrity, migrations.
   - **API/Compatibility**: Confirm request/response changes and version impact.
   - **Performance**: Watch for heavy queries, missing indexes, N+1.
   - **Ops/Observability**: Consider batch timing, retries, logging, metrics.
   - **Tests**: Ensure critical paths are covered; note missing tests.

6. Respond with a structured review
   - Prioritize issues by severity.
   - Cite file/line when available; otherwise point to section/topic.
   - Ask targeted questions when assumptions are unclear.
   - If the user asked for guidance only, do not post comments.

## Output Guidance

Follow the platform review style. Keep summaries short and lead with findings.
If the PR is a design-doc only, focus on architecture, data model, and risks.
