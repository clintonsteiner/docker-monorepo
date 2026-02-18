# jenkinsapi

Docker images for running Jenkins with pre-configured plugins and Python test
environment for running jenkinsapi tests.

## Overview

This project provides two Docker images:

1. **Jenkins Image** (`Dockerfile`) - Production-ready Jenkins with
   pre-installed plugins
2. **Test Image** (`Dockerfile.test`) - Python test environment for running
   jenkinsapi tests

## Features

### Jenkins Features

- Jenkins LTS with JDK 25
- Pre-installed plugins from `plugins.txt`
- Optimized Java settings for containerized environments
- Health check endpoint at `/api/json`
- Custom entrypoint for permission management
- Runs SSH slaves and git operations
- Configured for CI/CD workloads

### Test Image Features

- Python 3.13 slim base
- Pre-installed test dependencies (pytest, pytest-xdist, pytest-cov, etc.)
- `uv` package manager for fast dependency resolution
- Virtual environment pre-configured
- Ready for immediate pytest execution

## Prerequisites

- Docker (version 20.10 or later)
- For development: Docker Compose (version 1.29 or later)

## Quick Start

### Building Images

```bash
# Build Jenkins image
make build

# Build test image
make build-test

# Build both
make build build-test
```

### Running Tests

```bash
# Build and run full test suite
make test

# Run quick tests (requires images already built)
make test-quick
```

### Running Jenkins

```bash
# Start Jenkins container interactively
docker run -it --rm \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  jenkinsapi:test
```

Jenkins will be available at `http://localhost:8080`

### Running Test Commands

```bash
# Run pytest with specific tests
docker run --rm \
  -v /path/to/jenkinsapi:/workspace \
  jenkinsapi-test:test \
  pytest jenkinsapi_tests/test_example.py

# Run with specific pytest options
docker run --rm \
  -v /path/to/jenkinsapi:/workspace \
  jenkinsapi-test:test \
  pytest -v --tb=short jenkinsapi_tests/
```

## Available Make Targets

```bash
make build              # Build Jenkins image
make build-test        # Build test image
make test              # Build both images and run tests
make test-quick        # Run tests (requires images already built)
make lint              # Run all linters
make lint-docker       # Lint Dockerfiles
make lint-yaml         # Validate YAML files
make lint-markdown     # Check Markdown
make format            # Auto-fix formatting
make validate          # Validate Jenkins configuration
make clean             # Clean up images and artifacts
make shell             # Open interactive shell in Jenkins
make version           # Show Jenkins version
make help              # Display help
```

## Environment Variables

### Jenkins Image

| Variable | Default | Description |
|----------|---------|-------------|
| `JAVA_OPTS` | See Dockerfile | JVM configuration for Jenkins |

### Test Image

| Variable | Default | Description |
|----------|---------|-------------|
| `PYTHONPATH` | `/workspace:$PYTHONPATH` | Python module search path |

## Volumes

### Jenkins Data Volumes

| Volume | Purpose |
|--------|---------|
| `/var/jenkins_home` | Jenkins data, configuration, and plugins |

### Test Image Volumes

| Volume | Purpose |
|--------|---------|
| `/workspace` | Project directory for testing |

## Ports

### Jenkins Service Ports

| Port | Purpose |
|------|---------|
| `8080` | Jenkins web interface |
| `50000` | Jenkins agent (SSH slave) connections |

## Version Management

### Jenkins Version

The Jenkins version is managed through the `JENKINS_VERSION` file:

```bash
# View current Jenkins version
cat JENKINS_VERSION

# Update Jenkins version
echo "lts-jdk25" > JENKINS_VERSION
make build
```

The version is automatically read during the build process and passed as a build argument.

### Plugin Updates

To check for available plugin updates:

```bash
# Run the update checker script
./scripts/update-plugins.sh
```

This script will:
- Query the Jenkins plugins API for each plugin
- Display current vs. available versions
- Count total plugins and updates available
- Provide guidance on updating plugins

To update plugins manually:

1. Check for updates: `./scripts/update-plugins.sh`
2. Update versions in `plugins.txt`
3. Rebuild the image: `make build`
4. Test the build: `make test`

### Automated Update Checks

The monorepo includes a GitHub Actions workflow that automatically checks for Jenkins and plugin updates weekly:

- **Workflow**: `.github/workflows/jenkins-update-check.yml`
- **Schedule**: Runs every Sunday at 2 AM UTC
- **Trigger**: Can also be manually triggered via workflow_dispatch
- **Actions**: Creates GitHub issues when updates are available

The workflow output includes:
- Current vs. latest Jenkins LTS version
- Count of available plugin updates
- Detailed action items for updating

## Plugins Included

The Jenkins image includes pre-configured plugins for:

- Git and SSH integration
- Workflow and Pipeline support
- Matrix project support
- Credential management
- Email notifications
- And more (see `plugins.txt`)

## Development Setup

### Install Pre-commit Hooks

```bash
make install-hooks
```

### Running Linters

```bash
# All linters
make lint

# Specific linters
make lint-docker
make lint-yaml
make lint-markdown
```

### Auto-fix Issues

```bash
make format
```

## Health Check

The Jenkins image includes a health check that verifies Jenkins is responding:

```bash
# Health check manually
curl -f http://localhost:8080/api/json || exit 1
```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for development setup, testing
guidelines, and the pull request process.

## License

This project uses Jenkins, which is licensed under the MIT License.

## References

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Jenkins Docker Hub](https://hub.docker.com/_/jenkins)
- [jenkinsapi GitHub](https://github.com/pycontribs/jenkinsapi)
- [Docker Documentation](https://docs.docker.com/)
