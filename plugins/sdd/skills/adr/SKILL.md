---
name: adr
description: Record an ADR
argument-hint: <decision title>
disable-model-invocation: false
allowed-tools: Read(/${CLAUDE_SKILL_DIR}/*)
metadata:
  kit: sdd
  reviewed: 2026-11-02
  retire-when: Delete when Claude Code provides recording and numbering of ADRs (decision records) as a built-in feature
---
Target: $ARGUMENTS

Language: write the generated ADR in the language that the project's CLAUDE.md (or AGENTS.md) specifies for documents; if it specifies none, use the language of the conversation. The template is in English: translate the headings and placeholders into that language, but write the `- Status:` label and the chosen status value (for example `Approved` or `Accepted`) in English, and keep the `- [ ]` / `- [x]` checkboxes as they are, because other sdd skills detect them.

0. If docs/adr/ is missing, point the user to /sdd:init.
1. Choose the number as the highest number in docs/adr/ plus 1.
2. Following the template at `${CLAUDE_SKILL_DIR}/template.md`, draft the Context / Decision / Consequences from the conversation and the related design doc.
3. If it contradicts an existing ADR, name the ADR that should become Superseded.
4. Save it as docs/adr/NNNN-<slug>.md. If a task of an approved design doc or Plan Mode plan names this decision as an ADR to record, and it makes no ADR Superseded, save it without asking for approval and report the path. A decision that no task names is not covered, even during an approved plan. Otherwise, show the draft and save it only after approval.
