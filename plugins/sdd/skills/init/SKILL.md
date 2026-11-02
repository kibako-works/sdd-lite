---
name: init
description: Set up lightweight SDD (CLAUDE.md, docs/design/, docs/adr/) in the current project
argument-hint: [project root (defaults to the current directory)]
disable-model-invocation: true
allowed-tools: Read(/${CLAUDE_SKILL_DIR}/*)
metadata:
  kit: sdd
  reviewed: 2026-11-02
  retire-when: Delete when Claude Code's built-in /init or similar generates the design doc and ADR directories and a development flow template
---
Target: $ARGUMENTS

Language: write the generated files in the language that the project's CLAUDE.md (or AGENTS.md) specifies for documents; if it specifies none, use the language of the conversation. The templates are in English: translate the headings and placeholders into that language, but write the `- Status:` label and the chosen status value (for example `Approved` or `Accepted`) in English, and keep the `- [ ]` / `- [x]` checkboxes as they are, because other sdd skills detect them. When you create a new CLAUDE.md, fill in its language line with the language you write it in.

1. Decide the target project root (the argument if given; otherwise the git root or the current directory).
2. If CLAUDE.md doesn't exist, draft one from the template at `${CLAUDE_SKILL_DIR}/claude-md-template.md`, filling in what you can learn by examining the repository (tech stack, commands such as package.json scripts, main directories). If it exists, don't overwrite it; draft a diff that appends only what is missing from the "Common commands", "Development flow", "Design decisions", and "Places needing care" sections (or the sections with the same role, whatever language they are written in). Fill in a missing "Common commands" from the repository, and leave existing lines as they are. Fill in a missing "Places needing care" with the risky paths you find (such as infrastructure, migrations, CI workflows), or "none"; the user corrects it when reviewing the drafts. Write the additions in the language of the existing CLAUDE.md, and if it has no line that sets the language of documents, include the template's language line in the diff, filled in with the language of the existing CLAUDE.md.
3. Draft creating docs/design/ and docs/adr/, and creating docs/adr/0001-record-architecture-decisions.md from the template at `${CLAUDE_SKILL_DIR}/adr-0001.md` with today's date. If docs/adr/ already exists, skip this and report it.
4. Show all drafts, and write them only after the user approves. Don't commit.
