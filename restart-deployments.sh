#!/bin/bash
# Get all namespaces
namespaces=$(kubectl get namespaces -o jsonpath="{.items[*].metadata.name}")

# Loop through each namespace
for ns in $namespaces; do
  # Skip kube-system to avoid restarting critical components (optional)
  if [[ "$ns" == "kube-system" || "$ns" == "kube-custom" ]]; then
    continue
  fi
  # Get all deployments in the namespace
  deployments=$(kubectl get deployments -n "$ns" -o jsonpath="{.items[*].metadata.name}")

  # Restart each deployment
  for dep in $deployments; do
    echo "Restarting deployment $dep in namespace $ns"
    kubectl rollout restart deployment "$dep" -n "$ns"
  done
done
