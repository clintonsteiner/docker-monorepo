.PHONY: help build test run run-70b run-13b run-7b stop logs clean push

IMAGE_NAME = llm-bot
REGISTRY ?= ghcr.io
DOCKER_USERNAME ?= clintonsteiner

# Default model (70B)
MODEL_NAME ?= meta-llama/Llama-2-70b-hf
CONTAINER_NAME = llm-bot-server

help:
	@echo "llm-bot - vLLM-powered LLM server for Claude CLI"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build          Build the Docker image"
	@echo "  test           Run tests"
	@echo "  run            Run container with default model (70B Llama-2)"
	@echo "  run-70b        Run with 70B Llama-2 (default, requires ~40-50GB RAM)"
	@echo "  run-13b        Run with 13B Llama-2 (requires ~10-16GB RAM)"
	@echo "  run-7b         Run with 7B Llama-2 (requires ~5-8GB RAM)"
	@echo "  stop           Stop running container"
	@echo "  logs           View container logs"
	@echo "  clean          Remove image and stop container"
	@echo ""
	@echo "Environment variables:"
	@echo "  MODEL_NAME     HuggingFace model ID (default: meta-llama/Llama-2-70b-hf)"
	@echo "  PORT           API port (default: 8000)"
	@echo "  DEVICE         Device type: cpu or cuda (default: cpu)"
	@echo ""
	@echo "Examples:"
	@echo "  make run                    # Run with 70B model"
	@echo "  make run-7b                 # Run with 7B model"
	@echo "  MODEL_NAME=meta-llama/Llama-2-13b-hf make run"
	@echo ""

build:
	docker build -t $(IMAGE_NAME):latest .

test:
	chmod +x test/test-image.sh
	./test/test-image.sh

run: build
	@echo "Starting vLLM server with $(MODEL_NAME)..."
	@echo "API will be available at http://localhost:8000"
	@echo "Use Ctrl+C to stop"
	@echo ""
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p 8000:8000 \
		-e MODEL_NAME="$(MODEL_NAME)" \
		-e DEVICE=cpu \
		--memory 50g \
		$(IMAGE_NAME):latest

run-70b:
	$(MAKE) run MODEL_NAME="meta-llama/Llama-2-70b-hf"

run-13b:
	$(MAKE) run MODEL_NAME="meta-llama/Llama-2-13b-hf"

run-7b:
	$(MAKE) run MODEL_NAME="meta-llama/Llama-2-7b-hf"

stop:
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@echo "Container stopped"

logs:
	docker logs -f $(CONTAINER_NAME)

clean: stop
	docker rmi $(IMAGE_NAME):latest 2>/dev/null || true
	@echo "Cleaned up"

push:
	docker tag $(IMAGE_NAME):latest $(REGISTRY)/$(DOCKER_USERNAME)/$(IMAGE_NAME):latest
	docker push $(REGISTRY)/$(DOCKER_USERNAME)/$(IMAGE_NAME):latest
	docker tag $(IMAGE_NAME):latest $(DOCKER_USERNAME)/$(IMAGE_NAME):latest
	docker push $(DOCKER_USERNAME)/$(IMAGE_NAME):latest

.DEFAULT_GOAL := help
