#!/usr/bin/env bash
# Generates a fresh self-signed cert/key for the local Vault listener.
# Never reuse the certs/key published in the upstream DevNet-VAULT repo —
# they're public on GitHub and provide zero security.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p certs

openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout certs/vault.key -out certs/vault.crt -days 825 \
  -subj "/CN=vault.hornlab.local" \
  -addext "subjectAltName=DNS:vault.hornlab.local,DNS:localhost,IP:127.0.0.1"

chmod 600 certs/vault.key
echo "Generated certs/vault.crt and certs/vault.key (self-signed, 825 days)."
echo "If you'll reach Vault from somewhere other than HORNLAB01 itself, add its real IP/hostname to the -addext SAN list and regenerate."
