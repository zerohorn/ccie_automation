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
network as `gitlab`, so it reaches it internally.

**Correction from an earlier version of this doc:** I initially wrote this
assuming GitLab 16+ had fully retired the shared registration-token flow in
favor of per-runner `glrt-` authentication tokens. That's what GitLab
announced, but on this instance (17.5.2-ce.0) the legacy flow is still
served — deprecated (there's a warning banner) but functional — and the
`glrt-` auth-token path's own runner-detail page didn't even load correctly
here. **Use the registration-token flow below; it's the one confirmed
working.**

### 1. Get the registration token

In the GitLab web UI: **Admin Area → CI/CD → Runners → the "⋮" menu (or an
existing runner row) → "Install a runner"**. It shows a deprecation banner
but still gives you a ready-made command block containing `--url` and
`--registration-token <token>` — copy the token value from there (don't
retype it by hand; a hand-typed token is an easy way to introduce a typo or,
if composed in a rich-text editor, get smart-quoted into garbage).

**Version note:** the runner image is pinned to `GITLAB_RUNNER_VERSION` (default
`v17.5.0`, matching the GitLab server's `17.5.2-ce.0`) instead of `latest`.
GitLab explicitly recommends the Runner version not run ahead of the server
version — an unpinned `latest` runner can silently pick up CLI/behavior
changes (e.g. how `register` interprets `--token`) that break commands
written against an older version. I could not verify `v17.5.0` is an exact
existing tag on Docker Hub during this session (network egress to
hub.docker.com was unavailable) — if `docker compose up -d gitlab-runner`
fails to pull it, check available tags at
[hub.docker.com/r/gitlab/gitlab-runner/tags](https://hub.docker.com/r/gitlab/gitlab-runner/tags)
and adjust `GITLAB_RUNNER_VERSION` in `.env` to the closest 17.5.x tag that
exists.

If you already registered (or tried to) with the `:latest` image before this
fix: delete that runner entry in Admin Area → CI/CD → Runners (it likely
shows as failed/inactive anyway), then start clean below with a fresh token.

### 2. Start and register the runner

```bash
docker compose up -d gitlab-runner

docker exec -it gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "http://gitlab.hornlab.local:8929/" \
  --registration-token "<token-from-the-install-a-runner-modal>" \
  --executor "docker" \
  --docker-image "docker:24.0.5" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
  --description "hornlab01-runner"
```

Two easy-to-hit mistakes here, both from lived experience getting this
working:
- `docker exec -it gitlab-runner gitlab-runner register ...` needs
  `gitlab-runner` **twice** — once as the container name, once as the binary
  to run inside it. Drop the second one and you get `exec: "register":
  executable file not found`.
- Use straight quotes (`"`) around the token, not curly/smart quotes — some
  editors auto-convert `"` to `“`/`”`, which the shell won't parse as a
  quote character, corrupting the token.

Confirm it shows up: Admin Area → CI/CD → Runners (or the project's Runners
page) should list it as online. This flow creates a **new** runner entry —
if you'd already created one via "New instance runner" (the `glrt-` flow)
and it's stuck showing "Never contacted," delete that stale one with the
red ✕ once the new one is confirmed online.

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
