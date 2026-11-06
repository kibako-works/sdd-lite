---
name: design
description: Give a Plan Mode plan the design doc form, and save it in docs/design/ after approval, for a new feature or a medium or larger change (run in Plan Mode)
argument-hint: <feature name or summary>
disable-model-invocation: true
allowed-tools: Read(/${CLAUDE_SKILL_DIR}/*)
metadata:
  kit: sdd
  reviewed: 2026-11-06
  retire-when: Delete when Claude Code's built-in Plan Mode can save an approved plan in the repository under a chosen file name and mark it as approved
---
Target: $ARGUMENTS

Language: write the generated design doc in the language that the project's CLAUDE.md (or AGENTS.md) specifies for documents; if it specifies none, use the language of the conversation. The template is in English: translate the headings and placeholders into that language, but write the `- Status:` label and the chosen status value (for example `Approved` or `Accepted`) in English, and keep the `- [ ]` / `- [x]` checkboxes as they are, because other sdd skills detect them.

Run this skill in Plan Mode. Plan Mode handles the questions, the plan, and its approval. This skill only gives the plan the design doc form and has it saved after approval.

0. If you are not in Plan Mode, tell the user to enter Plan Mode (Shift+Tab) and run /sdd:design again, and stop. If docs/design/ or docs/adr/ is missing, point the user to /sdd:init.
1. Write the plan file following the template at `${CLAUDE_SKILL_DIR}/template.md`, with Status set to Draft. In T0, write the concrete path `docs/design/YYYY-MM-<slug>.md`, using today's year and month. Check that the plan doesn't contradict the Accepted ADRs in docs/adr/. If the plan has important decisions, such as a comparison of alternatives, add a task right after T0 to record them with /sdd:adr. When you ask for approval, tell the user in one or two sentences that after approval you will carry on without stopping up to just before the PR, and that the only stops are listed in the plan's After approval part (in section 5).
2. After the plan is approved, do T0 before anything else: copy the plan file to that path, set Status to Approved, and check T0. Don't delete the plan file. Then go straight on to T1 and follow the plan's After approval part: the approval is the user's prior permission for the changes the plan describes, even if the user's settings or CLAUDE.md say to ask before making changes. Stop only in the cases that part lists. When all tasks are done, run /sdd:ship. If the context was summarized, read the saved design doc again before continuing.
