## Summary

<!-- What does this change and why? Link the issue it addresses. -->

Closes #

## Design doc and ADRs

<!-- A new feature or a medium or larger change needs an approved design doc in docs/design/. -->

- Design doc: <!-- docs/design/... or "not needed (small fix)" -->
- ADRs: <!-- docs/adr/... added or affected, or "none" -->

## Security checklist

If you check any of these, explain why in the pull request.

- [ ] This changes `allowed-tools`, `tools`, or other permissions in a skill or agent.
- [ ] This adds or changes instructions that make Claude run shell commands.
- [ ] This adds or changes paths that a skill reads or writes outside its own directory.
- [ ] This changes `.github/` (workflows, CODEOWNERS, templates).

## Verification

- [ ] `claude plugin validate --strict .` passes with no warnings.
- [ ] I tried the change with `claude --plugin-dir ./plugins/sdd`.
- [ ] If I changed `README.md`, I updated `README.ja.md` in the same change, or I asked the maintainer to.
