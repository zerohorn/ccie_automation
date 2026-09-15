# Lab Workbooks

Self-contained, standalone HTML lab workbooks — one per blueprint sub-item — built for retrieval-practice study sessions.

**Launch page:** open `index.html` — a table of contents grouped by blueprint domain, linking every built workbook (and showing what's not built yet as a roadmap). It's the entry point; don't open individual workbook files from a file browser without it.

## Format (locked in as of 2.8 Terraform, keep using for all future topics)

Reference example: `2-8-terraform.html`. Blank starting point: `_template.html`.

- Single-file HTML, dark theme, no external assets (works offline, opens in any browser)
- **Header**: title, target platform/method, blueprint weight context
- **Prereq checklist**: checkboxes to confirm before starting (lab reachability, tool versions, credentials plan)
- **Per task**: task-block structure depends on the sub-item's **task mode** — see below. All modes share: collapsed `Hint` and `Solution` as `<details>` blocks closed by default (forces attempting before peeking), a suggested time box framed as study discipline (no official per-task timing exists), and a `Docs` section (study use only — real exam is closed-book against a curated internal tool-docs site, not open internet)
- Solutions include working code/diffs/written rationale as appropriate to the mode, not just descriptions
- At least one **stretch/open-ended task** with no solution given, when the domain allows it (e.g. schema discovery) — closer to real exam conditions than memorized syntax
- **Self-check process** section at the end: attempt → hint if stuck → diff your work against the solution, don't just read it
- Footer note flags anything else worth carrying forward

## Task modes (added 2026-09-15)

The blueprint's action verb per sub-item (tagged in `blueprint-tracker.md`, e.g. `[Build]`, `[Troubleshoot]`) tells you what kind of exam task it actually is — a from-scratch build reads nothing like a troubleshooting task. Match the workbook task-block structure to the mode. A sub-item with a compound verb (e.g. 3.1 `[Build/Modify/Troubleshoot]`) gets separate tasks in separate modes within the same workbook, not one blended task.

| Mode | Blueprint verbs | Task-block structure | Why it differs from Build |
|---|---|---|---|
| **Build** | Create, Automate, Configure, Package/deploy, Apply, Use (as "operate") | `Requirement` → `Reference` (verified facts) → `Docs` → `Verification` → `Hint` → `Solution` (full code) | This is the original/default shape — see `_template.html` Task 1 |
| **Design** | Design | `Scenario/Constraints` (a background story + stakeholder asks, like the exam's Design module) → `Decision Question` → `Reference` (trade-off dimensions, not one right answer) → `Docs` → `Hint` → `Solution` (written rationale + diagram/table — **no code**) | Exam's Design module is web-based Q&A against a scenario, not hands-on. Grading it against a single code solution would train the wrong skill |
| **Modify** | Modify | `Starting Point` (an existing artifact you seed beforehand — code block or file path) → `Change Requirement` (the gap to close) → `Reference` → `Docs` → `Verification` → `Hint` → `Solution` **presented as a diff against the starting point**, not a rewrite | Real task hands you working code and a new ask; rewriting from scratch trains a different (easier) skill than locating where to change existing code |
| **Troubleshoot / Diagnose** | Troubleshoot, Diagnose | `Scenario/Symptom` (user-facing failure only) → `Given Evidence` (logs/error output/metrics — the actual breadcrumbs, no root cause named) → `Docs` → `Diagnostic Verification` (command to confirm a hypothesis, distinct from the fix-verification) → `Hint` (nudges toward *where to look*, never the root cause) → `Solution` as `Root Cause` → `Fix` → `Verification` | No upfront `Reference` — withholding the "correct" facts is the point, since diagnosis is the skill under test, not recall |
| **Consume** | Consume and use (given documentation) | `Task Given Cold` (a spec written like a customer ask, deliberately not pre-digested) → `Docs` (the *only* reference section — no cheat-sheet `Reference` block) → `Verification` → `Hint` (which doc section to start at, not which field to use) → `Solution` | Point of 2.3 is reading unfamiliar docs live under time pressure, not recalling memorized fields |

`_template.html` includes one worked example block per mode (HTML-commented below the visible Build task) — copy the block matching the sub-item's tagged verb(s).

## Generating a new one

1. Copy `_template.html` to `<blueprint-id>-<topic-slug>.html` (e.g. `2-7-ansible.html`)
2. Look up the sub-item's tagged verb(s) in `blueprint-tracker.md` (e.g. `[Modify/Troubleshoot]`) and pick the matching task-block mode(s) from the table above — don't default to Build for everything
3. Fill in tasks mapped to the sub-item's lettered breakdown
4. Verify all "Reference"/"Given Evidence" facts against actual docs/registry/module source or a real seeded failure before writing them in — don't guess field names or fabricate a plausible-looking log
5. Update `index.html`: find that sub-item's `<div class="wb-row todo">` row and turn it into an `<a class="wb-row" href="...">` (see the maintenance comment at the top of `index.html`), then bump the progress count in its header
6. After a study session, note any format tweaks here rather than silently drifting per-file

## Status

| File | Blueprint item | Status |
|---|---|---|
| `2-8-terraform.html` | 2.8 Terraform | Paused — retargeted to `ciscodevnet/aci` (only Terraform provider on the v1.1 equipment list; the CWS has no `CiscoDevNet/iosxe`). Field names verified against the provider's GitHub docs, not yet against a live APIC — reverify with `terraform providers schema -json` once you have a DevNet sandbox APIC. Format itself is still the reference. |
| `2-7-ansible.html` | 2.7 Ansible | Not started (workbook built, hands-on pending). Splits `2.7.d` across `cisco.ios` (network_cli, IOSv/IOSvL2) and `ansible.netcommon` generic netconf/httpapi plugins (Cat8000V) — `cisco.ios` doesn't support netconf/httpapi at all, confirmed from its README. |
