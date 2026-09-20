# Telemetry stack: Telegraf + InfluxDB + Grafana (blueprint domains 3.4, 3.5)

Adapted from [lucagubler/DevNet-TIG](https://github.com/lucagubler/DevNet-TIG).
Collects Cisco model-driven telemetry (gRPC dial-out) from the Cat8000V node in
your CML topology, stores it in InfluxDB, visualizes it in Grafana.

## Setup

```bash
cp .env.example .env
# Edit .env with real credentials, then manually mirror INFLUXDB_ADMIN_TOKEN
# and INFLUXDB_BUCKET into grafana/datasources/influxdb.yml (see the note in
# that file — Grafana provisioning doesn't read .env).
mkdir -p grafana-data && sudo chown -R 472:472 grafana-data   # see Troubleshooting below
docker-compose up -d
```

Grafana: `http://<HORNLAB01-IP>:3000` — log in with the admin user/password
from `.env`.

## Troubleshooting: Grafana stuck in a restart loop

`docker ps -a` shows `grafana` cycling through `Restarting (1)`. Cause: the
`./grafana-data` bind mount gets created by Docker on first `up` as an empty
directory owned by `root`, but the Grafana image runs as UID `472` and can't
write its database into a root-owned directory — it crashes immediately and
restart-loops forever. This is the standard `grafana/grafana` bind-mount
gotcha, not specific to this stack.

Fix:
```bash
docker compose stop grafana
sudo chown -R 472:472 grafana-data
docker compose up -d grafana
docker ps -a   # should now show grafana as "Up"
```

If `docker logs grafana --tail 50` shows something other than a permission
error, check `GRAFANA_ADMIN_PASSWORD` in `.env` isn't blank — Grafana can also
refuse to start if it can't create the admin user with an empty password.

## Point the Cat8000V at it (plaintext dial-out, port 57000)

```
telemetry ietf subscription 100
 encoding encode-kvgpb
 filter xpath /interfaces-ios-xe-oper:interfaces/interface
 source-address <cat8000v-mgmt-ip>
 stream yang-push
 update-policy periodic 1000
 receiver ip address <hornlab01-ip> 57000 protocol grpc-tcp
```

Confirm data is landing before moving to TLS: check the Telegraf container
logs (`docker logs telegraf`) and query InfluxDB, or just watch a Grafana
panel update.

## gRPC-TLS dial-out (port 57100) — this is blueprint item 3.5.e directly

```bash
cd telegraf
# Edit csr.conf: set commonName_default and alt_names IP.1 to HORNLAB01's real IP/FQDN
openssl genrsa -out ca.key 2048
openssl genrsa -out telegraf.key 2048
openssl req -x509 -new -key ca.key -sha256 -days 3650 -out ca.crt -nodes
openssl req -out telegraf.csr -key telegraf.key -new -config csr.conf
openssl x509 -req -in telegraf.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out telegraf.crt -days 3650 -extensions v3_req -extfile csr.conf
chmod 644 telegraf.key
```

Then:
1. Uncomment the `ca.crt`/`telegraf.crt`/`telegraf.key` volume lines and the
   `57100:57100` port in `docker-compose.yml`.
2. Uncomment the TLS `cisco_telemetry_mdt` input block in `telegraf.conf`.
3. On the Cat8000V, install the CA cert as a trustpoint:

```
crypto pki trustpoint hornlab01
 enrollment terminal
 chain-validation stop
 revocation-check none
 exit
crypto pki authenticate hornlab01
! paste contents of ca.crt
```

4. Point the receiver at port 57100 with `protocol grpc-tls` instead of
   `grpc-tcp`.

These cert files are gitignored — they're generated per-deployment, never
committed.

## Why this matters for the exam

3.4/3.5 (model-driven telemetry) is the one part of your 25%-weight domain
that had zero lab coverage before this. This gets you both dial-out transport
variants (plaintext and TLS) and a real place to verify "confirm data
transmission" (3.5.f) and "identify network issues and make changes" (3.5.g)
against actual Grafana panels instead of just reading about it.
