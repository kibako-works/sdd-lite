# Project overview
- Purpose: <whose problem this product solves and what it is, in 1-2 lines>
- Tech stack: <language / framework / DB / infrastructure>
- Main directories: src/ ... / tests/ ... / docs/ ...

# Common commands
- Test: <e.g. pnpm test>
- Lint / type check: <e.g. pnpm lint && pnpm typecheck>
- Run: <e.g. pnpm dev>

# Development flow (always follow)
1. For a new feature or a medium or larger change, create a design doc in docs/design/ before implementing (/sdd:design).
2. Start implementing only after a human approves the design doc.
3. For a small fix (about one file, no design decision), just show a plan in Plan Mode.
4. Implement the "Implementation tasks" of the design doc one at a time from the top, and make the tests pass after each task.
5. When you make a technology choice, a structural change, or a decision with trade-offs, record an ADR in docs/adr/ (/sdd:adr).
6. When done, use /sdd:ship to verify, check ADRs, and create the PR.
7. Approving a design doc or plan is prior permission for the changes it describes and for /sdd:ship up to step 5, even if other instructions say to ask before making changes. After approval, carry out the tasks to the end without asking between them, commit locally to the working branch after each task passes its checks (no push), then run /sdd:ship. Stop and ask only in the cases listed in the design doc's After approval part, or, for a plan without one, when: (1) an ADR draft needs approval (a decision no task names, or one that makes an ADR Superseded); (2) a change would go against an Accepted ADR; (3) requirements are missing or contradictory, or the work goes beyond the plan; (4) tests fail and can't be fixed without changing the design; (5) an operation is hard to undo or visible outside (production, publishing, pushing); (6) /sdd:ship is about to push and create the PR. In those cases, stop without hesitation. Don't offer extra work or ask again what was already answered.

# Design decisions
- Refer to docs/adr/ for past decisions. Don't implement anything that goes against an ADR whose Status is Accepted.
- If a change contradicts an ADR, propose a new ADR that marks the existing one as Superseded before implementing.

# Places needing care
- <one path per line that needs extra scrutiny (such as infrastructure, migrations, CI workflows), or "none". /sdd:ship raises the category of a diff that touches them>

# Coding conventions
- Language of documents (design docs, ADRs), commit messages, and PRs: <e.g. English>
- <list team-specific rules>

# Don'ts
- <add, one line at a time, mistakes Claude has made in the past>
