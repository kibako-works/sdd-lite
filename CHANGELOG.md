# Changelog

This file records the changes to this project. Versions follow [Semantic Versioning](https://semver.org/).

## [0.5.0] - 2026-10-23

### Changed
- `/sdd:design` now leaves the questions, the plan, and its approval to Claude Code's Plan Mode. It only gives the plan the design doc form and has it saved after approval.
- The design doc template starts its implementation tasks with T0, which saves the plan as `docs/design/YYYY-MM-<slug>.md` with Status: Approved. The path is written in T0 while planning, so you can check the file name before approving, and the plan is saved even if you clear the context when approving. The plan file in `~/.claude/plans` is kept, and you don't need to set `plansDirectory`.
- The retirement condition of `/sdd:design` is now: Claude Code's built-in Plan Mode can save an approved plan in the repository under a chosen file name and mark it as approved.

## [0.4.0] - 2026-10-23

### Changed
- The decision criteria now say: when in doubt about the size of a change, choose the lower category and move up when needed. While planning, a design decision moves the change up to B (`/sdd:adr`), and requirements that need sorting out move it up to A (`/sdd:design`).
- `/sdd:ship` scales its steps to the change's category and declares the category in one line before starting. A (an approved design doc) runs all steps. B (an ADR added on the branch) has `sdd:verifier` check only consistency with ADRs and runs `/simplify` only when logic is added or changed. C (neither) skips `sdd:verifier` and `/simplify` and runs `/code-review low`. C is raised to B when the diff touches runtime configuration, shared constants, public APIs, schemas, dependencies, security, or places listed in your CLAUDE.md, and B is raised to A only when the diff touches such places beyond what the added ADR covers. The category is never lowered except by your override: `/sdd:ship <A|B|C>`.
- `sdd:verifier` can check only consistency with ADRs when asked.

## [0.3.0] - 2026-10-22

### Breaking changes
- Removed the plugin's `language` setting (`userConfig.language`). The conversation now follows Claude Code's own `language` setting, and generated files (CLAUDE.md, design docs, ADRs) and the commit messages and PR bodies from `/sdd:ship` follow the documents language in your project's CLAUDE.md (or AGENTS.md), or the language of the conversation if it has none.
- If you chose `ja` in 0.2.0: set Claude Code's `language` to `japanese` (in `/config` or `"language": "japanese"` in settings.json), and write the documents language in your project's CLAUDE.md if you want the documents in Japanese. You can delete `pluginConfigs["sdd@sdd-lite"].options.language` from your user settings.

### Changed
- Removed the Japanese versions of the skills' supporting files (`*.ja.md`). The templates are in English; their headings are translated when writing in another language, while the `- Status:` lines and `- [ ]` checkboxes stay as they are. `README.ja.md` remains.
- `/sdd:init` adds a line to CLAUDE.md that sets the language of documents (design docs, ADRs), commit messages, and PRs, also when it appends to an existing CLAUDE.md.
- Claude Code v2.1.271 or later is no longer required. Tested with v2.1.306.

## [0.2.0] - 2026-10-20

### Added
- A `language` setting (`en` / `ja`, default `en`). You are asked for it when you enable the plugin, and you can change it later in `/config`. All skills and `sdd:verifier` converse and generate files in the chosen language. If you set Claude Code's own `language` setting, the conversation follows that setting instead.
- Japanese versions of the supporting files (`*.ja.md`), and `README.ja.md`.

### Changed
- The skill and agent instructions, README, CHANGELOG, guide, templates, and manifest descriptions are now written in English. The README, the guide, and the templates have Japanese translations alongside them.
- Requires Claude Code v2.1.271 or later.
- If you used 0.1.0, the output becomes English after updating. To keep using Japanese, choose `ja` in `/config`.

## [0.1.0] - 2026-10-19

### Added
- First release as the marketplace `sdd-lite` and the plugin `sdd`.
- Skills `/sdd:ask`, `/sdd:init`, `/sdd:design`, `/sdd:adr`, and `/sdd:ship`, and the subagent `sdd:verifier`.

### Changed
- Renamed the skills and agent from the version kept in each user's `~/.claude/skills/` (`ask-sdd` → `ask`, `sdd-init` → `init`, `sdd-design` → `design`, `sdd-adr` → `adr`, `sdd-ship` → `ship`, `sdd-verifier` → `verifier`). If you installed them under the old names, delete the old skills before installing again.
