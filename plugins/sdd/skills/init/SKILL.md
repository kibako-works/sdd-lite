---
name: init
description: Set up lightweight SDD (CLAUDE.md, docs/design/, docs/adr/) in the current project
argument-hint: [project root (defaults to the current directory)]
disable-model-invocation: true
allowed-tools: Read(/${CLAUDE_SKILL_DIR}/*)
metadata:
  kit: sdd
  reviewed: 2026-10-20
  retire-when: Delete when Claude Code's built-in /init or similar generates the design doc and ADR directories and a development flow template
---
Target: $ARGUMENTS

Language: the configured language is `${user_config.language}`. If it is exactly `ja`, write all conversation and generated files in Japanese and use `claude-md-template.ja.md` and `adr-0001.ja.md`. Otherwise (including when the value is empty or was not substituted), write in English and use `claude-md-template.md` and `adr-0001.md`. Below, "the CLAUDE.md template" and "the ADR 0001 template" mean the files chosen here.

1. Decide the target project root (the argument if given; otherwise the git root or the current directory).
2. If CLAUDE.md doesn't exist, draft one from the CLAUDE.md template at `${CLAUDE_SKILL_DIR}/`, filling in what you can learn by examining the repository (tech stack, commands, main directories). If it exists, don't overwrite it; draft a diff that appends only what is missing from the "Development flow" and "Design decisions" sections (or the sections with the same role, whatever language they are written in).
3. Draft creating docs/design/ and docs/adr/, and creating docs/adr/0001-record-architecture-decisions.md from the ADR 0001 template at `${CLAUDE_SKILL_DIR}/` with today's date. If docs/adr/ already exists, skip this and report it.
4. Show all drafts, and write them only after the user approves. Don't commit.
