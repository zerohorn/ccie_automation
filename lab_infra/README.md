# Lab Infrastructure

Supporting tooling for the CCIE Automation (v1.1) lab, deployed on **HORNLAB01**
(Ubuntu + Docker) alongside the CML device topologies. This is infrastructure,
not blueprint content — see `blueprint-tracker.md` for exam-domain tracking.

Sourced/adapted from two reference repos by the author of the
[DevNet-Academy lab article](https://devnet-academy.com/blog/build-a-free-lab-for-the-devnet-expert-exam/):

- [lucagubler/DevNet-VAULT](https://github.com/lucagubler/DevNet-VAULT) → `vault/`
- [lucagubler/DevNet-TIG](https://github.com/lucagubler/DevNet-TIG) → `telemetry_tig/`

`gitlab/` is a standard GitLab CE Omnibus Docker Compose pattern (not from those
repos) added to close the same gap for domain 1.0. I could not verify its exact
current values against live GitLab docs during this session (network egress to
`docs.gitlab.com` was blocked) — check `gitlab/README.md` before deploying.

## What changed vs. the source repos (and why)

Both source repos are built for quick classroom demos, not for a repo you keep
around and reuse for a year of exam prep. I changed:

- **No committed secrets.** The original `DevNet-VAULT` repo ships a real
  `certs/vault.key` private key and a root token in its README, both public on
  GitHub. Anyone who has ever cloned that repo has that key. **Never reuse
  them.** This version generates certs locally (`vault/generate-certs.sh`) and
  gets the root token from your own `vault operator init` — nothing
  credential-shaped is committed here.
- **Credentials moved to `.env`** (gitignored) instead of hardcoded in
  `docker-compose.yml`, with `.env.example` as the template (run stacks with
  `docker compose`, the Docker Engine plugin — not the standalone
  `docker-compose` v1 binary, which may not be installed). Small thing, but
  it's also free reps for blueprint domain 5.0 (secrets management) instead of
  modeling the anti-pattern you're trying to learn to avoid.
- **Image versions bumped** where the source repo pinned old tags (Vault
  1.8.0 → 1.20 line, to match the v1.1 Equipment/Software list's Vault 1.20
  target; Telegraf 1.19.3 → 1.32). I have not run these bumped versions myself
  — validate on first `docker compose up` before you trust them.
- Removed the obsolete `version:` key and `links:` (both no-ops on current
  Docker Compose; service-name DNS resolution doesn't need `links`).
- Added persistent volumes for InfluxDB/Grafana data so dashboards survive a
  container recreate.

## Deployment order and resource budget

Check HORNLAB01's actual allocated RAM/vCPU before running everything at once
— GitLab Omnibus alone wants 4 GB+ RAM and is heavy relative to the other two.
Suggested order, each validated with `docker compose up` before moving on:

1. `vault/` — lightest, ~200 MB RAM, unlocks domain 5.4 immediately.
2. `telemetry_tig/` — ~1–2 GB RAM, unlocks domains 3.4/3.5 (currently your
   biggest zero-coverage area).
3. `gitlab/` — heaviest, run standalone first to confirm HORNLAB01 has headroom
   before leaving it up alongside the other two.

## Domain mapping

| Stack | Blueprint domain(s) | Unlocks |
|---|---|---|
| `vault/` | 5.4 (secret management system) | hvac Python client, Ansible/Terraform Vault integration |
| `telemetry_tig/` | 3.4, 3.5 (model-driven telemetry) | gRPC dial-out from Cat8000V, Grafana dashboards, TLS telemetry streams |
| `gitlab/` | 1.3, 1.4 (Git in CI/CD, pipeline troubleshooting) | Real GitLab CI runner + pipeline reps instead of local-only git |

## Security note

All three stacks bind to HORNLAB01's Docker host with default/example
credentials in `.env.example`. Before exposing any of these ports beyond
HORNLAB01 itself (e.g. port-forwarding through your home router, or reaching
them from the ESXi management network) — change every default credential and
put something in front of them. These are lab tools, not hardened services.
