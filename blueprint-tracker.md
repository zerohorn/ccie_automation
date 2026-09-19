# CCIE Automation (v1.1) Blueprint Tracker

Source: CCIE Automation v1.1 Exam Topics – Practical Exam (Cisco).
Valid for exams scheduled before March 23, 2027.

Mark items `[x]` as you reach working proficiency (can do it live, not just "understand it").
Keep this file in sync with `github.com/zerohorn/ccie_automation`.

---

## Phase 0 — Environment Verification Log

**Status: Complete.** The gate condition from `study-plan.md` ("confirm Cat8000V and IOSv/IOSvL2 are deployed and reachable before starting domain work") is satisfied. Recommended entry point: blueprint domain **2.8 (Terraform)** — resource graphs and state management, as a proficiency confirmation.

| Item | Status | Notes |
|---|---|---|
| Cat8000V reachability (SSH/RESTCONF) | ✅ Confirmed | RESTCONF verified via `curl` against router1 and router2 |
| IOSv/IOSvL2 reachability (SSH) | ✅ Confirmed | Required client-side SSH KEX workaround — see gotcha below |
| IOSvL2 RESTCONF | ❌ Confirmed non-functional | `restconf` is accepted into running-config (shared classic-IOS command parser) but every endpoint returns 404 — no working YANG/RESTCONF agent behind it. Note: IOL-L2's documented lack of RESTCONF/NETCONF does **not** automatically extend to IOSvL2 — different CML node type/image, confirmed by direct test rather than assumption |
| N9Kv 9.3(8) image | ✅ Confirmed | Custom image definition imported, labeled `NX-OS 9300v 9.3.8`, sized 4 vCPU / 8192 MB RAM |
| APIC + ACI Simulator | ⏸ Deferred | Pending 128GB RAM upgrade |
| CWS SSH KEX compatibility | ⚠️ Assumed, not yet tested on actual CWS build | Same fix will very likely be needed regardless of workstation OS — verify directly on CWS before exam day, don't assume |

**Gotcha — SSH key exchange failure against IOSv/IOSvL2:**
IOS 15.x's SSH server only offers SHA1-era key exchange (`diffie-hellman-group-exchange-sha1`, `diffie-hellman-group14-sha1`, `diffie-hellman-group1-sha1`). Modern OpenSSH clients (macOS and Ubuntu 24.04/CWS alike) reject these by default → `Unable to negotiate ... no matching key exchange method found`. Fix is client-side; add to `~/.ssh/config`:

```
Host 10.0.0.*
    KexAlgorithms +diffie-hellman-group14-sha1
    HostKeyAlgorithms +ssh-rsa
    Ciphers +aes128-cbc
```

Ansible/Netmiko (Paramiko-based) need the equivalent handled separately — `~/.ssh/config` isn't read by Paramiko. Use `ansible_paramiko_disabled_algorithms` for Ansible, or an explicit Paramiko transport override for Netmiko, when automation work starts.

---

## 1.0 Software Design, Development, and Deployment — 20%

- [ ] 1.1 [Design] Design a solution based on on-prem, hybrid, or public cloud deployment
  - [ ] 1.1.a Deployment: maintainability, modularity (containers, VM, orchestration, automation, components, infra requirements)
  - [ ] 1.1.b Reliability: high availability and resiliency
  - [ ] 1.1.c Performance: scalability, latency, rate limiting
  - [ ] 1.1.d Infrastructure: monitoring, observability, metrics
- [ ] 1.2 [Modify] Modify an existing network automation solution (gap analysis, source of truth)
- [ ] 1.3 [Build] Use Git in a CI/CD development workflow
- [ ] 1.4 [Troubleshoot] Troubleshoot CI/CD pipeline issues (code failures, pipeline issues, tool incompatibility)
- [ ] 1.5 [Troubleshoot] Diagnose application performance issues (async request processing, DB delays, high mem/CPU, microservice network delays, asymmetric routing) using network/app tools + assurance data (AppDynamics, ThousandEyes)

## 2.0 Infrastructure as Code — 30%

- [ ] 2.1 [Build] Build/manage/operate a Python-based REST API with a web framework (endpoints, HTTP req/resp, OpenAPI spec)
- [ ] 2.2 [Build] Build/manage/operate a Python-based CLI app that uses a REST API
- [ ] 2.3 [Consume] Consume and use a new API given documentation
  - [ ] 2.3.a REST
  - [ ] 2.3.b GraphQL
- [ ] 2.4 [Build] Create a RESTCONF or NETCONF payload from a YANG module; interpret the response
- [ ] 2.5 [Build] Create a NETCONF filter using XPath
- [ ] 2.6 [Build] Configure devices via NETCONF/RESTCONF using YANG analysis tools, driven by a source of truth
- [ ] 2.7 [Build] Create/use an Ansible role to manage infrastructure
  - [ ] 2.7.a Loop control
  - [ ] 2.7.b Conditionals
  - [ ] 2.7.c Variables and templating
  - [ ] 2.7.d Connection plugins (network CLI, HTTPAPI, NETCONF)
- [ ] 2.8 [Build] Use Terraform to statefully manage infrastructure
  - **Provider correction (2026-09-09):** the v1.1 Equipment and Software List only installs `ciscodevnet/aci v2.17.0` under Terraform — no `CiscoDevNet/iosxe` provider is on the Candidate Workstation. Target platform switched from Cat8000V/NETCONF to APIC/ACI. Blocked on APIC access — local ACI Simulator is still deferred pending the RAM upgrade (see Phase 0 log); use a DevNet sandbox (`developer.cisco.com/site/sandbox`) as an interim target if the upgrade timeline slips.
  - [ ] 2.8.a Loop control
  - [ ] 2.8.b Resource graphs
  - [ ] 2.8.c Variables
  - [ ] 2.8.d Resource retrieval
  - [ ] 2.8.e Resource provision
  - [ ] 2.8.f State management of provisioned resources
- [ ] 2.9 [Build] Create a basic Cisco NSO service package (python-and-template type, cisco-ios-cli NED)
  - [ ] 2.9.a Service template from a provided NSO device config
  - [ ] 2.9.b Basic YANG module (lists, leaf lists, data types, leaf refs, single-arg when/must)
  - [ ] 2.9.c Basic actions to verify operational status
  - [ ] 2.9.d Monitor service status via the NCS Python VM log

## 3.0 Network Programmability and Automation — 25%

- [ ] 3.1 [Build/Modify/Troubleshoot] Create/modify/troubleshoot Python scripts against APIs: ACI, AppDynamics, Catalyst Center, FDM, Intersight, IOS XE, Meraki, NSO, Webex
- [ ] 3.2 [Build] Automate Cisco IOS XE device configuration
  - [ ] 3.2.a Interfaces
  - [ ] 3.2.b Static routes
  - [ ] 3.2.c VLANs
  - [ ] 3.2.d Access control lists
  - [ ] 3.2.e BGP peering
  - [ ] 3.2.f BGP and OSPF routing tables
  - [ ] 3.2.g BGP and OSPF neighbors
- [ ] 3.3 [Modify/Troubleshoot] Modify/troubleshoot an automated test using pyATS
  - [ ] 3.3.a Testbed file for IOS/IOS XE/NX-OS devices
  - [ ] 3.3.b Gather config/operational state via Genie parser/models
  - [ ] 3.3.c Develop/execute test jobs and scripts using AEtest
- [ ] 3.4 [Design] Design a model-driven telemetry solution (gNMI dial-in, gRPC dial-out, NETCONF dial-in)
- [ ] 3.5 [Build] Create YANG model-driven telemetry subscriptions
  - [ ] 3.5.a Identify model elements and cadence
  - [ ] 3.5.b On-change or event-driven
  - [ ] 3.5.c Optimize frequency
  - [ ] 3.5.d Dial-out subscription
  - [ ] 3.5.e Secure telemetry streams
  - [ ] 3.5.f Confirm data transmission
  - [ ] 3.5.g Identify network issues and make changes

## 4.0 Containers — 10%

- [ ] 4.1 [Build] Create a Docker image (Dockerfile)
  - [ ] 4.1.a From a provided image
  - [ ] 4.1.b Expose ports
  - [ ] 4.1.c Add/copy files
  - [ ] 4.1.d Run commands during build
  - [ ] 4.1.e Entry point / initial commands
  - [ ] 4.1.f Working directories
  - [ ] 4.1.g Environment variables
  - [ ] 4.1.h .dockerignore
  - [ ] 4.1.i Volumes
- [ ] 4.2 [Build] Package/deploy via Docker Compose
  - [ ] 4.2.a Deploy and manage containers
  - [ ] 4.2.b Define services, networks, volumes, links
- [ ] 4.3 [Build] Package/deploy via Kubernetes
  - [ ] 4.3.a Deployments, secrets, services, ingress, volumes, namespaces, replicas
  - [ ] 4.3.b Pod lifecycle (scale up/down, status, logs)
  - [ ] 4.3.c Monitor pods via health checks
  - [ ] 4.3.d Use kubectl
- [ ] 4.4 [Build/Troubleshoot] Create/consume/troubleshoot Docker host + bridge networks, integrate with external networks

## 5.0 Security — 15%

- [ ] 5.1 [Build] Apply OWASP secure coding practices
  - [ ] 5.1.a Input validation
  - [ ] 5.1.b Authentication and password management
  - [ ] 5.1.c Access control
  - [ ] 5.1.d Cryptographic practices
  - [ ] 5.1.e Error handling and logging
  - [ ] 5.1.f Communication security
- [ ] 5.2 [Build] Create a CSR via OpenSSL; send to a CA; secure a web app with the cert
- [ ] 5.3 [Build] Use OAuth2+ to obtain an auth token
- [ ] 5.4 [Build] Use a secret management system to secure an application
- [ ] 5.5 [Build] Use tokens, headers, and secrets to secure a REST API

---

## Lab Environment Reference (v1.1 Equipment/Software List)

- Candidate Workstation: Ubuntu 24.04 LTS, x86-64 only (OVA/qcow2) — not ARM-compatible, hence running via ESXi/CML on HORNLAB01 rather than natively
- Core VMs: IOSvL2 15.2, IOSv 15.9, Catalyst 8000V 17.5, Nexus 9300v (N9Kv) 9.3(8), Cisco APIC 6.1 w/ ACI Simulator
- Key tooling: Python 3.13.9, Ansible Core 2.19.3, Terraform 1.13.3, Cisco NSO 6.5, Docker 28.4 + Compose, kubectl 1.33, uv for Python env management
- Other: GitLab 18.4, HashiCorp Vault 1.20, Grafana 12.2, Kubernetes 1.33, Cisco AppDynamics/ThousandEyes (cloud)
- Authoritative source: [CCIE Automation v1.1 Equipment and Software List (PDF)](https://learningcontent.cisco.com/documents/marketing/exam-topics/ccie-automation-1.1-Software-and-Equipment-list-24.04.pdf)

### Actual Lab Build (HORNLAB01, CML 2.9.1+build.7, refplat-20250616-fcs.iso)

| Platform | Exam target | Running version | Status |
|---|---|---|---|
| IOSvL2 | 15.2 | 15.2 (`high_iron_20200929` build) | Exact match |
| IOSv | 15.9 | 15.9(3)M10 | Exact match |
| Catalyst 8000V | 17.5 | 17.16.01a (refplat default) | Accepted drift — Cisco's equipment list explicitly allows newer software; only baseline features are tested |
| Nexus 9300v (N9Kv) | 9.3(8) | 9.3.8 (custom image def, sourced separately — refplat default of 10.5.3.F was a full NX-OS generation off-target, not used) | Exact match |
| APIC 6.1 w/ ACI Simulator | 6.1 | Not yet deployed | Deferred pending 128GB RAM upgrade |

### Lab Infrastructure (lab_infra/, staged 2026-09-19, not yet deployed)

Docker Compose stacks for the supporting tooling on the Equipment/Software
list that had zero lab coverage — see `lab_infra/README.md` for the full
writeup, domain mapping, and security notes (upstream Vault reference repo
ships a public private key/token — do not reuse it).

| Stack | Path | Domain(s) | Status |
|---|---|---|---|
| HashiCorp Vault 1.20 | `lab_infra/vault/` | 5.4 | Compose staged, not deployed on HORNLAB01 |
| Telegraf + InfluxDB + Grafana | `lab_infra/telemetry_tig/` | 3.4, 3.5 | Compose staged, not deployed on HORNLAB01 |
| GitLab CE | `lab_infra/gitlab/` | 1.3, 1.4 | Compose staged (unverified against live GitLab docs), not deployed |

Still fully unbuilt: Cisco NSO (2.9 — no instance anywhere, own learning
curve, don't defer to the last month), Kubernetes (4.3 — no cluster; k3s/kind
on HORNLAB01 is enough for kubectl reps).

### Device-to-Domain Mapping (locked in)

| Device | Domains | Notes |
|---|---|---|
| Catalyst 8000V | 2.4–2.6, 2.7.d (HTTPAPI/NETCONF plugins), 3.4–3.5 | Only RESTCONF/NETCONF/YANG/gNMI-capable platform in the lab — confirmed via curl |
| IOSv / IOSvL2 | 2.7.d (network_cli plugin), 3.2 | CLI automation only — RESTCONF confirmed non-functional on IOSvL2 despite being accepted into the command tree |
| N9Kv | 3.1 (NX-API / Python vs. APIs) | |
| APIC + ACI Simulator | 3.1 (ACI) | Standalone OVA, not a CML node — pending RAM upgrade |
