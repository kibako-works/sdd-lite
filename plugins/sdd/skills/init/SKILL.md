---
name: init
description: Set up lightweight SDD (CLAUDE.md, docs/design/, docs/adr/) in the current project
argument-hint: [project root (defaults to the current directory)]
disable-model-invocation: true
allowed-tools: Read(/${CLAUDE_SKILL_DIR}/*)
metadata:
  kit: sdd
  reviewed: 2026-10-22
  retire-when: Delete when Claude Code's built-in /init or similar generates the design doc and ADR directories and a development flow template
---
Target: $ARGUMENTS

Language: write the generated files in the language that the project's CLAUDE.md (or AGENTS.md) specifies for documents; if it specifies none, use the language of the conversation. The templates are in English: translate the headings and placeholders into that language, but keep the `- Status:` lines (both the label and the values) and the `- [ ]` / `- [x]` checkboxes in English exactly as they are, because other sdd skills detect them. When you create a new CLAUDE.md, fill in its documents language line with the language you write it in.

1. Decide the target project root (the argument if given; otherwise the git root or the current directory).
2. If CLAUDE.md doesn't exist, draft one from the template at `${CLAUDE_SKILL_DIR}/claude-md-template.md`, filling in what you can learn by examining the repository (tech stack, commands, main directories). If it exists, don't overwrite it; draft a diff that appends only what is missing from the "Development flow" and "Design decisions" sections (or the sections with the same role, whatever language they are written in).
3. Draft creating docs/design/ and docs/adr/, and creating docs/adr/0001-record-architecture-decisions.md from the template at `${CLAUDE_SKILL_DIR}/adr-0001.md` with today's date. If docs/adr/ already exists, skip this and report it.
4. Show all drafts, and write them only after the user approves. Don't commit.
