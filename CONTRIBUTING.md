# Contributing to Docker Monorepo

Thank you for your interest in contributing! This document provides guidelines for development, testing, and submitting pull requests.

## Prerequisites

- Docker (version 20.10 or later)
- Bash shell
- Git
- Python 3.7+ (for pre-commit hooks)

## Developer Setup

### 1. Clone and Setup

```bash
git clone https://github.com/clintonsteiner/docker-monorepo.git
cd docker-monorepo
```

### 2. Install Pre-commit Hooks

Pre-commit hooks automatically validate code quality on every commit:

```bash
pip install pre-commit
pre-commit install
```

To manually run all checks:

```bash
pre-commit run --all-files
```

Pre-commit checks include:

- **Dockerfile linting** (hadolint) - Detects common Docker mistakes
- **YAML validation** (yamllint) - Ensures valid YAML syntax
- **Markdown linting** (markdownlint) - Consistency in documentation
- **File hygiene** - Removes trailing whitespace, adds EOF newlines, detects merge conflicts

### 3. Building and Testing

Each project has its own Makefile. From the root, use delegating targets:

#### Build a Project

```bash
make build-caddy
# or go to the project and run:
cd caddy-cloudflaredns && make build
```

#### Run Tests

```bash
make test-caddy
# or run all tests:
make test-all
```

The test script verifies:

- ✓ Image builds successfully
- ✓ Caddy binary exists and is executable
- ✓ Caddy version matches Dockerfile specification
- ✓ Cloudflare DNS module is installed
- ✓ Caddy configuration validation works

#### Manual Testing

Test with a sample Caddyfile:

```bash
docker run -it --rm \
  -e ACME_AGREE=true \
  -e CLOUDFLARE_EMAIL=test@example.com \
  -e CLOUDFLARE_API_TOKEN=test_token \
  caddy-cloudflaredns:test \
  /usr/bin/caddy version
```

## Project Structure

```
docker-monorepo/
├── .github/
│   ├── workflows/
│   │   └── caddy-cloudflaredns.yml        # Project-specific CI/CD
│   └── dependabot.yml                     # Dependency updates
├── .pre-commit-config.yaml                # Shared pre-commit hooks
├── .gitignore                             # Shared git rules
├── Makefile                               # Root delegating targets
├── README.md                              # Monorepo overview
├── CONTRIBUTING.md                        # This file
└── caddy-cloudflaredns/
    ├── Dockerfile
    ├── README.md
    ├── Makefile
    └── test/
        └── test-image.sh
```

## Making Changes

### For Documentation Updates

1. Edit relevant `.md` files
2. Run `pre-commit run --all-files` to validate markdown
3. Test any code examples locally
4. Commit and push

### For Dockerfile Changes

1. Edit the project's `Dockerfile` (e.g., `caddy-cloudflaredns/Dockerfile`)
2. Run `docker build .` in the project directory to verify syntax
3. Run the project's test suite: `make -C caddy-cloudflaredns test`
4. Pre-commit hooks will automatically validate with hadolint
5. Commit and push

### Caddy Version Updates

When updating the Caddy version:

1. Update both `FROM caddy:X.X.X-builder` and `FROM caddy:X.X.X` lines in the Dockerfile
2. Ensure both versions match
3. The test script will automatically validate the version change
4. Run all tests before committing

Example:

```dockerfile
FROM caddy:2.10.2-builder AS builder
# ... build stage ...
FROM caddy:2.10.2
```

## Git Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

Use descriptive branch names:
- `feature/add-xyz` - New functionality
- `fix/issue-xyz` - Bug fixes
- `docs/update-xyz` - Documentation updates

### 2. Make Your Changes

- Keep commits focused on a single logical change
- Write clear commit messages (imperative mood)
- Test your changes locally before committing

### 3. Pre-commit Hooks

Hooks run automatically when you commit. If a check fails:

1. Fix the issue as suggested
2. Stage the changes: `git add .`
3. Try committing again

To skip hooks (not recommended):

```bash
git commit --no-verify
```

### 4. Push and Create a Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub. In your PR description:

- Summarize your changes
- Reference any related issues (#123)
- Describe testing performed
- Note any breaking changes

## Pull Request Checklist

Before submitting a PR, ensure:

- [ ] Tests pass locally (`make test-all`)
- [ ] Pre-commit checks pass (`pre-commit run --all-files`)
- [ ] Documentation is updated if needed
- [ ] Commit messages are clear and descriptive
- [ ] No credentials or secrets are committed
- [ ] Changes follow the existing code style

## Automated Checks

When you push to GitHub:

1. **Project-specific workflow triggers** - Only workflows matching modified project paths run
2. **Tests** run first - Must pass before build proceeds
3. **Build** creates multi-platform images (amd64, arm64, arm/v8, arm/v7)
4. **Push** publishes to Docker Hub, GHCR, and Quay registries
5. **Release** creates a GitHub release with the version tag
6. **Dependabot** automatically creates PRs for dependency updates

## Common Issues

### Pre-commit Hook Failures

**Issue:** `hadolint: command not found`

**Solution:** Pre-commit downloads hooks automatically. Try again:

```bash
pre-commit run --all-files --verbose
```

**Issue:** Markdown or YAML check fails

**Solution:** The hooks auto-fix most issues. Re-stage and commit:

```bash
git add .
git commit -m "Fix formatting"
```

### Docker Build Fails

**Issue:** `Error response from daemon: toomanyrequests`

**Solution:** Docker Hub rate limiting. Wait a few minutes and retry.

**Issue:** `qemu-xxx-static: not found`

**Solution:** Multi-platform builds need QEMU. Rebuild without multi-arch:

```bash
docker build -t test:local .
```

### Test Script Fails

**Issue:** `Caddy binary not found`

**Solution:** Verify the Dockerfile builds correctly:

```bash
docker build -t caddy-cloudflaredns:test .
docker run --rm caddy-cloudflaredns:test ls -la /usr/bin/caddy
```

## Code Review

Pull requests are reviewed for:

- Correctness and best practices
- Security considerations
- Completeness of documentation
- Test coverage
- Alignment with project goals

## Adding a New Project

To add a new project to the monorepo:

1. Create project directory: `mkdir new-project && mkdir new-project/test`
2. Copy Makefile template: `cp caddy-cloudflaredns/Makefile new-project/`
3. Create project files:
   - `new-project/Dockerfile`
   - `new-project/test/test-image.sh`
   - `new-project/README.md`
4. Create `.github/workflows/new-project.yml` with path filtering
5. Update `.github/dependabot.yml` with the new project directory
6. Add delegating targets to root `Makefile`
7. Add project row to root `README.md` project table

## Questions?

- Check existing [GitHub Issues](https://github.com/clintonsteiner/docker-monorepo/issues)
- Create a new issue for bugs or feature requests
- Discussions welcome in pull requests

Thank you for contributing!
