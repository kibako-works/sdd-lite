---
name: ship
description: Verify, check ADRs, and create a PR
disable-model-invocation: false
metadata:
  kit: sdd
  reviewed: 2026-10-20
  retire-when: Delete when a Claude Code built-in feature or bundled skill can verify, check ADRs, commit, and create a PR in one go
---
Language: the configured language is `${user_config.language}`. If it is exactly `ja`, write all conversation and reports in Japanese. Otherwise (including when the value is empty or was not substituted), write in English. If Claude Code's own `language` setting tells you to always respond in a particular language, use that language for conversation and reports instead. Follow the project's conventions for the language of commit messages and PR bodies; if there are none, use the language chosen here.

1. With the sdd:verifier subagent, match the requirements in the design doc against the implementation and tests. If you need to check the app's behavior, you can also choose the bundled /verify skill. For a change without a design doc, pass the related ADRs and the Plan Mode plan file as the requirements.
2. Run the tests, lint, and type checks, and fix any failures.
3. Clean up the diff with Claude Code's bundled /simplify skill, and check the diff for bugs with the also-bundled /code-review skill.
4. Check whether any decision in this change that should be an ADR is missing, and if so, propose /sdd:adr.
5. If there is a design doc, update its task checkboxes and Status. For a change without one, check that related docs (README and so on) are updated.
6. In a directory not under git, stop here (no commit or PR). If you are on the default branch, create a working branch before committing. Show the changes, and commit and create the PR after the user approves. Follow the project's conventions (CLAUDE.md or AGENTS.md) for commit messages; if there are none, follow Conventional Commits. Use the gh CLI to create the PR, and include links to the design doc and ADRs in the PR body. Always get the user's approval before committing and creating the PR.
