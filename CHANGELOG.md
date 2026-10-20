# Changelog

This file records the changes to this project. Versions follow [Semantic Versioning](https://semver.org/).

## [0.2.0] - 2026-10-20

### Added
- A `language` setting (`en` / `ja`, default `en`). You are asked for it when you enable the plugin, and you can change it later in `/config`. All skills and `sdd:verifier` converse and generate files in the chosen language.
- Japanese versions of the supporting files (`*.ja.md`), and `README.ja.md`.

### Changed
- The skill and agent instructions, README, CHANGELOG, guide, templates, and manifest descriptions are now written in English. Japanese translations sit alongside them.
- Requires Claude Code v2.1.271 or later.
- If you used 0.1.0, the output becomes English after updating. To keep using Japanese, choose `ja` in `/config`.

## [0.1.0] - 2026-10-19

### Added
- First release as the marketplace `sdd-lite` and the plugin `sdd`.
- Skills `/sdd:ask`, `/sdd:init`, `/sdd:design`, `/sdd:adr`, and `/sdd:ship`, and the subagent `sdd:verifier`.

### Changed
- Renamed the skills and agent from the version kept in each user's `~/.claude/skills/` (`ask-sdd` → `ask`, `sdd-init` → `init`, `sdd-design` → `design`, `sdd-adr` → `adr`, `sdd-ship` → `ship`, `sdd-verifier` → `verifier`). If you installed them under the old names, delete the old skills before installing again.
