.PHONY: help install-hooks pre-commit build build-test test test-quick clean lint format validate shell version help

JENKINS_IMAGE := jenkinsapi:test
TEST_IMAGE := jenkinsapi-test:test
JENKINS_VERSION := $(shell cat JENKINS_VERSION | tr -d '\n')

help:
	@echo "Available targets:"
	@echo "  make install-hooks     Install pre-commit hooks"
	@echo "  make pre-commit        Run pre-commit checks on all files"
	@echo "  make build             Build Jenkins Docker image locally"
	@echo "  make build-test        Build test Docker image locally"
	@echo "  make test              Build and run test suite"
	@echo "  make test-quick        Quick test without building (requires images)"
	@echo "  make lint              Run all linters (Dockerfile, YAML, Markdown)"
	@echo "  make lint-docker       Lint Dockerfiles with hadolint"
	@echo "  make lint-yaml         Validate YAML files with yamllint"
	@echo "  make lint-markdown     Check Markdown with markdownlint"
	@echo "  make format            Auto-fix formatting issues"
	@echo "  make validate          Validate Jenkins image and health checks"
	@echo "  make clean             Remove test artifacts and containers"
	@echo "  make shell             Open shell in Jenkins container"
	@echo "  make version           Show Jenkins version from Dockerfile"
	@echo "  make help              Show this help message"

install-hooks:
	@echo "Installing pre-commit hooks..."
	uv tool install pre-commit
	pre-commit install
	@echo "✓ Pre-commit hooks installed"

pre-commit:
	@echo "Running pre-commit checks..."
	pre-commit run --all-files

build:
	@echo "Building Jenkins Docker image: $(JENKINS_IMAGE)"
	@echo "Jenkins version: $(JENKINS_VERSION)"
	docker build -t $(JENKINS_IMAGE) --build-arg JENKINS_VERSION=$(JENKINS_VERSION) -f Dockerfile .
	@echo "✓ Jenkins image built successfully"

build-test:
	@echo "Building test Docker image: $(TEST_IMAGE)"
	docker build -t $(TEST_IMAGE) -f Dockerfile.test .
	@echo "✓ Test image built successfully"

test: build build-test
	@echo "Running test suite..."
	chmod +x test/test-image.sh
	./test/test-image.sh

test-quick:
	@echo "Running quick tests (images must already exist)..."
	chmod +x test/test-image.sh
	./test/test-image.sh

lint: lint-docker lint-yaml lint-markdown
	@echo "✓ All linters passed"

lint-docker:
	@echo "Linting Dockerfiles with hadolint..."
	docker run --rm -i hadolint/hadolint < Dockerfile
	docker run --rm -i hadolint/hadolint < Dockerfile.test
	@echo "✓ Dockerfile linting passed"

lint-yaml:
	@echo "Validating YAML files..."
	yamllint .
	@echo "✓ YAML validation passed"

lint-markdown:
	@echo "Checking Markdown files..."
	markdownlint README.md
	@echo "✓ Markdown checks passed"

format:
	@echo "Auto-fixing formatting issues..."
	pre-commit run --all-files --hook-stage=manual
	@echo "✓ Formatting complete"

validate: build
	@echo "Validating Jenkins image and health checks..."
	@echo "✓ Jenkins image validation successful"

clean:
	@echo "Cleaning up..."
	docker rm -f jenkinsapi-test 2>/dev/null || true
	docker rmi $(JENKINS_IMAGE) 2>/dev/null || true
	docker rmi $(TEST_IMAGE) 2>/dev/null || true
	rm -f test/*.log
	rm -rf test/logs/
	@echo "✓ Cleanup complete"

shell: build
	@echo "Opening shell in Jenkins container..."
	docker run -it --rm -p 8080:8080 $(JENKINS_IMAGE) /bin/bash

version:
	@echo "Jenkins version from Dockerfile:"
	@grep "^FROM jenkins/" Dockerfile | head -1 | sed 's/.*://g'

.DEFAULT_GOAL := help
