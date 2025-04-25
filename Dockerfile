FROM bitnami/kubectl:latest

# Create a directory for the script
WORKDIR /app
COPY restart-deployments.sh /app/restart-deployments.sh

# Switch to root to set permissions, then revert to non-root user
USER root
RUN chmod +x /app/restart-deployments.sh
# Revert to the non-root user (default in bitnami/kubectl)
USER 1001

# Set the entrypoint
ENTRYPOINT ["/app/restart-deployments.sh"]
