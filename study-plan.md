# CCIE Automation Study Plan (v1.1, Path B pacing)

Goal: exam before March 23, 2027. Budget: <5 hrs/week now, ramping as the date approaches.
Sequenced by blueprint weight, starting from strengths (Ansible, Terraform) outward to gaps (NSO, telemetry, pyATS, container/security depth).

## Phase 0 — Environment Parity (short, do this first)
- Stand up lab access that mirrors the exam: Candidate Workstation software list on HORNLAB01/CML (Ubuntu 24.04, Python 3.13.9, Ansible Core 2.19.3, Terraform 1.13.3, NSO 6.5, Docker/Kubernetes)
- Get core VMs running: IOSvL2, IOSv, Catalyst 8000V, N9Kv, APIC + ACI Simulator
- Set up `uv` for Python env management to match exam conditions
- Confirm git workflow against `github.com/zerohorn/ccie_automation` (branch per topic area works well for isolating scenario labs)

## Phase 1 — Domain Build, weighted by exam % and current skill

1. **Infrastructure as Code (30%)** — biggest chunk, mixed strength
   - Terraform sub-items (2.8): likely fastest since it's a strength — confirm depth on resource graphs, state management
   - Ansible role work (2.7): confirm depth on connection plugins (NETCONF/HTTPAPI specifically, less common than CLI)
   - Python REST API/CLI build (2.1, 2.2) and RESTCONF/NETCONF/YANG/XPath (2.4–2.6): likely the real gap — this is where Python speed matters most
   - NSO service package (2.9): probably the newest ground — treat as its own mini-project

2. **Network Programmability and Automation (25%)**
   - IOS XE automation (3.2): straightforward given Ansible/Terraform base, just needs the specific config domains (BGP/OSPF, ACLs, VLANs) drilled
   - pyATS/Genie/AEtest (3.3): new tooling, budget dedicated time
   - Telemetry (3.4, 3.5): likely least familiar domain — gNMI/gRPC/NETCONF dial-in concepts plus subscription mechanics

3. **Software Design, Development, and Deployment (20%)**
   - Mostly design/judgment questions (HA, scalability, observability) plus CI/CD with Git — can layer in throughout rather than as a standalone block
   - App performance diagnosis (1.5) ties to AppDynamics/ThousandEyes — new tools, worth a dedicated session

4. **Security (15%)**
   - OWASP practices, OAuth2+, secret management, OpenSSL/CSR — mostly concept + a few concrete workflows, compact to study
   - Fold into the IaC/API work where it naturally overlaps (e.g., securing the REST API you build in 2.1 with tokens/OAuth2 from 5.3/5.5)

5. **Containers (10%)** — smallest weight, but hands-on heavy
   - Docker image/Compose (4.1, 4.2): likely quick if comfortable with Docker already
   - Kubernetes (4.3): budget more time if less hands-on experience there
   - Networking (4.4): pairs naturally with your network background

## Phase 2 — Integration Labs
Once individual domains are checked off, build 2–3 multi-domain scenario labs that combine IaC + Network Programmability + Security in one flow (e.g., Terraform-provisioned infra → Ansible-configured devices → Python REST API exposing status → secured with OAuth2 → monitored via telemetry). This is closer to what the exam actually asks for than isolated topic drills.

## Phase 3 — Ramp and Timed Practice
As the exam date firms up, shift from open-ended study to timed, closed-book practice scenarios (the real exam is closed-book, 8 hours). This is the "ramp hours" part of Path B.

## Weekly Cadence
- Study sessions (Project chat): work through one blueprint sub-item or concept per session, building mental models
- Lab/code work (Claude Code, in the repo): implement and test against HORNLAB01/CML
- Weekly sweep (Cowork): reconcile the week's progress against `blueprint-tracker.md`, flag gaps for next week
