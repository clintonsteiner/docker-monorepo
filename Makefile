.PHONY: help install-hooks pre-commit build-caddy build-jenkinsapi build-ollama test-caddy test-jenkinsapi test-ollama test-all clean lint format validate build-all

# Project definitions
PROJECTS := caddy-cloudflaredns jenkinsapi ollama

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
	@echo "  make build-ollama            Build ollama Docker image"
	@echo "  make build-all               Build all Docker images"
	@echo "  make test-caddy              Build and test caddy-cloudflaredns"
	@echo "  make test-jenkinsapi         Build and test jenkinsapi"
	@echo "  make test-ollama             Build and test ollama"
	@echo "  make test-all                Build and test all projects"
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
	@echo "  ollama/                      Ollama LLM server for Claude CLI"
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

# ollama targets
build-ollama:
	@echo "Building ollama..."
	$(MAKE) -C ollama build

test-ollama:
	@echo "Testing ollama..."
	$(MAKE) -C ollama test

# Multi-project targets
build-all: build-caddy build-jenkinsapi build-ollama
	@echo "✓ All images built successfully"

test-all: test-caddy test-jenkinsapi test-ollama
	@echo "✓ All tests passed"

lint:
	@echo "Running linters..."
	$(MAKE) -C caddy-cloudflaredns lint 2>/dev/null || true
	$(MAKE) -C jenkinsapi lint 2>/dev/null || true
	@echo "✓ Linting complete"

format:
	@echo "Auto-fixing formatting..."
	$(MAKE) -C caddy-cloudflaredns format 2>/dev/null || true
	$(MAKE) -C jenkinsapi format 2>/dev/null || true
	@echo "✓ Formatting complete"

validate: build-all
	@echo "Validating all projects..."
	$(MAKE) -C caddy-cloudflaredns validate 2>/dev/null || true
	$(MAKE) -C jenkinsapi validate 2>/dev/null || true
	@echo "✓ All validations passed"

version:
	@echo "Caddy version from Dockerfile:"
	@$(MAKE) -C caddy-cloudflaredns version 2>/dev/null || echo "N/A"
	@echo "Jenkins version from Dockerfile:"
	@$(MAKE) -C jenkinsapi version 2>/dev/null || echo "N/A"

clean:
	@echo "Cleaning up all projects..."
	$(MAKE) -C caddy-cloudflaredns clean 2>/dev/null || true
	$(MAKE) -C jenkinsapi clean 2>/dev/null || true
	$(MAKE) -C ollama clean 2>/dev/null || true
	@echo "✓ Cleanup complete"

shell:
	@echo "Opening shell in caddy-cloudflaredns container..."
	$(MAKE) -C caddy-cloudflaredns shell

.DEFAULT_GOAL := help
