# Security Policy

## Reporting a vulnerability

Please don't report vulnerabilities in public issues, pull requests, or discussions.

Report them privately through GitHub's private vulnerability reporting:
[Report a vulnerability](https://github.com/kibako-works/sdd-lite/security/advisories/new) (or open the **Security** tab and select **Report a vulnerability**).

Include what you can of the following:

- The affected file (skill, agent definition, supporting file, or manifest) and version
- What an attacker can do, and the steps to reproduce it
- The Claude Code version you tested with

You will get a first response within 14 days. This project is maintained by one person in their spare time, so a fix may take longer. Once a fix is released, the advisory is published, and you are credited unless you ask not to be.

## Scope

This repository distributes instructions for Claude Code rather than executable programs. The following are in scope:

- Skill and agent instructions (`plugins/sdd/skills/*/SKILL.md`, `plugins/sdd/agents/*.md`) and their supporting files, for example instructions that make Claude run commands, read files outside the skill's own directory, or send data somewhere without the user's approval
- `allowed-tools` and other permissions the skills declare, if they grant more than the skill needs
- The marketplace and plugin manifests (`.claude-plugin/marketplace.json`, `plugins/sdd/.claude-plugin/plugin.json`)
- The repository's GitHub Actions workflows

The following are out of scope:

- Vulnerabilities in Claude Code itself. Report them to Anthropic.
- Content that Claude generates in your project when you use the skills, unless the skills' instructions cause the problem

## Supported versions

Only the latest release receives security fixes. Update the plugin to get them.
