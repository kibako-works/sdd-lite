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
   - The changes to look at: find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD` (if that fails, whichever of `main` or `master` exists). Look at the commits not on it (`<default branch>...HEAD`; if you are on the default branch, the commits not pushed upstream, `@{u}..HEAD`, or none if there is no upstream), the uncommitted changes (`git diff HEAD`), and the untracked files (`git status --porcelain`, lines starting with `??`).
   - Base category, from what was made while planning: A if a design doc in docs/design/ has `- Status: Approved` (if there are several, ask which one is the target); otherwise B if those changes add an ADR in docs/adr/ (including an untracked one); otherwise C.
   - Then read the content of those changes, ignoring whitespace (`git diff -w <range>` for each commit range above, and `git diff -w HEAD`), and read untracked files in full. Raise at most one step. If the base category is C, raise it to B if they touch configuration that changes runtime behavior, shared constants, a public API, a schema or migration, dependencies, or security (authentication, permissions, secrets, input validation), or a place that the project's CLAUDE.md lists as needing care. If the base category is B, raise it to A only if they touch such a place beyond what the added ADR covers. Never lower the category. Don't use the amount of change (line or file counts, `git diff --stat`) to decide.
   - In a directory not under git, there is no diff: use A if there is an Approved design doc, otherwise ask the user for the category.
   - If the Override above is A, B, or C, or the user names a category, use it instead. The user's choice takes precedence over raising and over "never lower".
   - Before the next step, state the category and the reason in one line (for example, "Category B: ADR 0012 was added; the diff doesn't touch anything that raises it."). Don't wait for approval; continue.
1. Match against requirements with the sdd:verifier subagent.
   - A: match the requirements in the design doc against the implementation and tests. If there is no design doc (raised to A), pass the Plan Mode plan file (by default in `~/.claude/plans/`, or in the `plansDirectory` setting) and the related ADRs as the requirements. If you can't tell which plan file is for this change, ask the user.
   - B: ask it to check only that the changes are consistent with the Accepted ADRs, and tell it which changes to read (the commands from step 0).
   - C: skip this step.
   - If you need to check the app's behavior, you can also choose the bundled /verify skill.
2. Run the tests, lint, and type checks, and fix any failures.
3. Clean up and review the diff with Claude Code's bundled skills.
   - /simplify: A always. B only if the diff adds functions, classes, or modules, or changes logic beyond a few lines (skip it for docs or configuration values only). C skip.
   - /code-review: every category. For C, run `/code-review low`; for A and B, don't pass a level.
   - If either rewrote anything, run step 2 again.
4. Check whether any decision in this change that should be an ADR is missing, and if so, propose /sdd:adr. If an ADR is added in category C, continue as category B and run step 1 for B.
5. If there is a design doc, update its task checkboxes and Status. For a change without one, check that related docs (README and so on) are updated.
6. In a directory not under git, stop here (no commit or PR). If you are on the default branch, create a working branch before committing. Show the changes, and commit and create the PR after the user approves. Follow the project's conventions (CLAUDE.md or AGENTS.md) for commit messages; if there are none, follow Conventional Commits. Write commit messages and the PR body in the language the conventions specify; if they specify none, use the language of the conversation. Use the gh CLI to create the PR, and include links to the design doc and ADRs in the PR body. Always get the user's approval before committing and creating the PR.
