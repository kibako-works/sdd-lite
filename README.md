# sdd-lite

English | [日本語](README.ja.md)

A marketplace that distributes `sdd`, a plugin for running lightweight SDD (developing with design docs and ADRs) with Claude Code.

## Overview

`sdd` is a plugin made of the following five skills and one subagent.

| Name | Role |
|---|---|
| `/sdd:ask` | Entry point when you're unsure which skill to use. Tells you the next step from the current state and the size of the change |
| `/sdd:init` | Sets up CLAUDE.md, `docs/design/`, and `docs/adr/` in a project |
| `/sdd:design` | Gives a Plan Mode plan the design doc form for a new feature or a medium or larger change, and saves it in `docs/design/` after approval |
| `/sdd:adr` | Records an ADR (decision record) |
| `/sdd:ship` | Runs verification, ADR checks, and commit and PR creation together at completion, scaled to the size of the change |
| `sdd:verifier` | Subagent that matches the requirements in a design doc against the implementation and tests |

There are other tools for spec-driven development, but this was made as a lighter alternative that is easier to start with. It uses Claude Code's built-in features (Plan Mode, `/simplify`, `/code-review`, and so on) as they are wherever possible, and adds skills only for what is missing. When a built-in feature covers the same thing, that skill is removed ([Retirement conditions](#retirement-conditions)).

## Prerequisites

- Tested with Claude Code v2.1.308.
- The completion steps use Claude Code's bundled skills `/simplify` and `/code-review` (and `/verify` if you need to check the app's behavior).
- `/sdd:ship` uses the [GitHub CLI (gh)](https://cli.github.com/) to create PRs.

## Installation

Run these two commands in Claude Code.

```
/plugin marketplace add kibako-works/sdd-lite
/plugin install sdd@sdd-lite
```

You can update and remove it from the `/plugin` screen. From a terminal, you can also use these commands.

```bash
# Update (refresh the marketplace, then update the plugin)
claude plugin marketplace update sdd-lite
claude plugin update sdd@sdd-lite

# Remove
claude plugin uninstall sdd@sdd-lite
claude plugin marketplace remove sdd-lite
```

### Cloud sessions (claude.ai/code)

A cloud session doesn't install the plugins your repository turns on in `.claude/settings.json`, or the ones only in your user settings. To use sdd there, add it to your claude.ai account: add the `kibako-works/sdd-lite` marketplace and turn on sdd under Customize > Plugins on claude.ai. It then loads as `sdd@synced`, in cloud sessions and in terminal sessions where you sign in with your claude.ai account. The official docs state the terminal part; loading in cloud sessions is what we observed on 2026-11-02.

If you also installed `sdd@sdd-lite` from the marketplace, that copy loads in your terminal and the synced copy doesn't. To use the same copy everywhere, turn `sdd@sdd-lite` off with `"sdd@sdd-lite": false` under `enabledPlugins` in your user settings (or in `.claude/settings.local.json` for one project), or uninstall it. Don't put it in the committed `.claude/settings.json`: it would turn sdd off for collaborators who installed it only from the marketplace.

## Language

sdd has no language setting of its own.

- The conversation follows Claude Code's own `language` setting. Set it in `/config`, or add `"language": "japanese"` (for example) to your settings.json. Without it, Claude answers in the language you write in.
- The files the skills generate (CLAUDE.md, design docs, ADRs) and the commit messages and PR bodies from `/sdd:ship` follow the documents language in your project's CLAUDE.md (or AGENTS.md). If it has none, they are written in the language of the conversation. `/sdd:init` adds a line for this to your CLAUDE.md.
- The templates are in English. When writing in another language, the headings are translated, but the `- Status:` lines and `- [ ]` checkboxes stay in English, because the skills use them to find where you are.
- If you chose `ja` in 0.2.0, that setting no longer has any effect. Set Claude Code's `language` to `japanese` instead, and if you want the project's documents in Japanese, write that in your CLAUDE.md. You can delete `pluginConfigs["sdd@sdd-lite"].options.language` from your user settings.

## Usage

When in doubt, run `/sdd:ask` with what you want to do. It tells you the next command to type and the steps, based on the current state and the size of the change.

```
/sdd:ask I want to write a design doc
```

The overall flow, how to decide the size of a change, and when to use each skill are in [plugins/sdd/skills/ask/guide.md](plugins/sdd/skills/ask/guide.md). That file is the canonical source of the decision criteria ([ADR 0010](docs/adr/0010-native-language.md)).

## Notes

- Only humans can start `/sdd:design` and `/sdd:init`. Claude can't start them, so when Claude points you to one, type it yourself: type the command first, then paste the argument. Pasting the whole line doesn't start the command.
- Approving a design doc or plan is your prior permission for the changes it describes and for `/sdd:ship` up to step 5, even if your settings or CLAUDE.md say to ask before changes. After approval, Claude carries out the tasks without asking between them, commits locally to the working branch after each task passes its checks (no push), and then runs `/sdd:ship`. It stops only in the cases listed in the After approval part of the design doc: an ADR draft that needs approval, a conflict with an Accepted ADR, missing or contradictory requirements or work beyond the plan, test failures that need a design change, operations that are hard to undo or visible outside (production, publishing, pushing), and just before pushing and creating the PR. An ADR that the plan includes as a task is saved without asking; review it with the PR. `/sdd:init` writes the same rule into a new CLAUDE.md; if your CLAUDE.md already has "Development flow", replace or add rule 7 of the [template](plugins/sdd/skills/init/claude-md-template.md) yourself, so that it also applies to plans without a design doc.
- Run `/sdd:design` in Plan Mode. Plan Mode asks the questions and approves the plan. The plan's first task, T0, saves it as `docs/design/YYYY-MM-<slug>.md` with Status: Approved, so it is saved even if you clear the context when approving. You don't need to set `plansDirectory`; if you do, don't point it at `docs/design/`, or draft plans pile up there.
- `/sdd:init` writes nothing until it shows its proposal and gets your approval. It doesn't commit either. For an existing CLAUDE.md, it proposes only the sections that are missing.
- When Claude itself calls `/sdd:ask` or `/sdd:adr`, you are asked to approve running the skill, because the skill has permission to read its own files (guide.md and templates). To skip the prompt, allow `Skill(sdd:ask)` and `Skill(sdd:adr)` in your permission settings (`/permissions`).
- `/sdd:ship` always gets approval before pushing and creating a PR. It shows all the changes, including the commits made at task boundaries. Commit messages follow the project's conventions (CLAUDE.md or AGENTS.md), or Conventional Commits if there are none.
- `/sdd:ship` first declares the change's category in one line and skips steps a small change doesn't need. The category is A if there is an approved design doc, B if the branch adds an ADR, and C otherwise, and it is raised when the diff touches places such as runtime configuration, public APIs, dependencies, security, or the "Places needing care" in your CLAUDE.md (the full list is in ship's `SKILL.md`). To override it, run `/sdd:ship A` (or `B`, `C`). Details are in the [guide](plugins/sdd/skills/ask/guide.md).

## Retirement conditions

Each skill and agent is removed when a Claude Code built-in feature can take its place. The conditions are written in each file's frontmatter `metadata.retire-when`; the following table is a copy of them.

| Target | Retired when |
|---|---|
| `/sdd:ask` | A Claude Code built-in feature guides users to, or routes them among, the skills in a set, or when all other sdd skills have been removed |
| `/sdd:init` | Claude Code's built-in /init or similar generates the design doc and ADR directories and a development flow template |
| `/sdd:design` | Claude Code's built-in Plan Mode can save an approved plan in the repository under a chosen file name and mark it as approved |
| `/sdd:adr` | Claude Code provides recording and numbering of ADRs (decision records) as a built-in feature |
| `/sdd:ship` | A Claude Code built-in feature or bundled skill can verify, check ADRs, commit, and create a PR in one go |
| `sdd:verifier` | A Claude Code built-in or bundled agent or skill can verify the implementation and tests against the requirements in a design doc |

## How to retire

1. Confirm that the built-in feature has arrived.
2. Delete the skill, and fix the tables in the README (English and Japanese), the steps and command list in guide.md, and the templates. When removing `ask`, move the content of the guide back into the README or elsewhere.
3. Bump `version` in `plugin.json` and release.
4. Users get the change by updating the plugin.

## More

- Decision criteria and when to use each skill: [plugins/sdd/skills/ask/guide.md](plugins/sdd/skills/ask/guide.md)
- Design decisions: [docs/adr/](docs/adr/) (in Japanese)
- Changelog: [CHANGELOG.md](CHANGELOG.md)
- Contributing: [CONTRIBUTING.md](CONTRIBUTING.md)
- Reporting a vulnerability: [SECURITY.md](SECURITY.md)

## License

[MIT](LICENSE)
