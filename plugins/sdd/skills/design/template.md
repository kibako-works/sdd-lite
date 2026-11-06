# <Feature name>

- Status: Draft | Approved | Implemented
- Created: YYYY-MM-DD
- Related ADRs: docs/adr/NNNN-...

## 1. Background and goals
<Why we are building this. The problem to solve and the definition of success>

## 2. Scope
- In scope:
- Out of scope (Non-goals):

## 3. Requirements
- REQ-1: <When the user / system does X, it must Y>
- REQ-2:
- Non-functional requirements: <performance, security, compatibility, and so on>

## 4. Design
- Overall approach:
- Data model / API / UI:
- Alternatives considered and why they were rejected: (record important ones as ADRs)

## 5. Implementation tasks
- [ ] T0: Save this plan as docs/design/YYYY-MM-<slug>.md, set Status to Approved, and check this task
- [ ] T1: <task> (requirements: REQ-1)
- [ ] T2:

### After approval
Approving this plan is prior permission for every change it describes and for running /sdd:ship up to, but not including, the push and PR, even if the user's settings or CLAUDE.md say in general to ask before making changes. After approval, Claude works through T0, T1 ... Tn without stopping. After each task, it runs the tests, lint, and type checks, and when they pass, commits locally to the working branch (creating one first if on the default branch; no commit outside git; no push). When all tasks are done, it runs /sdd:ship. It stops and asks only when:
1. An ADR draft needs approval: a decision that no task names, or one that makes an existing ADR Superseded
2. A change would go against an Accepted ADR
3. Requirements are missing or contradictory, or the work goes beyond this plan (including moving up a category)
4. Tests fail and can't be fixed without changing the design
5. An operation is hard to undo or visible outside, such as writing to production or publishing (a human runs these)
6. /sdd:ship is about to push and create the PR

In these cases, stop and ask without hesitation. Not stopping applies only to work that needs no confirmation.

## 6. Tests and verification
- <How to check each requirement>

## 7. Open questions
- <What isn't decided yet. Resolve before approval>
