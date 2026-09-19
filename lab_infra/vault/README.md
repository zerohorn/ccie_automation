# Vault (blueprint domain 5.4)

Adapted from [lucagubler/DevNet-VAULT](https://github.com/lucagubler/DevNet-VAULT).
Runs Vault 1.20 (matching the v1.1 Equipment/Software list) with a file
backend and TLS listener — not dev mode, so it behaves like the real
init/unseal/token workflow you'll need to know.

## Setup

```bash
cp .env.example .env          # adjust VAULT_PORT if needed
./generate-certs.sh           # generates certs/vault.{crt,key} locally — do this every time you clone/reset the lab
docker-compose up -d
docker ps -a                  # confirm devnet_vault is running
```

## Initialize and unseal

```bash
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_CACERT=$(pwd)/certs/vault.crt

vault operator init           # save the unseal key(s) and root token — password manager, NOT this repo
vault operator unseal <unseal-key>
export VAULT_TOKEN=<root-token>

vault status
```

## Never do this

The upstream repo's README ships a real private key (`certs/vault.key`) and a
root token, both public on GitHub since the repo was published. If you ever
cloned that repo and ran it as-is, that key and token are burned — anyone can
compute what you sealed with them. `generate-certs.sh` here produces a fresh
key every time; the root token only ever exists in your own `vault operator
init` output. Keep it that way — don't commit `.env`, `certs/`, `file/`, or
`logs/` (all covered by `.gitignore` already).

## Where this goes next

- hvac (Python) client against this instance — ties into blueprint 2.1/2.2
  (Python REST clients) and 5.4 directly.
- Terraform/Ansible Vault provider integration — natural pairing with your
  existing 2.7/2.8 work.
