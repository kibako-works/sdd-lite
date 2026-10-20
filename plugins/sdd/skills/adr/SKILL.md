---
name: adr
description: Record an ADR
argument-hint: <decision title>
disable-model-invocation: false
allowed-tools: Read(/${CLAUDE_SKILL_DIR}/*)
metadata:
  kit: sdd
  reviewed: 2026-10-20
  retire-when: Delete when Claude Code provides recording and numbering of ADRs (decision records) as a built-in feature
---
Target: $ARGUMENTS

Language: the configured language is `${user_config.language}`. If it is exactly `ja`, write all conversation and the ADR in Japanese and use `template.ja.md`. Otherwise (including when the value is empty or was not substituted), write in English and use `template.md`. Below, "the template" means the file chosen here. If Claude Code's own `language` setting tells you to always respond in a particular language, use that language for conversation instead; the generated files still follow the rule above.

0. If docs/adr/ is missing, point the user to /sdd:init.
1. Choose the number as the highest number in docs/adr/ plus 1.
2. Following the template at `${CLAUDE_SKILL_DIR}/` (the file chosen above), draft the Context / Decision / Consequences from the conversation and the related design doc.
3. If it contradicts an existing ADR, name the ADR that should become Superseded.
4. Show the draft, and after approval save it as docs/adr/NNNN-<slug>.md.
