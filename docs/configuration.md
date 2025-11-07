# Configuration Guide

This document provides detailed information about configuring the StockOps platform components.

## Core Configuration Files

### 1. Inventory Configuration (inventory.ini)
```ini
[k3s_controller]
k3srouter ansible_connection=local

[k3s_nodes]
k3s1 ansible_host=192.168.50.101
k3s2 ansible_host=192.168.50.102
k3s3 ansible_host=192.168.50.103

[k3s_controller:vars]
k3s_delegate_host=k3s1
k3s_kubeconfig=~/.kube/k3s1.config
k3s_remote_kubeconfig=/etc/rancher/k3s/k3s.yaml
```

### 2. Variables Configuration (vars.yml)
Key sections that need to be configured:

#### Network Configuration
```yaml
NAMESPACE: stockops
NODE_IP: 192.168.50.101
SUBNET_CIDR: 192.168.50.0/24
```

#### Storage Configuration
```yaml
NFS_SERVER_IP: 192.168.50.1
NFS_ALLOWED_CIDR: 192.168.50.0/24
NFS_MOUNTPOINT: /mnt/k3s_storage
```

#### Docker Registry
```yaml
DOCKERHUB_USER: your_username
DOCKERHUB_PRIVATE: false
```

## Service-Specific Configuration

### 1. InfluxDB
```yaml
INFLUXDB_ADMIN_USER: admin
INFLUXDB_ADMIN_PASSWORD: "ChangeMe123!"
INFLUXDB_ADMIN_TOKEN: "<YOUR_TOKEN>"
INFLUXDB_ORG: home
INFLUXDB_BUCKET: stockops
```

### 2. Grafana
```yaml
GRAFANA_ADMIN_USER: admin
GRAFANA_ADMIN_PASSWORD: "ChangeMe123!"
GRAFANA_TOKEN: "<YOUR_TOKEN>"
```

### 3. Jenkins
```yaml
JENKINS_ADMIN_USER: admin
JENKINS_ADMIN_PASS: "admin"
JENKINS_PLUGINS:
  - kubernetes
  - git
  - blueocean
```

### 4. Stock Fetcher
```yaml
STOCKS_TICKERS: "AAPL,MSFT,GOOGL"
STOCKS_POLL_SECONDS: "60"
STOCKS_YF_INTERVAL: "1m"
STOCKS_YF_PERIOD: "5d"
```

### 5. News Fetcher
```yaml
NEWS_TICKERS: "AAPL,MSFT,GOOGL"
NEWS_POLL_SECONDS: "120"
```

## Resource Limits

### Core Services
```yaml
# InfluxDB
INFLUXDB_CPU_REQUEST: "200m"
INFLUXDB_CPU_LIMIT: "1000m"
INFLUXDB_MEM_REQUEST: "512Mi"
INFLUXDB_MEM_LIMIT: "2Gi"

# Grafana
GRAFANA_CPU_REQUEST: "100m"
GRAFANA_CPU_LIMIT: "500m"
GRAFANA_MEM_REQUEST: "256Mi"
GRAFANA_MEM_LIMIT: "1Gi"

# Jenkins
JENKINS_CPU_REQUEST: "200m"
JENKINS_CPU_LIMIT: "1000m"
JENKINS_MEM_REQUEST: "512Mi"
JENKINS_MEM_LIMIT: "2Gi"
```

### Data Fetchers
```yaml
# Stocks Fetcher
STOCKS_CPU_REQUEST: "75m"
STOCKS_CPU_LIMIT: "300m"
STOCKS_MEM_REQUEST: "128Mi"
STOCKS_MEM_LIMIT: "256Mi"

# News Fetcher
NEWS_CPU_REQUEST: "50m"
NEWS_CPU_LIMIT: "250m"
NEWS_MEM_REQUEST: "96Mi"
NEWS_MEM_LIMIT: "192Mi"
```

## Storage Configuration

### Persistent Volumes
```yaml
APP_PVCS:
  - { name: jenkins-pvc,  pv: jenkins-pv }
  - { name: news-pvc,     pv: news-pv }
  - { name: stocks-pvc,   pv: stocks-pv }
  - { name: grafana-pvc,  pv: pv-grafana }
  - { name: influxdb-pvc, pv: influxdb-pv }
```

### Storage Sizes
```yaml
JENKINS_STORAGE: 10Gi
GRAFANA_STORAGE: 5Gi
INFLUXDB_STORAGE: 20Gi
STOCKS_STORAGE: 1Gi
NEWS_STORAGE: 1Gi
```

## Security Considerations

1. Change all default passwords before production use
2. Use secrets management for sensitive data
3. Configure proper firewall rules
4. Enable TLS for service endpoints
5. Regularly update security tokens
6. Monitor system logs for security events

## Performance Tuning

1. Adjust polling intervals based on needs
2. Monitor resource usage and adjust limits
3. Configure data retention policies
4. Optimize storage allocation
5. Fine-tune K3s cluster settings

## Backup Configuration

1. Set up regular NFS backups
2. Configure InfluxDB backups
3. Back up Grafana dashboards
4. Export Jenkins configurations
5. Document restore procedures