# k8s-restart-deployments

A Kubernetes `CronJob` to restart all deployments daily at 23:00 UTC, excluding `kube-system` and `kube-custom` namespaces. This project provides a Docker image and Kubernetes manifests to automate deployment restarts in a Kubernetes cluster.

The Docker image is publicly available at [Docker Hub: unicolored/k8s-restart-deployments](https://hub.docker.com/r/unicolored/k8s-restart-deployments). The repository includes a shell script, Dockerfile, and Kustomize manifests to deploy the `CronJob` with proper RBAC permissions.

## Features

- **Daily Restarts**: Runs at 23:00 UTC to gracefully restart all deployments using `kubectl rollout restart`.
- **Namespace Exclusions**: Skips `kube-system` and `kube-custom` to avoid disrupting critical components.
- **Kubernetes-Native**: Uses a `CronJob` for scheduling and RBAC for secure access.
- **Kustomize Support**: Applies a `cron-restart-` prefix and `kube-custom` namespace for easy customization.
- **Public Docker Image**: Lightweight image based on `bitnami/kubectl` for executing the restart script.

## Prerequisites

- A Kubernetes cluster (v1.19 or later).
- `kubectl` configured with cluster access.
- Kustomize (or `kubectl` with Kustomize support, v1.14+).
- Permissions to create namespaces, `ServiceAccount`, `ClusterRole`, `ClusterRoleBinding`, and `CronJob`.

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/unicolored/k8s-restart-deployments.git
cd k8s-restart-deployments
```

### 2. Review the Docker Image

The Docker image is available at `docker.io/unicolored/k8s-restart-deployments`. It contains:

- A shell script (`restart-deployments.sh`) to list and restart deployments.
- A base image (`bitnami/kubectl`) for `kubectl` commands.

To pull the image:

```bash
docker pull unicolored/k8s-restart-deployments:latest
```

### 3. Deploy with Kustomize

The repository includes Kustomize manifests in the `kustomize/` directory:

- `rbac.yaml`: Defines `ServiceAccount`, `ClusterRole`, and `ClusterRoleBinding`.
- `cronjob.yaml`: Defines the `CronJob` to run daily at 23:00 UTC.
- `kustomization.yaml`: Applies `namePrefix: cron-restart-` and `namespace: kube-custom`, and patches the `ClusterRoleBinding`.

To deploy:

```bash
kubectl apply -k kustomize/
```

This creates:

- `ServiceAccount: cron-restart-restart-deployments-sa` in `kube-custom`.
- `ClusterRole: cron-restart-restart-deployments-role`.
- `ClusterRoleBinding: cron-restart-restart-deployments-binding`.
- `CronJob: cron-restart-restart-deployments` in `kube-custom`.

### 4. Verify the Deployment

Check the resources:

```bash
kubectl get namespace kube-custom
kubectl get serviceaccount,cronjob -n kube-custom
kubectl get clusterrole cron-restart-deployments-role
kubectl get clusterrolebinding cron-restart-deployments-binding
```

Run a manual job to test:

```bash
kubectl create job --from=cronjob/cron-restart-cronjob-deployments manual-test-job -n kube-custom
kubectl get jobs -n kube-custom
kubectl get pods -n kube-custom
kubectl logs <pod-name> -n kube-custom
```

Verify deployments were restarted (excluding `kube-system` and `kube-custom`):

```bash
kubectl get pods --all-namespaces -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name,CREATION:.metadata.creationTimestamp"
```

### 5. Confirm the Schedule

Ensure the `CronJob` is scheduled for 23:00 UTC:

```bash
kubectl get cronjob cron-restart-cronjob-deployments -n kube-custom -o yaml | grep schedule
```

Expected: `schedule: "0 23 * * *"`

Check for suspension:

```bash
kubectl get cronjob cron-restart-cronjob-deployments -n kube-custom -o yaml | grep suspend
```

If `suspend: true`, enable the `CronJob`:

```bash
kubectl patch cronjob cron-restart-cronjob-deployments -n kube-custom -p '{"spec":{"suspend":false}}'
```

## Customization

- **Change Schedule**: Edit `cronjob.yaml` to adjust the `spec.schedule` (e.g., `0 20 * * *` for 20:00 UTC).
- **Modify Excluded Namespaces**: Update `restart-deployments.sh` to exclude additional namespaces:
  ```bash
  if [[ "$ns" == "kube-system" || "$ns" == "kube-custom" || "$ns" == "other-namespace" ]]; then
    continue
  fi
  ```
  Rebuild and push the Docker image:
  ```bash
  docker build -t unicolored/k8s-restart-deployments:latest .
  docker push unicolored/k8s-restart-deployments:latest
  ```
- **Change Namespace or Prefix**: Edit `kustomization.yaml` to modify `namespace` or `namePrefix`.
- **Private Registry**: Add `imagePullSecrets` to `cronjob.yaml` if using a private registry.

## Files

- `Dockerfile`: Builds the Docker image with `restart-deployments.sh`.
- `restart-deployments.sh`: Script to restart deployments, excluding `kube-system` and `kube-custom`.
- `kustomize/rbac.yaml`: Defines RBAC resources.
- `kustomize/cronjob.yaml`: Defines the `CronJob`.
- `kustomize/kustomization.yaml`: Applies Kustomize customizations.

## Troubleshooting

- **Image Pull Errors**: Ensure the cluster can access `docker.io/unicolored/k8s-restart-deployments:latest`.
- **RBAC Errors**: Verify the `ClusterRole` and `ClusterRoleBinding`:
  ```bash
  kubectl describe clusterrole cron-restart-deployments-role
  kubectl describe clusterrolebinding cron-restart-deployments-binding
  ```
- **No Restarts**: Check if deployments exist in non-excluded namespaces:
  ```bash
  kubectl get deployments --all-namespaces
  ```
- **CronJob Not Running**: Confirm the schedule and time zone (UTC). Check `kubectl describe cronjob`.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit changes (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

Please include tests and documentation for new features.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For questions or issues, open an issue on [GitHub](https://github.com/unicolored/k8s-restart-deployments/issues) or contact the maintainer at [your-email@example.com] (replace with your email if desired).
