.PHONY: help install-hooks pre-commit build-caddy build-jenkinsapi test-caddy test-jenkinsapi test-all clean lint format validate build-all

# Project definitions
PROJECTS := caddy-cloudflaredns jenkinsapi

help:
	@echo "Docker Monorepo - Available targets:"
	@echo ""
	@echo "Installation:"
	@echo "  make install-hooks           Install pre-commit hooks"
	@echo "  make pre-commit              Run pre-commit checks on all files"
	@echo ""
	@echo "Build & Test:"
	@echo "  make build-caddy             Build caddy-cloudflaredns Docker image"
	@echo "  make build-jenkinsapi        Build jenkinsapi Docker images"
	@echo "  make build-all               Build all Docker images"
	@echo "  make test-caddy              Build and test caddy-cloudflaredns"
	@echo "  make test-jenkinsapi         Build and test jenkinsapi"
	@echo "  make test-all                Build and test all projects"
	@echo "  make test-quick-caddy        Quick test caddy-cloudflaredns (requires image)"
	@echo "  make test-quick-jenkinsapi   Quick test jenkinsapi (requires images)"
	@echo ""
	@echo "Development:"
	@echo "  make lint                    Run all linters"
	@echo "  make format                  Auto-fix formatting issues"
	@echo "  make validate                Validate all projects"
	@echo "  make version                 Show Caddy version from Dockerfile"
	@echo "  make clean                   Remove test artifacts"
	@echo ""
	@echo "Project Structure:"
	@echo "  caddy-cloudflaredns/         Caddy with Cloudflare DNS module"
	@echo "  jenkinsapi/                  Jenkins with Python test environment"
	@echo ""
	@echo "Usage:"
	@echo "  make help                    Show this help message"

install-hooks:
	@echo "Installing pre-commit hooks..."
	pip install pre-commit
	pre-commit install
	@echo "✓ Pre-commit hooks installed"

pre-commit:
	@echo "Running pre-commit checks..."
	pre-commit run --all-files

# Caddy-cloudflaredns targets
build-caddy:
	@echo "Building caddy-cloudflaredns..."
	$(MAKE) -C caddy-cloudflaredns build

test-caddy:
	@echo "Testing caddy-cloudflaredns..."
	$(MAKE) -C caddy-cloudflaredns test

test-quick-caddy:
	@echo "Quick testing caddy-cloudflaredns..."
	$(MAKE) -C caddy-cloudflaredns test-quick

# Jenkinsapi targets
build-jenkinsapi:
	@echo "Building jenkinsapi..."
	$(MAKE) -C jenkinsapi build build-test

test-jenkinsapi:
	@echo "Testing jenkinsapi..."
	$(MAKE) -C jenkinsapi test

test-quick-jenkinsapi:
	@echo "Quick testing jenkinsapi..."
	$(MAKE) -C jenkinsapi test-quick

# Multi-project targets
build-all: build-caddy build-jenkinsapi
	@echo "✓ All images built successfully"

test-all: test-caddy test-jenkinsapi
	@echo "✓ All tests passed"

lint:
	@echo "Running linters..."
	$(MAKE) -C caddy-cloudflaredns lint
	$(MAKE) -C jenkinsapi lint
	@echo "✓ All linters passed"

format:
	@echo "Auto-fixing formatting..."
	$(MAKE) -C caddy-cloudflaredns format
	$(MAKE) -C jenkinsapi format
	@echo "✓ Formatting complete"

validate: build-all
	@echo "Validating all projects..."
	$(MAKE) -C caddy-cloudflaredns validate
	$(MAKE) -C jenkinsapi validate
	@echo "✓ All validations passed"

version:
	@echo "Caddy version from Dockerfile:"
	@$(MAKE) -C caddy-cloudflaredns version
	@echo "Jenkins version from Dockerfile:"
	@$(MAKE) -C jenkinsapi version

clean:
	@echo "Cleaning up all projects..."
	$(MAKE) -C caddy-cloudflaredns clean
	$(MAKE) -C jenkinsapi clean
	@echo "✓ Cleanup complete"

shell:
	@echo "Opening shell in caddy-cloudflaredns container..."
	$(MAKE) -C caddy-cloudflaredns shell

.DEFAULT_GOAL := help
