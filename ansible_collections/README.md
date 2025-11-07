# Ansible Collections Directory

This directory contains the Ansible collections used in the StockOps project. Currently, it houses the `stockops.core` collection which is the heart of our automation and deployment infrastructure.

## Structure

```
ansible_collections/
└── stockops/
    └── core/
        ├── roles/         # Individual automation roles
        ├── plugins/       # Custom plugins and modules
        ├── docs/          # Documentation and examples
        └── meta/          # Collection metadata
```

## Collections Overview

### stockops.core
The main collection that provides all the automation necessary for deploying and managing the StockOps platform. It includes:
- Infrastructure setup (router, K3s cluster)
- Service deployment (InfluxDB, Grafana, Jenkins)
- Application deployment (stock and news data collectors)
- Common utilities and shared configurations

## Usage

The collections are automatically used by the main playbooks in the root directory. You don't need to install them separately as they are part of the repository.

For development:
1. Make changes within the appropriate collection directory
2. Test using the main playbooks
3. Follow the project's contribution guidelines for submitting changes