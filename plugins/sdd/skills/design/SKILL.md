---
name: design
description: Create a design doc for a new feature or a medium or larger change (run in Plan Mode)
argument-hint: <feature name or summary>
disable-model-invocation: true
allowed-tools: Read(/${CLAUDE_SKILL_DIR}/*)
metadata:
  kit: sdd
  reviewed: 2026-10-20
  retire-when: Delete when Claude Code's built-in Plan Mode can save and approve a plan in design doc form as Markdown in the repository
---
Target: $ARGUMENTS

Language: the configured language is `${user_config.language}`. If it is exactly `ja`, write all conversation and the design doc in Japanese and use `template.ja.md`. Otherwise (including when the value is empty or was not substituted), write in English and use `template.md`. Below, "the template" means the file chosen here. If Claude Code's own `language` setting tells you to always respond in a particular language, use that language for conversation instead; the generated files still follow the rule above.

Run this skill in Plan Mode.

0. If docs/design/ or docs/adr/ is missing, point the user to /sdd:init.
1. Read CLAUDE.md, the related code, and the Accepted ADRs in docs/adr/.
2. Ask about anything unclear in the requirements, scope, and constraints, one question at a time (don't fill gaps by guessing).
3. Summarize the plan following the template at `${CLAUDE_SKILL_DIR}/` (the file chosen above) and ask for approval.
4. After approval, save it as docs/design/YYYY-MM-<slug>.md with Status set to Approved.
5. If there are important decisions, such as a comparison of alternatives, propose recording them with /sdd:adr.
Don't write implementation code in this skill.
