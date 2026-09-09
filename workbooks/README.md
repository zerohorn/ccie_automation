# Lab Workbooks

Self-contained, standalone HTML lab workbooks — one per blueprint sub-item — built for retrieval-practice study sessions.

**Launch page:** open `index.html` — a table of contents grouped by blueprint domain, linking every built workbook (and showing what's not built yet as a roadmap). It's the entry point; don't open individual workbook files from a file browser without it.

## Format (locked in as of 2.8 Terraform, keep using for all future topics)

Reference example: `2-8-terraform.html`. Blank starting point: `_template.html`.

- Single-file HTML, dark theme, no external assets (works offline, opens in any browser)
- **Header**: title, target platform/method, blueprint weight context
- **Prereq checklist**: checkboxes to confirm before starting (lab reachability, tool versions, credentials plan)
- **Per task**: `Requirement` → `Reference` (verified facts, not guesses) → `Verification` (a command proving success) → collapsed `Hint` → collapsed `Solution`
  - Hint and solution are `<details>` blocks, closed by default — forces attempting before peeking
  - Solutions include working code, not just descriptions
- Include a suggested time box, framed as study discipline, not exam-accurate timing (no official per-task timing exists)
- **Docs links** (added 2026-09-09): a page-level note up top links the collection/provider's top-level docs; each task's `Docs` section links the specific module/resource/plugin page used in that task. For study use only — call this out explicitly, since the real exam is closed-book/no internet. Prefer official docs (docs.ansible.com, registry.terraform.io, developer.cisco.com) over blogs. Web docs can't reliably pin to the exact micro-version installed on the CWS — note that `ansible-doc <fqcn>` / `terraform providers schema -json` / `ansible-galaxy collection list` run locally is the authoritative version-matched source, and treat web links as convenience/study-time only
- At least one **stretch/open-ended task** with no solution given, when the domain allows it (e.g. schema discovery) — closer to real exam conditions than memorized syntax
- **Self-check process** section at the end: attempt → hint if stuck → diff your work against the solution, don't just read it
- Footer note flags anything else worth carrying forward

## Generating a new one

1. Copy `_template.html` to `<blueprint-id>-<topic-slug>.html` (e.g. `2-7-ansible.html`)
2. Fill in tasks mapped to the sub-item's lettered breakdown in `blueprint-tracker.md`
3. Verify all "Reference" facts against actual docs/registry/module source before writing them in — don't guess field names
4. Update `index.html`: find that sub-item's `<div class="wb-row todo">` row and turn it into an `<a class="wb-row" href="...">` (see the maintenance comment at the top of `index.html`), then bump the progress count in its header
5. After a study session, note any format tweaks here rather than silently drifting per-file

## Status

| File | Blueprint item | Status |
|---|---|---|
| `2-8-terraform.html` | 2.8 Terraform | Paused — retargeted to `ciscodevnet/aci` (only Terraform provider on the v1.1 equipment list; the CWS has no `CiscoDevNet/iosxe`). Field names verified against the provider's GitHub docs, not yet against a live APIC — reverify with `terraform providers schema -json` once you have a DevNet sandbox APIC. Format itself is still the reference. |
| `2-7-ansible.html` | 2.7 Ansible | Not started (workbook built, hands-on pending). Splits `2.7.d` across `cisco.ios` (network_cli, IOSv/IOSvL2) and `ansible.netcommon` generic netconf/httpapi plugins (Cat8000V) — `cisco.ios` doesn't support netconf/httpapi at all, confirmed from its README. |
