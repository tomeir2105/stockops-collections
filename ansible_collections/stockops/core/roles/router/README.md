# Raspberry Pi Wi‑Fi Router — Role
(for `stockops.core.router`)

This README explains **what each file does**, **why the role is split this way**, and **how to use it** both as plain Bash and as part of your **Ansible Collection** (`stockops.core`). It’s designed so a new user can follow it end‑to‑end without hunting through the repo.

---

## Role porpuse

Turns a Raspberry Pi (Debian 12/13) into a Wi‑Fi **router / access point**:

- Access Point with **hostapd**
- DHCP/DNS with **dnsmasq**
- **NAT/IP forwarding** with iptables + netfilter‑persistent
- One interface as **WAN** (internet uplink), another as **LAN/AP**
- Staged scripts (0→6) provide idempotent, debuggable setup with health checks

---

## Files details

- **`files/scripts/` (imperative)** — Small, auditable **Bash** steps (stage0…stage6) that you can run by hand during bring‑up or call from Ansible. Separation by stage gives you **clear checkpoints** and easy troubleshooting (e.g., you can run only `stage3_ap.sh` if AP fails).
- **`files/config/` (declarative)** — A single `.env` + config **templates** for hostapd/dnsmasq/iptables/etc. This isolates **environment and policy** (SSID, IP ranges, country, interfaces) from the scripts, so you can **port** the role to other Pis or labs by only editing config.
- **`tasks/*.yml` (orchestration)** — Ansible glue that **deploys** the scripts/config to the target, **renders** templates, **exports vars** to `/etc/stockops/vars.env`, and optionally **runs** the staged scripts in order. This is what makes the role “one‑role‑and‑done”.
- **`defaults/` & `vars/`** — Provide safe defaults and a canonical stage order list. Consumers can override without touching the role.

This structure gives you the flexibility to:
- debug with **Bash only** on-device,
- or run **fully automated** via Ansible across many devices.

---

## Directory & file map (what each file does)

### `files/config/`
- **`.env`** — Central environment file: interface names (`WAN_IFACE`, `LAN_IFACE`), country code, LAN CIDR, DHCP range, AP SSID/PSK, etc. Edit this when running via Bash or copy/render via Ansible.
- **`hostapd.conf.tmpl`** — Template for AP parameters (SSID, channel, HT capabilities, auth). Rendered into `hostapd.conf`.
- **`dnsmasq.conf.tmpl`** — Template for DHCP/DNS ranges, options, and leases. Rendered into `dnsmasq.conf`.
- **`dhcpcd_wlan1.conf.tmpl`** — Template for setting a **static IP** on the LAN interface. Rendered for `dhcpcd`.
- **`iptables.rules.v4.tmpl`** — Template for **persistent NAT** rules (MASQUERADE on WAN). Rendered to an iptables‑persistent rules file.
- **`sysctl_router.conf`** — Sets `net.ipv4.ip_forward = 1` so the kernel forwards packets.

### `files/scripts/` (Stage scripts and helpers)
- **`install.sh`** — Runs all stages in order (0→6). Use this for quick, fully automatic Bash install.
- **`utils.sh`** — Shared helpers used by all stages: logging, safety checks, env loading/validation, AP capability checks, etc.
- **`stage0_prep.sh`** — Pre-flight checks, packages (`hostapd`, `dnsmasq`, `rfkill`, `iptables-persistent`, etc.), base hardening.
- **`stage1_wan.sh`** — Validates WAN link & DHCP; prints join hints (if WAN is Wi‑Fi) and routes/DNS status.
- **`stage2_lan.sh`** — Configures the LAN interface with static IP/broadcast/netmask using your `.env`.
- **`stage3_ap.sh`** — Generates/installs `hostapd.conf` + `dnsmasq.conf`; enables services.
- **`stage4_nat.sh`** — Enables IP forwarding and adds **MASQUERADE** NAT on the WAN interface; saves rules persistently.
- **`stage5_health.sh`** — Health audit: service status, open ports, DHCP leases, NAT rules, and last logs (quick troubleshooting).
- **`stage5_verify.sh`** — Optional extra verification steps.
- **`stage6_enable.sh`** — Ensures required services are enabled on boot; finalizes router state.
- **`stage6_finalize.sh`** — Optional final touches (e.g., cleanups; safe to omit).
- **`disable_rfkill.sh`** — One‑time helper to persistently unblock Wi‑Fi/Bluetooth (udev rule + mask systemd‑rfkill).
- **`set-static-ip.sh`, `check-ap.sh`, `show-clients.sh`** — Utility scripts for network tweaks and visibility.
- **`bootstrap-router-ssh-nfs.sh`** (in role root `files/`) — Optional helper to set up SSH + NFS share + simple NAT quickly on the same box (useful for lab scaffolding).

### `tasks/` (Ansible orchestration)
- **`main.yml`** — Entry point. Includes:
  - `deploy-scripts.yml` — copies `files/scripts/` to target (`router_scripts_dir`).
  - `deploy-config.yml` — copies `files/config/` and **renders** templates (`hostapd.conf`, `dnsmasq.conf`, `dhcpcd_wlan1.conf`, `iptables.rules.v4`).
  - `gen-vars-env.yml` — exports role variables as `STOCKOPS_*` into `/etc/stockops/vars.env` (for shell consumption).
  - `run-scripts.yml` — optionally executes stages in order.
- **`deploy-scripts.yml`** — Ensures target directory exists and copies the scripts.
- **`deploy-config.yml`** — Ensures config dir exists, copies `.env`, renders all `*.tmpl` to their final files.
- **`gen-vars-env.yml`** — Renders `templates/vars.env.j2` → `/etc/stockops/vars.env`. Scripts source it automatically in `run-scripts.yml`.
- **`run-scripts.yml`** — Determines the script order (`router_scripts_order` or discovered) and runs each script using `/bin/bash`.

### `defaults/` & `vars/`
- **`defaults/main.yml`** — Key switches:
  - `router_deploy_scripts: true`
  - `router_deploy_config: true`
  - `router_run_scripts: false`  ⟵ set to `true` in your playbook to auto‑execute stages
  - `router_scripts_dir: /opt/stockops-router/scripts`
  - `router_scripts_order: []`   ⟵ set an explicit stage list for clarity
- **`vars/script_order.yml`** — Canonical list you can reuse for stage order if you don’t want to repeat it in playbooks.

---

## Using it with **Bash only** (one device, no Ansible)

1) Edit the environment:
```bash
cd roles/router/files
sudo cp config/.env config/.env.backup   # Inline remarks: keep a copy
sudo nano config/.env                    # WAN_IFACE, LAN_IFACE, SSID/PSK, LAN_CIDR, DHCP range, COUNTRY_CODE
```

2) (Optional, recommended once) Make rfkill persistence safe:
```bash
sudo bash scripts/disable_rfkill.sh
```

3) Run the full installer:
```bash
sudo bash scripts/install.sh
```

4) Reboot and verify:
```bash
sudo reboot
# after boot:
sudo bash scripts/stage5_health.sh
```

---

## Using it as part of the **Ansible Collection** (`stockops.core`)

You **do not** need to `cd` into the role. Call it by **FQCN**: `stockops.core.router`.

### Dev mode (your repo directly)

Make sure your `ansible.cfg` includes your repo collections path:
```ini
[defaults]
# Inline remarks: allows Ansible to find the collection straight from your repo
collections_paths = /home/user/stockops-collections/ansible_collections:~/.ansible/collections:/usr/share/ansible/collections
```


Run:
```bash
ansible-playbook -i /home/user/stockops-collections/inventory.ini play_router.yml
```

### Installed mode (use from anywhere)

Build and install your collection:
```bash
cd /home/user/stockops-collections
ansible-galaxy collection build
ansible-galaxy collection install dist/stockops-core-*.tar.gz
```

Then the same **playbook** works from any directory because `stockops.core` is installed under `~/.ansible/collections`.

---

## Variables you’ll commonly set (via Ansible)

You can pass variables in the playbook or inventory:

```yaml
# Inline remarks: example vars; keep secrets (PSK) in Ansible Vault if needed
router_deploy_scripts: true
router_deploy_config: true
router_run_scripts: true

# For templates:
AP_SSID: "k3srouter"               # SSID for hostapd
AP_PSK: "12345678"           # Passphrase
AP_CHANNEL: 6                    # Channel
COUNTRY_CODE: "IL"               # Regulatory domain

WAN_IFACE: "wlan0"               # WAN uplink interface (or "eth0")
LAN_IFACE: "wlan1"               # AP/LAN interface

LAN_CIDR: "192.168.50.1/24"
LAN_NETMASK: "255.255.255.0"
LAN_BROADCAST: "192.168.50.255"
LAN_SUBNET: "192.168.50.0"

DHCP_RANGE_START: "192.168.50.100"
DHCP_RANGE_END: "192.168.50.200"
```

> The role renders `hostapd.conf`, `dnsmasq.conf`, `dhcpcd_wlan1.conf`, and `iptables.rules.v4` from these vars, and writes `/etc/stockops/vars.env` for shell consumption.

---

## Health & Troubleshooting

- Run **`stage5_health.sh`** to dump service status, ports, leases, NAT rules, and relevant logs.
- If AP won’t start:
  - Check `iw list` supports **AP** mode (the scripts test this).
  - Confirm regulatory domain (`COUNTRY_CODE`) and channel.
- If clients connect but have no internet:
  - Ensure `net.ipv4.ip_forward = 1` (sysctl applied).
  - Confirm MASQUERADE rule is on the **WAN** interface.
  - Check DNS resolution via `dnsmasq` (leases, logs).

---

## Repo hygiene (pre‑commit)

This repository uses **pre‑commit** hooks to keep YAML and Ansible content clean:
- `pre-commit-hooks` (basic whitespace/EOF fixes)
- `yamllint` (YAML style/validity)
- `ansible-lint` (best practices)

To enable locally (optional):
```bash
pipx install pre-commit            # or: pip install --user pre-commit
pre-commit install                 # Inline remarks: installs git hook to run on commit
```

---

## License

MIT © Meir
