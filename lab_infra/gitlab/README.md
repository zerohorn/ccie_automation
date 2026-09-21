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
docker compose up -d
```

First boot takes several minutes (reconfigure runs on first start). Then:

```bash
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

That's your one-time root password — GitLab deletes that file after 24 hours,
so log in and change it promptly.

## Registering a GitLab Runner (domain 1.3/1.4)

`docker-compose.yml` includes a `gitlab-runner` service on the same Docker
network as `gitlab`, so it reaches it internally at `http://gitlab:8929/` —
no host IP/port juggling needed. GitLab 16+ retired the old shared
registration-token flow, so you get a per-runner authentication token from
the UI first.

### 1. Get a runner authentication token

In the GitLab web UI:
- **Admin Area → CI/CD → Runners → "New instance runner"** (covers every
  project), or **a specific project → Settings → CI/CD → Runners → "New
  project runner"** if you only want it scoped to one repo.
- Pick platform "Linux", add a tag if you want (e.g. `hornlab01`), create it.
- Copy the authentication token shown (starts with `glrt-`) — it's only
  displayed once.

### 2. Start and register the runner

```bash
docker compose up -d gitlab-runner

docker exec -it gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "http://gitlab:8929/" \
  --token "<glrt-your-token>" \
  --executor "docker" \
  --docker-image "docker:24.0.5" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
  --description "hornlab01-runner"
```

Confirm it shows up: Admin Area → CI/CD → Runners (or the project's Runners
page) should list it as online.

### 3. Security note on `/var/run/docker.sock`

The runner uses **Docker socket binding** — CI jobs get a Docker client that
talks to HORNLAB01's real Docker daemon, meaning any pipeline job can, in
practice, control every other container on the host (Vault, TIG, GitLab
itself). Fine for a personal home lab; do not do this on a shared or
internet-facing runner. The exam-relevant lesson (ties to domain 5.0) is
recognizing this as a real trust boundary, not just plumbing.

### 4. Prove it works — minimal test pipeline

Create a throwaway project in GitLab, add `.gitlab-ci.yml`:

```yaml
test-job:
  image: alpine:latest
  script:
    - echo "runner is alive"
    - cat /etc/os-release
```

Push it, watch it run under CI/CD → Pipelines. Once that's green, you have a
real pipeline to deliberately break (bad image name, failing script, missing
artifact) and fix — that's what 1.4 ("troubleshoot CI/CD pipeline issues")
actually tests, not just having GitLab installed.
