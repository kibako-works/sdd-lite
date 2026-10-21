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
| `/sdd:ship` | Runs verification, ADR checks, and commit and PR creation together at completion |
| `sdd:verifier` | Subagent that matches the requirements in a design doc against the implementation and tests |

There are other tools for spec-driven development, but this was made as a lighter alternative that is easier to start with. It uses Claude Code's built-in features (Plan Mode, `/simplify`, `/code-review`, and so on) as they are wherever possible, and adds skills only for what is missing. When a built-in feature covers the same thing, that skill is removed ([Retirement conditions](#retirement-conditions)).

## Prerequisites

- Claude Code v2.1.271 or later (required for the language options setting).
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

## Language setting

You can choose the language of the skills' conversation and of the files they generate (CLAUDE.md, design docs, ADRs): English (`en`) or Japanese (`ja`). The default is English.

- You are asked for the language when you enable the plugin.
- If you set Claude Code's own `language` setting, the conversation follows that setting instead, and this setting still decides the language of the generated files.
- To change it later, open `/config` and choose again in sdd's Language row.
- The setting is saved per user (`pluginConfigs["sdd@sdd-lite"].options.language` in your user settings). It can't be set per project.
- In the same repository, ADRs and design docs may end up in mixed languages depending on each user's setting. If you want them consistent, decide the language in your CLAUDE.md conventions and have everyone match their setting.
- If you used 0.1.0, updating switches the output to the default, English. To keep using Japanese, choose `ja` in `/config`.

## Usage

When in doubt, run `/sdd:ask` with what you want to do. It tells you the next command to type and the steps, based on the current state and the size of the change.

```
/sdd:ask I want to write a design doc
```

The overall flow, how to decide the size of a change, and when to use each skill are in [plugins/sdd/skills/ask/guide.md](plugins/sdd/skills/ask/guide.md). That file is the canonical source of the decision criteria ([ADR 0006](docs/adr/0006-i18n.md)). The Japanese translation is [guide.ja.md](plugins/sdd/skills/ask/guide.ja.md).

## Notes

- Only humans can start `/sdd:design` and `/sdd:init`. Claude can't start them, so when Claude points you to one, type it yourself.
- `/sdd:init` writes nothing until it shows its proposal and gets your approval. It doesn't commit either.
- When Claude itself calls `/sdd:ask` or `/sdd:adr`, you are asked to approve running the skill, because the skill has permission to read its own files (guide.md and templates). To skip the prompt, allow `Skill(sdd:ask)` and `Skill(sdd:adr)` in your permission settings (`/permissions`).
- `/sdd:ship` always gets approval before committing and creating a PR. Commit messages follow the project's conventions (CLAUDE.md or AGENTS.md), or Conventional Commits if there are none.

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
2. Delete the skill, and fix the tables in the README (English and Japanese), the steps and command list in guide.md and guide.ja.md, and the templates. When removing `ask`, move the content of the guide back into the README or elsewhere.
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
