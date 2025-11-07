#!/usr/bin/env bash
set -euo pipefail

# Minimal rfkill auto-unblock setup with hardening
# - Installs a udev rule that unblocks Wi-Fi and Bluetooth on add/change
# - Masks systemd-rfkill units to prevent restore of old blocked states
# Usage: sudo bash rfkill_min_hardened.sh

# Ensure rfkill exists
command -v rfkill >/dev/null 2>&1 || { echo "rfkill not found. Install: sudo apt-get update && sudo apt-get install -y rfkill"; exit 1; }

# Install udev rule (persistent across reboots)
sudo tee /etc/udev/rules.d/90-rfkill-unblock.rules >/dev/null <<'RULE'
SUBSYSTEM=="rfkill", ACTION=="add|change", RUN+="/usr/sbin/rfkill unblock wifi; /usr/sbin/rfkill unblock bluetooth"
RULE

# Reload udev and trigger rfkill so the rule runs now
sudo udevadm control --reload
sudo udevadm trigger -s rfkill || true

# Harden: prevent systemd-rfkill from restoring a blocked state (no-op if units absent)
sudo systemctl mask --now systemd-rfkill.service systemd-rfkill.socket || true

# Immediate unblock now and show status
sudo rfkill unblock wifi || true
sudo rfkill unblock bluetooth || true
rfkill list

echo "Done. Reboot to verify persistence: sudo reboot; then run: rfkill list"

