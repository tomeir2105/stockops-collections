# /home/user/stockops-collections/ansible_collections/stockops/core/roles/k3s/README.md

## Purpose
Apply or server-validate Kubernetes manifests staged under this role without installing new tools on the controller. The role auto-detects whether to run locally (controller) or delegate to a remote node (e.g., `k3s1`) that already has `kubectl` and cluster access.

## How it works
- **Stage A (`tasks/10_gather_info.yml`)**: Detects capabilities on the controller and delegate:
  - Controller: `kubectl` present? Python `kubernetes` importable? Kubeconfig exists?
  - Delegate (default `k3s1`): `kubectl` present? Kubeconfig exists?
  - Sets `k3s_apply_executor` → `controller` | `delegate` | `none`
- **Stage B (`tasks/20_apply_manifests.yml`)**:
  - Collects `files/staged/*.yml`
  - If `k3s_apply: false` → validates with `kubectl --dry-run=server`
  - If `k3s_apply: true`:
    - Uses `kubernetes.core.k8s` when controller has Python client
    - Otherwise falls back to `kubectl apply -f -` on the chosen executor

## Variables (defaults in `defaults/main.yml`)
```yaml
k3s_apply: false                         # false = validation only; true = real apply
k3s_delegate_host: "k3s1"                # node that already has kubectl + cluster access
k3s_kubeconfig: "~/.kube/k3s1.config"    # controller path (if controller executes)
k3s_remote_kubeconfig: "/etc/rancher/k3s/k3s.yaml"  # delegate path

