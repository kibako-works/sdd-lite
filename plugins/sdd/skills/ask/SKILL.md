---
name: ask
description: Entry point for lightweight SDD (the sdd plugin's skills, design docs, and ADRs). Call it as "/sdd:ask <what you want to do>", or with no arguments, and it tells you which sdd skill and steps to use next, based on the current state and the size of the change. Use it when asked how to proceed with lightweight SDD - where to start, what to do next, or which skill to use.
argument-hint: [what you want to do (omit to get the next step from the current state)]
disable-model-invocation: false
allowed-tools: Read(/${CLAUDE_SKILL_DIR}/*)
metadata:
  kit: sdd
  reviewed: 2026-10-20
  retire-when: Delete when a Claude Code built-in feature guides users to, or routes them among, the skills in a set, or when all other sdd skills have been removed
---
Target: $ARGUMENTS

Language: the configured language is `${user_config.language}`. If it is exactly `ja`, write all conversation in Japanese and read `guide.ja.md`. Otherwise (including when the value is empty or was not substituted), write in English and read `guide.md`. Below, "the guide" means the file chosen here.

This skill only gives guidance. It doesn't run skills or write files. Base the guidance only on the criteria in the guide. For anything not in the guide (including requests unrelated to how to proceed with lightweight SDD), say it is outside the scope of sdd and stop. Don't guess and recommend other tools or skills.

1. Read the guide at `${CLAUDE_SKILL_DIR}/` (the file chosen above).
2. Collect the state needed for the table in section 6 of the guide. Don't read file contents; get only presence and counts, in as few calls as possible.
   - `ls -d CLAUDE.md docs/design docs/adr`
   - Approved design docs: `grep -l '^- Status: Approved' docs/design/*.md`. For each file found, count the unchecked tasks with `grep -cF -- '- [ ]' <file>`.
   - Under git: `git rev-parse --is-inside-work-tree`. If not, don't use the git commands below.
   - Uncommitted changes: `git status --porcelain`
   - Commits not on the default branch: find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD` (if that fails, whichever of `main` or `master` exists), and count with `git rev-list --count <default branch>..HEAD`. If you are on the default branch, count the commits not yet pushed upstream with `git rev-list --count @{u}..HEAD`.
   - If you can't decide from these, ask instead of guessing.
3. Use section 6 of the guide (the table and "Use the request text") to decide where the user is and the next step.
4. If you asked a question, decide again from step 3 with the answer. Once decided, give guidance in this form and stop.
   - Where the user is, and why you decided so
   - The command to type next (ready to paste, with an example argument)
   - What to do before it (for example, enter Plan Mode)
   - Whether the command can only be started by a human
   - An overview of what follows
