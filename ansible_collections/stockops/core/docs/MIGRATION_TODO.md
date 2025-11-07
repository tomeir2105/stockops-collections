# Migration TODO (auto-generated)

## k3s
  - ./k3s-03-agents-install.yml
  - ./k3s-99-utils.yml
  - ./k3s-01-cgroups.yml
  - ./k3s-prepare.yml
  - ./k2s-02-server-install.yml

## influxdb
  - ./deploy-03-stockops.yml
  - ./deploy-01-nfs-export.yml
  - ./deploy-02-nfs-verify.yml
  - ./create-stocks-monitor-bucket.yml
  - ./create-influx-org-bucket.yml
  - ./deploy-00-prepull.yml
  - ./create-monitor-bucket.yml

## grafana
  - ./create-grafana-token.yml
  - ./create-monitor-dash.yml
  - ./create-stockops-dash.yml

## apps_news
  - ./run-news-pod.yml

## apps_stocks
  - ./run-stocks-pod.yml

### Notes
- Keep secrets/real vars out of git; push only examples (docs/examples/*.example).
- Convert staged YAML to templates/ with Jinja vars from vars.yml.example and group_vars examples.
- Replace shell installers with idempotent Ansible tasks where possible.
