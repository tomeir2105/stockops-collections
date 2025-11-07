# Installation Guide

This guide provides detailed instructions for setting up the StockOps platform on your Raspberry Pi cluster.

## Hardware Requirements

### Minimum Configuration
- 1x Raspberry Pi 4B (8GB) for router node (k3srouter)
- 2x Raspberry Pi 4B (4GB+) for worker nodes
- Network switch (Gigabit recommended)
- SD cards (32GB+ recommended)
- Power supplies for each Pi
- Ethernet cables

### Recommended Configuration
- 1x Raspberry Pi 4B (8GB) for router node (k3srouter)
- 3x Raspberry Pi 4B (8GB) for worker nodes
- 1x Gigabit network switch
- High-speed SD cards (64GB+)
- Proper cooling solution for each Pi
- Reliable power supply unit
- CAT6 Ethernet cables
- Optional: SSD drives for improved storage performance

## Software Prerequisites

- Raspberry Pi OS (64-bit, Lite) on all nodes
- Python 3.8 or higher
- Ansible 2.9 or higher
- Git
- SSH enabled on all nodes
- Docker installed on worker nodes

## Network Setup

### Router Node (k3srouter)
1. Configure static IP: 192.168.50.1
2. Enable IPv4 forwarding
3. Configure NAT
4. Set up DHCP server
5. Configure WiFi access point (optional)

### Worker Nodes
- k3s1: 192.168.50.101
- k3s2: 192.168.50.102
- k3s3: 192.168.50.103

## Initial Setup Steps

1. **OS Installation**
   ```bash
   # Download Raspberry Pi Imager
   # Flash SD cards with Raspberry Pi OS (64-bit, Lite)
   # Enable SSH during flashing
   ```

2. **Basic Configuration (All Nodes)**
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y

   # Install required packages
   sudo apt install -y python3 python3-pip git

   # Set timezone
   sudo timedatectl set-timezone Your/Timezone
   ```

3. **SSH Key Setup**
   ```bash
   # On router node
   ssh-keygen -t ed25519 -C "your_email@example.com"
   
   # Copy key to each worker node
   ssh-copy-id pi@192.168.50.101
   ssh-copy-id pi@192.168.50.102
   ssh-copy-id pi@192.168.50.103
   ```

4. **Repository Setup**
   ```bash
   git clone https://github.com/yourusername/stockops-collections.git
   cd stockops-collections
   ```

5. **Configuration Files**
   ```bash
   # Copy example files
   cp ansible_collections/stockops/core/docs/examples/vars.yml.example inventory/group_vars/all/vars.yml
   cp inventory.ini.example inventory.ini

   # Edit configuration files
   nano inventory.ini  # Update with your Pi IP addresses
   nano inventory/group_vars/all/vars.yml  # Update variables
   ```

## Installation Process

1. **Router Setup**
   ```bash
   ansible-playbook -i inventory.ini play.yml -t router
   ```

2. **K3s Cluster Setup**
   ```bash
   ansible-playbook -i inventory.ini play.yml -t k3s -e k3s_apply=true
   ```

3. **Core Services Deployment**
   ```bash
   # Deploy monitoring stack
   ansible-playbook -i inventory.ini play.yml -t grafana
   ansible-playbook -i inventory.ini play.yml -t influxdb

   # Deploy CI/CD
   ansible-playbook -i inventory.ini play.yml -t jenkins
   ```

4. **Applications Deployment**
   ```bash
   ansible-playbook -i inventory.ini play.yml -t apps
   ```

## Validation Steps

After each stage, verify the installation:

1. **Router**
   ```bash
   # Check network connectivity
   ping 192.168.50.101
   
   # Verify NFS
   showmount -e localhost
   ```

2. **K3s**
   ```bash
   # Check nodes
   kubectl get nodes
   
   # Verify system pods
   kubectl get pods -A
   ```

3. **Core Services**
   ```bash
   # Check service status
   kubectl get pods -n stockops
   
   # Verify endpoints
   curl -I http://192.168.50.101:30030  # Grafana
   curl -I http://192.168.50.101:30886  # InfluxDB
   curl -I http://192.168.50.101:30080  # Jenkins
   ```

4. **Applications**
   ```bash
   # Verify app pods
   kubectl get pods -n stockops -l app=stockops-news
   kubectl get pods -n stockops -l app=stockops-stocks
   
   # Check logs
   kubectl logs -n stockops -l app=stockops-stocks
   kubectl logs -n stockops -l app=stockops-news
   ```