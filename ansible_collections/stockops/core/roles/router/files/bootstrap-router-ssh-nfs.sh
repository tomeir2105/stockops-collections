#!/usr/bin/env bash
set -euo pipefail
NFS_DIR="/mnt/k3s_storage"
NFS_NET="192.168.50.0/24"
WAN_IF="${WAN_IF:-eth0}"
EXPORTS_LINE="${NFS_DIR} ${NFS_NET}(rw,sync,no_subtree_check,no_root_squash)"

sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server nfs-kernel-server iptables-persistent
sudo mkdir -p "${NFS_DIR}"/{jenkins,grafana,influxdb,netdata,news,stocks,sentiments}
sudo chmod -R 0777 "${NFS_DIR}"
grep -qF "${EXPORTS_LINE}" /etc/exports || echo "${EXPORTS_LINE}" | sudo tee -a /etc/exports >/dev/null
sudo exportfs -ra
sudo systemctl enable --now ssh
sudo systemctl enable --now nfs-server
sudo install -m 0644 /dev/stdin /etc/sysctl.d/99-stockops-router.conf <<SYSCTL
net.ipv4.ip_forward = 1
SYSCTL
sudo sysctl --system >/dev/null
sudo iptables -t nat -C POSTROUTING -s "${NFS_NET}" -o "${WAN_IF}" -j MASQUERADE 2>/dev/null || \
sudo iptables -t nat -A POSTROUTING -s "${NFS_NET}" -o "${WAN_IF}" -j MASQUERADE
sudo netfilter-persistent save >/dev/null
echo "[done] SSH, NFS, NAT bootstrap complete."
