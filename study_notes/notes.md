
## 2.7 Ansible
### Cheetsheets
https://spacelift.io/blog/ansible-cheat-sheet
https://github.com/eon01/AnsibleCheatSheet


## 2.8 Terraform IOS-XE
### How to enable netconf on IOS-XE
config t
netconf-yang
### How to verify netconf enabled
ssh admin@10.0.0.251 -p 830 -s netconf


## Lab infrastructure (Vault, telemetry, GitLab) — see lab_infra/
2026-09-19: compared my lab against the DevNet-Academy "build a free lab"
article. Device layer (CML, exact IOS/NX-OS versions) was already ahead of
what it describes. Real gap was the tooling layer: GitLab/Vault/Grafana/NSO/K8s
are all on the v1.1 Equipment/Software list and blueprint-tracker.md already
named them, but none were built. Staged docker-compose stacks for Vault and
the Telegraf/InfluxDB/Grafana telemetry pipeline under `lab_infra/`, adapted
from the article author's own reference repos (lucagubler/DevNet-VAULT,
lucagubler/DevNet-TIG), plus a GitLab CE stack. Not yet deployed on HORNLAB01
— that's the next step.

**Security note worth remembering:** the upstream DevNet-VAULT repo has a real
private key and root token committed and public on GitHub. Never reuse
anything credential-shaped from a public reference repo without regenerating
it — `lab_infra/vault/generate-certs.sh` does this locally instead.

Still unbuilt after this: NSO (domain 2.9 — biggest neglected item, has its
own learning curve, don't leave it late), Kubernetes/kubectl reps (domain 4.3
— k3s or kind on HORNLAB01 would be enough), NetBox/YANGsuite (not on the
official software list, lower priority).