# Contributing

Thanks for your interest in `sdd`. This file explains how to report problems and propose changes.

## Current status

Creating new issues and pull requests is limited to collaborators for now, while the contribution process is being set up. Until it opens:

- To report a bug or request a feature, comment on an existing issue if there is a related one. The maintainer will open a new issue for you if needed.
- To report a vulnerability, follow [SECURITY.md](SECURITY.md). Never report it in public.

## Reporting issues

- Use the issue forms (bug report or feature request). Blank issues are disabled.
- For a bug, include the Claude Code version (`claude --version`), the plugin version, the `language` setting, the command you ran, and what happened.
- Search existing issues first.

## Proposing changes

1. Open an issue first for anything larger than a small fix, so the direction can be agreed before you write it.
2. Fork the repository and create a branch.
3. Follow the development flow below.
4. Open a pull request and fill in the template.

Each person can have one open pull request at a time.

### Development flow

This project is developed with its own lightweight SDD flow. The rules are in [CLAUDE.md](CLAUDE.md) (in Japanese).

- A new feature or a medium or larger change needs a design doc in `docs/design/`, approved by the maintainer, before implementation.
- A decision that involves choosing a technology, changing the structure, or a trade-off is recorded as an ADR in `docs/adr/`. Don't make changes that contradict an Accepted ADR. If one needs to change, propose a new ADR that supersedes it.
- A small fix (about one file, with no design decision) doesn't need a design doc.

The maintainer may write the design doc or ADR for you, based on the discussion in the issue.

### Trying your changes locally

```bash
# Load the plugin from your working tree
claude --plugin-dir ./plugins/sdd

# Validate the marketplace and the plugin (must pass with no warnings)
claude plugin validate --strict .
```

### Conventions

- **Language**: user-facing files (README.md, CHANGELOG.md, SKILL.md, agent definitions, the skills' supporting files, and manifest descriptions) are written in English. The README and the skills' supporting files have Japanese translations (`<name>.ja.md`). Update the translation in the same change as the English file. If you can't write Japanese, say so in the pull request and the maintainer will update it. Design docs, ADRs, and CLAUDE.md are written in Japanese.
- **Commits**: [Conventional Commits](https://www.conventionalcommits.org/), `<type>(<scope>): <subject>`. The scope is the skill or agent name (`ask`, `init`, `design`, `adr`, `ship`, `verifier`), or `repo` for the whole repository. Subjects are written in Japanese in this repository. If you can't write Japanese, write the subject in English and the maintainer will adjust it.
- **Paths**: skills must not read outside their own directory, for example with paths that contain `..` or with shell expansion.
- **Permissions**: keep `allowed-tools` to the minimum the skill needs. Explain any change to it in the pull request.
- **Personal information**: don't add email addresses, absolute paths from your environment, or information about your employer.
- **Mermaid**: use `<br/>` for line breaks inside node labels, not `\n`.

### Review

- The maintainer reviews every pull request. Changes to `plugins/`, `.claude-plugin/`, and `.github/` require the code owner's review.
- CI runs `claude plugin validate --strict .` and checks for personal information and invisible Unicode characters. Workflows on pull requests from external contributors run only after the maintainer approves them.
- Pull requests that change `.github/` get extra scrutiny.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE), the same license as the project.
