# StockOps Collections

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ansible: 2.9+](https://img.shields.io/badge/Ansible-2.9+-blue.svg)](https://docs.ansible.com/ansible/latest/index.html)
[![Platform: Raspberry Pi](https://img.shields.io/badge/Platform-Raspberry%20Pi-C51A4A.svg)](https://www.raspberrypi.org/)

StockOps is a professional-grade, modular platform for collecting, processing, and visualizing stock market data, optimized for deployment on Raspberry Pi clusters. It combines enterprise-level tools with efficient resource utilization to create a powerful, self-hosted financial data operations environment.

---

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [System Architecture](#system-architecture)
- [Components](#components)
- [Installation Guide](#installation-guide)
  - [Hardware Setup](#hardware-setup)
  - [Network Configuration](#network-configuration)
  - [Initial Setup](#initial-setup)
  - [Deployment Steps](#deployment-steps)
- [Configuration](#configuration)
- [Accessing Services](#accessing-services)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

**stockops** is a fully automated DevOps and data-operations system that integrates:
- **Data ingestion** (Python fetchers for stocks and news),
- **Observability** (InfluxDB + Grafana dashboards),
- **Automation and CI/CD** (Jenkins and Ansible),
- **Orchestration** (K3s Kubernetes cluster),
- **Storage and persistence** (NFS-based shared storage).

All modules are deployed in a distributed Raspberry Pi environment.  
The project demonstrates how real-world automation and analytics can be implemented on low-power hardware using professional-grade tools.

## Prerequisites

### Hardware Requirements
- 1x Raspberry Pi 4B (8GB) for router node
- 2-3x Raspberry Pi 4B (4GB+) for worker nodes
- Network switch (Gigabit recommended)
- SD cards (32GB+ recommended)
- Power supplies
- Ethernet cables

### Software Requirements
- Raspberry Pi OS (64-bit, Lite) on all nodes
- Python 3.8+
- Ansible 2.9+
- Git
- SSH enabled on all nodes

### Network Setup
- Router node: 192.168.50.1
- Worker nodes: 192.168.50.101-103
- Subnet: 192.168.50.0/24

For detailed setup instructions, see our [Installation Guide](docs/installation.md).

---

## System Architecture

### Physical Architecture

```
                 ┌─────────────────────────┐
                 │ Raspberry Pi Cluster    │
                 │ (k3srouter, k3s1, ...)  │
                 └─────────────────────────┘
                             │
           ┌─────────────────┴─────────────────┐
           │                                   │
    ┌──────────────┐                    ┌──────────────┐
    │ Jenkins CI   │                    │ NFS Storage  │
    │ Builds, Push │                    │ /mnt/k3s_... │
    └──────────────┘                    └──────────────┘
           │                                   │
    ┌──────────────┐                    ┌──────────────┐
    │ Grafana      │◄──────InfluxDB────►│ Stocks Data  │
    │ Visualization│                    │ Metrics/Logs │
    └──────────────┘                    └──────────────┘
           │
    ┌──────────────┐
    │ Fetchers     │──►  API Feeds
    │ News/Stocks  │
    └──────────────┘
```

### Logical Architecture

```mermaid
graph TB
    Router[Router Node<br/>k3srouter]
    K3S[K3s Cluster<br/>Worker Nodes]
    NFS[NFS Storage<br/>/mnt/k3s_shared]
    Jenkins[Jenkins CI/CD]
    Grafana[Grafana<br/>Dashboards]
    InfluxDB[InfluxDB<br/>Time-series DB]
    Fetchers[Data Fetchers<br/>Stocks & News]
    APIs[External APIs]

    Router --> K3S
    Router --> NFS
    K3S --> Jenkins
    K3S --> Grafana
    K3S --> InfluxDB
    K3S --> Fetchers
    Fetchers --> APIs
    InfluxDB --> Grafana
    Jenkins --> K3S
```

## 📦 Components

| Component | Role | Description | Status |
|-----------|------|-------------|---------|
| Router | Infrastructure | Network management, DHCP, WiFi AP | ✅ |
| K3s | Orchestration | Lightweight Kubernetes cluster | ✅ |
| InfluxDB | Storage | Time-series data management | ✅ |
| Grafana | Visualization | Real-time dashboards and alerts | ✅ |
| Jenkins | Automation | CI/CD pipeline management | ✅ |
| News Fetcher | Data Collection | Financial news aggregation | ✅ |
| Stock Fetcher | Data Collection | Market data collection | ✅ |

## CI Pipelines

Pipeline definitions are now stored under `ci/jenkins/pipelines/` (one folder per pipeline). I moved the two pipeline files you added into:

- `ci/jenkins/pipelines/netdata-fetcher/Jenkinsfile`
- `ci/jenkins/pipelines/monitor-pods/Jenkinsfile`

To install a pipeline manually in Jenkins:

1. Multibranch pipeline: create a Multibranch Pipeline job that points to this repository (or the subfolder) — the job will pick up `Jenkinsfile` files in the pipeline folders.
2. Seed/Job DSL: create a seed job that runs the Job DSL scripts and creates jobs pointing to the Jenkinsfile paths.
3. Pipeline job: create a pipeline job and set the Pipeline script from SCM to the repo path `ci/jenkins/pipelines/<pipeline-name>/Jenkinsfile`.

> Security: do not commit secrets. Use Jenkins credentials and reference them by ID in the Jenkinsfiles (the pipelines call `influxdb_token` credential). For automated installation, prefer Job DSL or a seed job that references credentials by ID.

---

## Collection Overview

This repository contains the **`stockops.core`** Ansible Collection — a modular automation suite designed to deploy and manage the StockOps DevOps environment on a Raspberry Pi–based K3s cluster.

### Key Components

| Layer | Role | Description |
|-------|------|--------------|
| Network | `router` | Configures Raspberry Pi router (Wi‑Fi AP, LAN/WAN, NAT, DHCP) |
| Kubernetes | `k3s` | Installs and joins nodes into a lightweight K3s cluster |
| Core Services | `influxdb`, `grafana`, `jenkins` | Deploys metrics storage, dashboards, and CI/CD pipelines |
| Applications | `apps_news`, `apps_stocks` | Deploys StockOps applications for news and stock ingestion |
| Utility | `cluster_checks`, `common` | Performs validation and shared setup tasks |

---

## Repository Structure

```
stockops-collections/
├── ansible_collections/
│   └── stockops/
│       └── core/
│           ├── roles/
│           ├── plugins/
│           ├── galaxy.yml
│           ├── README.md
│           └── ...
├── inventory.ini
├── play.yml
├── play_router.yml
├── play_k3s.yml
├── play_core.yml
├── play_apps.yml
├── .pre-commit-config.yaml
├── .ansible-lint
├── .yamllint.yaml
└── Makefile
```

---

## Quick Start

### Full Install

```bash
ansible-playbook -i inventory.ini play.yml -t full -e k3s_apply=true
```

### Stage-by-Stage

### Accessing Services

| Service  | URL                               | Default Credentials |
|----------|-----------------------------------|-------------------|
| Grafana  | http://192.168.50.101:30030      | admin/ChangeMe123! |
| InfluxDB | http://192.168.50.101:30886      | admin/ChangeMe123! |
| Jenkins  | http://192.168.50.101:30080      | admin/admin      |

> **Important**: After initial setup, you must configure API tokens in your `vars.yml`:
>
> **1. Grafana Token**:
> 1. Log into Grafana using the default credentials
> 2. Go to Configuration → API Keys
> 3. Create a new API key with Admin role
> 4. Copy the generated token
> 5. Update `GRAFANA_TOKEN: "<ADD_YOUR_TOKEN>"` in your `vars.yml`
>
> **2. InfluxDB Token**:
> 1. Log into InfluxDB using the default credentials
> 2. Go to Data → API Tokens
> 3. Generate a new admin API token
> 4. Copy the generated token
> 5. Update `INFLUXDB_ADMIN_TOKEN: "<ADD_YOUR_TOKEN>"` in your `vars.yml`
>
> These tokens are required for automated dashboard provisioning, datasource configuration, and data collection.

For detailed configuration options, see our [Configuration Guide](docs/configuration.md).
For troubleshooting help, see our [Troubleshooting Guide](docs/troubleshooting.md).

### Available Tags

The playbooks use tags to control which parts of the infrastructure are deployed. Here's a comprehensive list of available tags:

#### Main Deployment Tags
- `full`: Deploy the complete stack (equivalent to running all stages)
- `router`: Configure the Raspberry Pi router node (WiFi AP, networking)
- `k3s`: Set up the K3s Kubernetes cluster
- `core`: Deploy all core services (Grafana, InfluxDB, Jenkins)
- `apps`: Deploy all StockOps applications (news and stock fetchers)

#### Core Service Tags
- `grafana`: Deploy only Grafana dashboard service
- `influxdb`: Deploy only InfluxDB time-series database
- `jenkins`: Deploy only Jenkins CI/CD service

#### Application Tags
- `apps_stocks`: Deploy only the stock data fetcher
- `apps_news`: Deploy only the news fetcher

#### Preparation Tags
- `prepare`: Run pre-deployment tasks (cgroups, system configs)
- `nfs`: Configure NFS storage setup
- `storage`: Set up persistent volumes and claims

#### Example Usage:

```bash
# Full deployment
ansible-playbook -i inventory.ini play.yml -t full

# Network and cluster setup
ansible-playbook -i inventory.ini play.yml -t router
ansible-playbook -i inventory.ini play.yml -t k3s -e k3s_apply=true

# Core services deployment
ansible-playbook -i inventory.ini play.yml -t core
# Or deploy services individually
ansible-playbook -i inventory.ini play.yml -t grafana
ansible-playbook -i inventory.ini play.yml -t influxdb,jenkins

# Applications deployment
ansible-playbook -i inventory.ini play.yml -t apps
# Or deploy apps individually
ansible-playbook -i inventory.ini play.yml -t apps_stocks
ansible-playbook -i inventory.ini play.yml -t apps_news
```

You can combine tags with commas to run multiple stages: `-t grafana,influxdb`

---

## Development Hygiene

This repository enforces YAML and Ansible quality gates via **pre-commit hooks**.

### Pre-commit configuration

The `.pre-commit-config.yaml` file includes:
- **`ansible-lint`** — ensures best practices in roles/playbooks  
- **`yamllint`** — validates YAML syntax and structure  
- **`pre-commit-hooks`** — trims trailing spaces, checks end-of-file newlines, and ensures file hygiene

To enable locally:

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

---

## Contributing

1. Fork and clone the repository  
2. Make changes to your role or playbook under `ansible_collections/stockops/core/`  
3. Test locally using `ansible-playbook -i inventory.ini play.yml -t your_tag`  
4. Submit a pull request

---

## License

This project is licensed under the **MIT License**.

---

## Author

**Meir A. (tomeir2105)**  
Built with dedication, patience, and curiosity — to make DevOps, automation, and data analytics accessible on low-cost hardware.
