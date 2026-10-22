---
name: ship
description: Verify, check ADRs, and create a PR, with steps scaled to the change's category (A / B / C)
argument-hint: [A|B|C to override the category]
disable-model-invocation: false
metadata:
  kit: sdd
  reviewed: 2026-10-23
  retire-when: Delete when a Claude Code built-in feature or bundled skill can verify, check ADRs, commit, and create a PR in one go
---
Override: $ARGUMENTS

0. Decide the category and declare it.
   - Base category, from what was made while planning: A if a design doc in docs/design/ has `- Status: Approved` (if there are several, ask which one is the target); otherwise B if an ADR was added in docs/adr/ on this branch (in the commits not on the default branch, or in uncommitted changes); otherwise C.
   - Then read the content of the diff, ignoring whitespace (`git diff -w <default branch>...HEAD` and `git diff -w HEAD`). If it touches configuration values, shared constants, a public API, a schema or migration, dependencies, or security (authentication, permissions, secrets, input validation), or a place that the project's CLAUDE.md lists as needing care, raise the category by one. Never lower it. Don't use the amount of change (line or file counts, `git diff --stat`) to decide.
   - In a directory not under git, there is no diff: use A if there is an Approved design doc, otherwise ask the user for the category.
   - If the Override above is A, B, or C, or the user names a category, use it instead.
   - Before the next step, state the category and the reason in one line (for example, "Category B: ADR 0012 was added; the diff doesn't touch anything that raises it."). Don't wait for approval; continue.
1. Match against requirements with the sdd:verifier subagent.
   - A: match the requirements in the design doc against the implementation and tests. If there is no design doc (raised to A), pass the Plan Mode plan file and the related ADRs as the requirements.
   - B: ask it to check only that the diff is consistent with the Accepted ADRs.
   - C: skip this step.
   - If you need to check the app's behavior, you can also choose the bundled /verify skill.
2. Run the tests, lint, and type checks, and fix any failures.
3. Clean up and review the diff with Claude Code's bundled skills.
   - /simplify: A always. B only if the diff adds functions, classes, or modules, or changes logic beyond a few lines (skip it for docs or configuration values only). C skip.
   - /code-review: every category. For C, run `/code-review low`; for A and B, don't pass a level.
   - If either rewrote anything, run step 2 again.
4. Check whether any decision in this change that should be an ADR is missing, and if so, propose /sdd:adr.
5. If there is a design doc, update its task checkboxes and Status. For a change without one, check that related docs (README and so on) are updated.
6. In a directory not under git, stop here (no commit or PR). If you are on the default branch, create a working branch before committing. Show the changes, and commit and create the PR after the user approves. Follow the project's conventions (CLAUDE.md or AGENTS.md) for commit messages; if there are none, follow Conventional Commits. Write commit messages and the PR body in the language the conventions specify; if they specify none, use the language of the conversation. Use the gh CLI to create the PR, and include links to the design doc and ADRs in the PR body. Always get the user's approval before committing and creating the PR.
