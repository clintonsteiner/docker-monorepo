.PHONY: help build push start stop restart logs status download-model pull-model test clean

VERSION ?= $(shell cat VERSION)
CONTAINER_NAME ?= coding-agent
IMAGE_NAME ?= clintonsteiner/coding-agent
GHCR_IMAGE_NAME ?= ghcr.io/clintonsteiner/coding-agent

help:
	@echo "Coding Agent - Self-hosted Claude Code alternative"
	@echo ""
	@echo "Available targets:"
	@echo "  build          - Build the Docker image"
	@echo "  push           - Push image to registries (Docker Hub + GHCR)"
	@echo "  start          - Start the coding agent"
	@echo "  stop           - Stop the coding agent"
	@echo "  restart        - Restart the coding agent"
	@echo "  logs           - View container logs"
	@echo "  status         - Check service status"
	@echo "  download-model - Download model manually (optional)"
	@echo "  pull-model     - Pull model via Ollama (inside container)"
	@echo "  test           - Run health checks"
	@echo "  clean          - Remove containers and volumes"
	@echo ""
	@echo "Docker Image:"
	@echo "  Version: $(VERSION)"
	@echo "  Docker Hub: $(IMAGE_NAME):$(VERSION)"
	@echo "  GHCR: $(GHCR_IMAGE_NAME):$(VERSION)"
	@echo ""
	@echo "Access the UI at: http://unraid.clintonsteiner.com:3000"

build:
	@echo "Building coding-agent Docker image..."
	@echo "Version: $(VERSION)"
	docker build -t $(IMAGE_NAME):$(VERSION) \
		-t $(IMAGE_NAME):latest \
		-t $(GHCR_IMAGE_NAME):$(VERSION) \
		-t $(GHCR_IMAGE_NAME):latest \
		.
	@echo "✓ Image built successfully"

push: build
	@echo "Pushing to Docker Hub..."
	docker push $(IMAGE_NAME):$(VERSION)
	docker push $(IMAGE_NAME):latest
	@echo ""
	@echo "Pushing to GitHub Container Registry..."
	docker push $(GHCR_IMAGE_NAME):$(VERSION)
	docker push $(GHCR_IMAGE_NAME):latest
	@echo ""
	@echo "✓ Images pushed successfully!"
	@echo "  Docker Hub: $(IMAGE_NAME):$(VERSION)"
	@echo "  GHCR: $(GHCR_IMAGE_NAME):$(VERSION)"

start:
	@echo "Starting coding agent..."
	docker compose up -d
	@echo ""
	@echo "✓ Service started!"
	@echo "  Web UI: http://unraid.clintonsteiner.com:3000"
	@echo "  API: http://unraid.clintonsteiner.com:3000/api"
	@echo ""
	@echo "First-time setup:"
	@echo "  1. Open the Web UI"
	@echo "  2. Go to Settings → Models"
	@echo "  3. Pull model: qwen2.5-coder:32b-instruct-q5_K_M"
	@echo "  4. Wait for download (~20GB)"
	@echo "  5. Select the model and start chatting!"

stop:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

status:
	@echo "Service status:"
	@docker compose ps
	@echo ""
	@curl -s http://localhost:3000/health || echo "Service not responding"

download-model:
	@echo "Downloading Qwen2.5-Coder-32B-Instruct (Q5_K_M, ~20GB)..."
	@echo "This may take a while..."
	@scripts/download-model.sh

pull-model:
	@echo "Pulling model via Ollama..."
	docker exec $(CONTAINER_NAME) ollama pull qwen2.5-coder:32b-instruct-q5_K_M

test:
	@echo "Running health checks..."
	@test/test-image.sh

clean:
	@echo "Warning: This will remove all data including conversations and models!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
		echo "✓ Cleaned up"; \
	fi
