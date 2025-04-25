#! /bin/bash

docker buildx build \
  --builder cloud-unicolored-my-cloud-builder \
  --sbom=true \
  --provenance=true \
  --push \
  -t unicolored/k8s-restart-deployments:latest .
