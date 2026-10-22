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

# Design decisions
- Refer to docs/adr/ for past decisions. Don't implement anything that goes against an ADR whose Status is Accepted.
- If a change contradicts an ADR, propose a new ADR that marks the existing one as Superseded before implementing.

# Coding conventions
- Language of design docs and ADRs: <e.g. English>
- <list team-specific rules>

# Don'ts
- <add, one line at a time, mistakes Claude has made in the past>
