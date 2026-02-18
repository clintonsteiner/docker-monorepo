.PHONY: help install-hooks pre-commit build test clean lint format validate-docker validate-yaml validate-markdown

DOCKER_IMAGE := caddy-cloudflaredns:test
DOCKER_REGISTRY_HUB := docker.io/clintonsteiner/caddy-cloudflaredns
DOCKER_REGISTRY_GHCR := ghcr.io/clintonsteiner/caddy-cloudflaredns
DOCKER_REGISTRY_QUAY := quay.io/clintonsteiner/caddy-cloudflaredns

help:
	@echo "Available targets:"
	@echo "  make install-hooks     Install pre-commit hooks"
	@echo "  make pre-commit        Run pre-commit checks on all files"
	@echo "  make build             Build Docker image locally"
	@echo "  make test              Run test suite"
	@echo "  make test-quick        Quick test without building (requires image)"
	@echo "  make lint              Run all linters (Dockerfile, YAML, Markdown)"
	@echo "  make lint-docker       Lint Dockerfile with hadolint"
	@echo "  make lint-yaml         Validate YAML files with yamllint"
	@echo "  make lint-markdown     Check Markdown with markdownlint"
	@echo "  make format            Auto-fix formatting issues"
	@echo "  make validate          Validate Caddyfile syntax"
	@echo "  make clean             Remove test artifacts and containers"
	@echo "  make shell             Open shell in test container"
	@echo "  make version           Extract and display Caddy version from Dockerfile"
	@echo "  make help              Show this help message"

install-hooks:
	@echo "Installing pre-commit hooks..."
	pip install pre-commit
	pre-commit install
	@echo "✓ Pre-commit hooks installed"

pre-commit:
	@echo "Running pre-commit checks..."
	pre-commit run --all-files

build:
	@echo "Building Docker image: $(DOCKER_IMAGE)"
	docker build -t $(DOCKER_IMAGE) .
	@echo "✓ Image built successfully"

test: build
	@echo "Running test suite..."
	chmod +x test/test-image.sh
	./test/test-image.sh

test-quick:
	@echo "Running quick tests (image must already exist)..."
	chmod +x test/test-image.sh
	./test/test-image.sh

lint: lint-docker lint-yaml lint-markdown
	@echo "✓ All linters passed"

lint-docker:
	@echo "Linting Dockerfile with hadolint..."
	docker run --rm -i hadolint/hadolint < Dockerfile
	@echo "✓ Dockerfile linting passed"

lint-yaml:
	@echo "Validating YAML files..."
	yamllint .
	@echo "✓ YAML validation passed"

lint-markdown:
	@echo "Checking Markdown files..."
	markdownlint README.md CONTRIBUTING.md
	@echo "✓ Markdown checks passed"

format:
	@echo "Auto-fixing formatting issues..."
	pre-commit run --all-files --hook-stage=manual
	@echo "✓ Formatting complete"

validate: build
	@echo "Validating Caddy configuration..."
	docker run --rm -e ACME_AGREE=true $(DOCKER_IMAGE) \
		/usr/bin/caddy validate --config /dev/stdin <<< "localhost:2015\nrespond \"OK\""
	@echo "✓ Configuration validation successful"

clean:
	@echo "Cleaning up..."
	docker rm -f caddy-cloudflaredns-test 2>/dev/null || true
	docker rmi $(DOCKER_IMAGE) 2>/dev/null || true
	rm -f test/*.log
	rm -rf test/logs/
	@echo "✓ Cleanup complete"

shell: build
	@echo "Opening shell in container..."
	docker run -it --rm $(DOCKER_IMAGE) /bin/sh

version:
	@echo "Caddy version from Dockerfile:"
	@grep "^FROM caddy:" Dockerfile | head -1 | sed 's/.*:\([^-]*\).*/\1/'

.DEFAULT_GOAL := help
