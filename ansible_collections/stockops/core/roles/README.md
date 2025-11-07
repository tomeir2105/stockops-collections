# StockOps Roles

This directory contains all the Ansible roles used in the StockOps platform. Each role is designed to be modular and reusable, following Ansible best practices.

## Role Categories

### Infrastructure Roles
- **router**: Network configuration and routing
- **k3s**: Kubernetes cluster management
- **common**: Shared utilities and configurations

### Service Roles
- **influxdb**: Time-series database deployment
- **grafana**: Monitoring and visualization
- **jenkins**: CI/CD pipeline infrastructure

### Application Roles
- **apps_news**: News data collection services
- **apps_stocks**: Stock data collection services

## Role Structure

Each role follows the standard Ansible role structure:
```
role_name/
├── defaults/       # Default variables
├── files/         # Static files
├── handlers/      # Notification handlers
├── meta/          # Role metadata
├── tasks/         # Core task definitions
├── templates/     # Jinja2 templates
├── tests/         # Role tests
└── vars/          # Role variables
```

## Development Guidelines

1. **Variable Naming**:
   - Use descriptive names
   - Prefix variables with role name
   - Document all variables in defaults/main.yml

2. **Task Organization**:
   - Break complex tasks into separate files
   - Use meaningful task names
   - Include proper tags for selective execution

3. **Testing**:
   - Include molecule tests where possible
   - Provide example playbooks
   - Document test procedures

4. **Documentation**:
   - Maintain README.md in each role
   - Document all variables and dependencies
   - Include usage examples

## Usage

Roles are called from the main playbooks in the root directory:
```yaml
- name: Example usage
  hosts: all
  roles:
    - stockops.core.common
    - stockops.core.k3s
    # etc...
```

## Contributing

1. Create a new branch for your role changes
2. Follow the role structure and guidelines
3. Include tests and documentation
4. Submit a pull request

## License

All roles are covered under the project's MIT License