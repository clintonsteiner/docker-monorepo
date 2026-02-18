# Single stage build for Jenkins with pre-installed plugins
# Use a recent LTS Jenkins version with JDK 21
FROM jenkins/jenkins:lts-jdk25

# Install system utilities and setup Jenkins
USER root
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        iputils-ping && \
    mkdir -p /var/jenkins_home && \
    chmod 777 /var/jenkins_home

# Copy plugins.txt and entrypoint script early for better layer caching
COPY plugins.txt /tmp/plugins.txt
COPY jenkins-entrypoint.sh /usr/local/bin/jenkins-entrypoint.sh

# Install plugins and setup entrypoint in single layer
RUN jenkins-plugin-cli --plugin-file /tmp/plugins.txt --verbose --latest=false && \
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
