# Troubleshooting Guide

This guide helps you diagnose and resolve common issues in the StockOps platform.

## Common Issues and Solutions

### 1. Installation Issues

#### K3s Node Join Fails
```bash
# Check node status
kubectl get nodes

# Common solutions:
1. Verify network connectivity
2. Check firewall settings
3. Validate token in /var/lib/rancher/k3s/server/node-token
4. Ensure proper DNS resolution
```

#### NFS Mount Problems
```bash
# Check NFS server
showmount -e 192.168.50.1

# Verify mount points
df -h | grep k3s_storage

# Common solutions:
1. Restart NFS service
2. Check export permissions
3. Verify network connectivity
4. Check mount options
```

### 2. Service Issues

#### Pods Not Starting
```bash
# Check pod status
kubectl get pods -n stockops
kubectl describe pod <pod-name> -n stockops

# Common solutions:
1. Check resource limits
2. Verify storage availability
3. Check image pull status
4. Review pod logs
```

#### Service Connectivity
```bash
# Test service endpoints
curl -I http://192.168.50.101:30030  # Grafana
curl -I http://192.168.50.101:30886  # InfluxDB
curl -I http://192.168.50.101:30080  # Jenkins

# Common solutions:
1. Verify service NodePorts
2. Check network policies
3. Validate service configuration
4. Review proxy settings
```

### 3. Data Collection Issues

#### Stock Fetcher Problems
```bash
# Check logs
kubectl logs -n stockops -l app=stockops-stocks

# Common issues:
1. API rate limits
2. Invalid tickers
3. Network connectivity
4. Storage issues
```

#### News Fetcher Problems
```bash
# Check logs
kubectl logs -n stockops -l app=stockops-news

# Common issues:
1. News API access
2. Invalid configuration
3. Storage capacity
4. Rate limiting
```

### 4. Monitoring Issues

#### Grafana Problems
```bash
# Check status
kubectl get pods -n stockops -l app=grafana
kubectl logs -n stockops -l app=grafana

# Common issues:
1. Database connectivity
2. Dashboard permissions
3. Plugin compatibility
4. Storage problems
```

#### InfluxDB Issues
```bash
# Verify database
kubectl exec -it -n stockops <influxdb-pod> -- influx ping

# Common issues:
1. Authentication tokens
2. Storage capacity
3. Query performance
4. Retention policies
```

### 5. System Resources

#### Node Resources
```bash
# Check node resources
kubectl top nodes
kubectl describe node <node-name>

# Common issues:
1. CPU pressure
2. Memory constraints
3. Storage capacity
4. Network bandwidth
```

#### Pod Resources
```bash
# Monitor pod resources
kubectl top pods -n stockops
kubectl describe pod <pod-name> -n stockops

# Common issues:
1. Resource limits too low
2. Memory leaks
3. CPU throttling
4. Storage bottlenecks
```

## Diagnostic Commands

### System Health
```bash
# Node status
kubectl get nodes -o wide

# Pod status
kubectl get pods -A -o wide

# Events
kubectl get events -n stockops

# Logs
kubectl logs -n stockops <pod-name> --previous
```

### Storage
```bash
# PV/PVC status
kubectl get pv,pvc -n stockops

# Storage class
kubectl get sc

# Node storage
df -h
```

### Network
```bash
# Service status
kubectl get svc -n stockops

# Endpoints
kubectl get ep -n stockops

# Network policies
kubectl get netpol -n stockops
```

## Recovery Procedures

### 1. Service Recovery
```bash
# Restart service
kubectl rollout restart deployment <deployment-name> -n stockops

# Scale deployment
kubectl scale deployment <deployment-name> -n stockops --replicas=0
kubectl scale deployment <deployment-name> -n stockops --replicas=1
```

### 2. Node Recovery
```bash
# Drain node
kubectl drain <node-name> --ignore-daemonsets

# Reset K3s
/usr/local/bin/k3s-agent-uninstall.sh
/usr/local/bin/k3s-uninstall.sh

# Rejoin cluster
# Re-run ansible playbook with k3s tag
```

### 3. Data Recovery
```bash
# Restore from backup
# Follow backup restoration procedures for each service
# Verify data integrity after restore
```

## Prevention Tips

1. Regular monitoring of system resources
2. Proactive maintenance schedule
3. Regular backup verification
4. System updates planning
5. Resource usage trending
6. Performance benchmarking

## Getting Help

1. Check the documentation
2. Review GitHub issues
3. Consult the community
4. Open a new issue with:
   - Detailed description
   - Relevant logs
   - System information
   - Steps to reproduce