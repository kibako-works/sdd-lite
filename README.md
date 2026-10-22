# sdd-lite

English | [日本語](README.ja.md)

A marketplace that distributes `sdd`, a plugin for running lightweight SDD (developing with design docs and ADRs) with Claude Code.

## Overview

`sdd` is a plugin made of the following five skills and one subagent.

| Name | Role |
|---|---|
| `/sdd:ask` | Entry point when you're unsure which skill to use. Tells you the next step from the current state and the size of the change |
| `/sdd:init` | Sets up CLAUDE.md, `docs/design/`, and `docs/adr/` in a project |
| `/sdd:design` | Creates a design doc for a new feature or a medium or larger change |
| `/sdd:adr` | Records an ADR (decision record) |
| `/sdd:ship` | Runs verification, ADR checks, and commit and PR creation together at completion, scaled to the size of the change |
| `sdd:verifier` | Subagent that matches the requirements in a design doc against the implementation and tests |

There are other tools for spec-driven development, but this was made as a lighter alternative that is easier to start with. It uses Claude Code's built-in features (Plan Mode, `/simplify`, `/code-review`, and so on) as they are wherever possible, and adds skills only for what is missing. When a built-in feature covers the same thing, that skill is removed ([Retirement conditions](#retirement-conditions)).

## Prerequisites

- Tested with Claude Code v2.1.306.
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

- Only humans can start `/sdd:design` and `/sdd:init`. Claude can't start them, so when Claude points you to one, type it yourself.
- `/sdd:init` writes nothing until it shows its proposal and gets your approval. It doesn't commit either.
- When Claude itself calls `/sdd:ask` or `/sdd:adr`, you are asked to approve running the skill, because the skill has permission to read its own files (guide.md and templates). To skip the prompt, allow `Skill(sdd:ask)` and `Skill(sdd:adr)` in your permission settings (`/permissions`).
- `/sdd:ship` always gets approval before committing and creating a PR. Commit messages follow the project's conventions (CLAUDE.md or AGENTS.md), or Conventional Commits if there are none.
- `/sdd:ship` first declares the change's category in one line and skips steps a small change doesn't need. The category is A if there is an approved design doc, B if the branch adds an ADR, and C otherwise, and it is raised when the diff touches places such as runtime configuration, public APIs, dependencies, security, or places your CLAUDE.md lists (the full list is in ship's `SKILL.md`). To override it, run `/sdd:ship A` (or `B`, `C`). Details are in the [guide](plugins/sdd/skills/ask/guide.md).

## Retirement conditions

Each skill and agent is removed when a Claude Code built-in feature can take its place. The conditions are written in each file's frontmatter `metadata.retire-when`; the following table is a copy of them.

| Target | Retired when |
|---|---|
| `/sdd:ask` | A Claude Code built-in feature guides users to, or routes them among, the skills in a set, or when all other sdd skills have been removed |
| `/sdd:init` | Claude Code's built-in /init or similar generates the design doc and ADR directories and a development flow template |
| `/sdd:design` | Claude Code's built-in Plan Mode can save and approve a plan in design doc form as Markdown in the repository |
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
