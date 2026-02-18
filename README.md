# Docker Monorepo

A monorepo structure for managing multiple Docker image projects with shared
CI/CD workflows, pre-commit hooks, and development tools.

## Projects

| Project | Description | Status |
|---------|-------------|--------|
| **[caddy-cloudflaredns](./caddy-cloudflaredns/)** | Caddy + Cloudflare DNS for automatic TLS | [![Docker Build][caddy-workflow-badge]][caddy-workflow-url] |
| **[jenkinsapi](./jenkinsapi/)** | Jenkins + Python test environment | [![Docker Build][jenkins-workflow-badge]][jenkins-workflow-url] |

## Key Features

- **Per-project CI/CD**: Workflows trigger only when project files change (using `paths:` filter)
- **Shared tooling**: Common pre-commit hooks, linting rules, and development guidelines
- **Easy scaling**: Add new projects without duplicating infrastructure
- **Root-level delegation**: Use `make` targets from the root to run tests/builds for any project

## Quick Start

### Clone the Repository

```bash
git clone https://github.com/clintonsteiner/docker-monorepo.git
cd docker-monorepo
```

### Install Development Tools

```bash
make install-hooks
```

### Build All Projects

```bash
make build-all
```

### Test All Projects

```bash
make test-all
```

### View Available Commands

```bash
make help
```

## Project-Specific Development

Each project has its own Makefile and can be developed independently:

```bash
cd caddy-cloudflaredns
make help
make build
make test
```

Or use root-level delegation:

```bash
make test-caddy
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, testing guidelines, and the pull request process.

## Project Details

### caddy-cloudflaredns

A Docker image for [Caddy](https://caddyserver.com/) with built-in support for
DNS validation using Cloudflare DNS. This enables automatic TLS certificate
generation and renewal for domains managed on Cloudflare.

- **Repository**: [caddy-cloudflaredns](./caddy-cloudflaredns/)
- **Docker Hub**: `docker.io/clintonsteiner/caddy-cloudflaredns`
- **GitHub Container Registry**: `ghcr.io/clintonsteiner/caddy-cloudflaredns`
- **Quay Container Registry**: `quay.io/clintonsteiner/caddy-cloudflaredns`

[Learn more about caddy-cloudflaredns →](./caddy-cloudflaredns/README.md)

### jenkinsapi

Production-ready Jenkins with pre-configured plugins and a Python test environment for running jenkinsapi tests.

- **Repository**: [jenkinsapi](./jenkinsapi/)
- **Images**:
  - `jenkinsapi:latest` - Jenkins LTS with pre-installed plugins
  - `jenkinsapi-test:latest` - Python test environment for pytest
- **GitHub Container Registry**: `ghcr.io/clintonsteiner/jenkinsapi`

[Learn more about jenkinsapi →](./jenkinsapi/README.md)

## Adding a New Project

To add a new project to the monorepo:

1. Create the project directory structure
2. Copy/create `Dockerfile`, `Makefile`, `README.md`, and test scripts
3. Create a new workflow file in `.github/workflows/new-project.yml`
4. Add dependency configuration to `.github/dependabot.yml`
5. Add delegating targets to the root `Makefile`
6. Update this README with the new project

See [CONTRIBUTING.md#adding-a-new-project](CONTRIBUTING.md#adding-a-new-project) for detailed instructions.

## CI/CD Architecture

### Workflow Triggering

Each project has its own GitHub Actions workflow file that triggers only when:

- Changes are pushed to the `master` branch
- Files within the project directory change (using `paths:` filter)
- The workflow is manually dispatched

Example from `caddy-cloudflaredns-build-optimized.yml`:

```yaml
on:
  push:
    branches: [master]
    paths:
      - 'caddy-cloudflaredns/**'
      - '.github/workflows/caddy-cloudflaredns-build-optimized.yml'
  workflow_dispatch:
```

### Dependency Updates

[Dependabot](https://docs.github.com/en/code-security/dependabot) automatically checks for updates to:

- Docker base images (per project)
- GitHub Actions

Configuration: [.github/dependabot.yml](.github/dependabot.yml)

## Development Workflow

```
Your Branch
    ↓
Pre-commit hooks (local)
    ↓
Push to GitHub
    ↓
GitHub Actions (per-project workflow)
    ├─ Tests
    ├─ Build
    ├─ Push to registries
    └─ Create release
```

## Directory Structure

```
docker-monorepo/
├── .github/
│   ├── workflows/
│   │   ├── caddy-cloudflaredns-build-optimized.yml  # caddy CI/CD (build-once-reuse)
│   │   ├── jenkinsapi-build-optimized.yml            # jenkinsapi CI/CD (build-once-reuse)
│   │   └── test-all.yml                              # Blocking test suite
│   └── dependabot.yml                     # Automated dependency updates
├── .pre-commit-config.yaml                # Shared pre-commit hooks
├── .gitignore                             # Shared git exclusions
├── Makefile                               # Root delegating Makefile
├── README.md                              # This file
├── CONTRIBUTING.md                        # Development guidelines
└── caddy-cloudflaredns/
    ├── Dockerfile
    ├── README.md                          # Project-specific docs
    ├── Makefile                           # Project-specific targets
    └── test/
        └── test-image.sh
```

## License

Each project is released under its respective license. See individual project READMEs for details.

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
- [Docker Documentation](https://docs.docker.com/)

---

[caddy-workflow-badge]: https://img.shields.io/github/actions/workflow/status/clintonsteiner/docker-monorepo/caddy-cloudflaredns-build-optimized.yml?style=flat-square
[caddy-workflow-url]: https://github.com/clintonsteiner/docker-monorepo/actions/workflows/caddy-cloudflaredns-build-optimized.yml

[jenkins-workflow-badge]: https://img.shields.io/github/actions/workflow/status/clintonsteiner/docker-monorepo/jenkinsapi-build-optimized.yml?style=flat-square
[jenkins-workflow-url]: https://github.com/clintonsteiner/docker-monorepo/actions/workflows/jenkinsapi-build-optimized.yml
