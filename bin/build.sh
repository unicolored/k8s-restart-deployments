#! /bin/bash

docker buildx build \
  --builder cloud-unicolored-my-cloud-builder \
  --push \
  -t unicolored/k8s-restart-deployments:latest .
