# GitLab CE (blueprint domains 1.3, 1.4)

Not from the DevNet-Academy reference repos — this is the standard GitLab CE
Omnibus Docker Compose pattern (external_url + `GITLAB_OMNIBUS_CONFIG` +
persistent config/logs/data volumes). **I could not verify this against the
live GitLab installation docs during this session** (`docs.gitlab.com` was
blocked by network egress) — cross-check `GITLAB_VERSION` and the compose
shape against [docs.gitlab.com/install/docker](https://docs.gitlab.com/install/docker/)
before you deploy.

## Resource requirement — check this before you run it

GitLab Omnibus wants **4 GB+ RAM minimum** on its own, more once you add a CI
runner. Confirm HORNLAB01's actual allocated RAM/vCPU can absorb this on top
of Vault + the TIG stack before running all three simultaneously. If it can't,
run GitLab standalone during CI/CD study sessions and stop it otherwise —
don't leave it fighting the other stacks for memory.

## Setup

```bash
cp .env.example .env      # adjust hostname/ports if they collide with anything
docker-compose up -d
```

First boot takes several minutes (reconfigure runs on first start). Then:

```bash
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

That's your one-time root password — GitLab deletes that file after 24 hours,
so log in and change it promptly.

## Next step for domain 1.3/1.4 coverage

Register a GitLab Runner (Docker executor, on HORNLAB01 or the GitLab
container itself) so you have a real `.gitlab-ci.yml` pipeline to break and
fix — that's what 1.4 ("troubleshoot CI/CD pipeline issues") actually tests,
not just having GitLab installed.
