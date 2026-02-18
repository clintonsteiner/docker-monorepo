# Single stage build for Jenkins with pre-installed plugins
# Jenkins version is managed in JENKINS_VERSION file for consistency with CI/CD
ARG JENKINS_VERSION=lts-jdk21
FROM jenkins/jenkins:${JENKINS_VERSION}

# Install system utilities with aggressive caching
USER root
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/root/.cache,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        iputils-ping && \
    mkdir -p /var/jenkins_home && \
    chmod 777 /var/jenkins_home

# Copy all setup files (reordered for optimal caching)
COPY --link jenkins-entrypoint.sh /usr/local/bin/jenkins-entrypoint.sh
COPY --link plugins.txt /tmp/plugins.txt

# Install plugins and setup entrypoint with caching
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    jenkins-plugin-cli --plugin-file /tmp/plugins.txt --verbose --latest=false && \
    chmod +x /usr/local/bin/jenkins-entrypoint.sh

USER jenkins

# Set Jenkins configuration for faster startup and optimal performance
# Skip wizard, disable multicast, skip update center checks, enable parallel startup
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false \
  -Dhudson.DNSMultiCast.disabled=true \
  -Dhudson.model.UpdateCenter.never=true \
  -Djenkins.InitReactorRunner.concurrency=4 \
  -XX:+TieredCompilation \
  -XX:TieredStopAtLevel=4 \
  -XX:+UseG1GC \
  -Xms512m \
  -Xmx1024m"

# Health check to verify Jenkins is ready
# Use curl instead of wget, 127.0.0.1 explicitly, longer startup time
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
  CMD curl -f http://127.0.0.1:8080/api/json || exit 1

# Expose Jenkins port
EXPOSE 8080

# Expose Jenkins agent port
EXPOSE 50000

# Use tini as the init process (PID 1) to properly handle signals
# tini is included in the jenkins base image
ENTRYPOINT ["/bin/tini", "--"]

CMD ["/usr/local/bin/jenkins-entrypoint.sh"]
