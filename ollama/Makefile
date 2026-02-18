.PHONY: help build test run run-70b run-13b run-7b stop logs clean push

IMAGE_NAME = ollama
VERSION ?= $(shell cat VERSION)
REGISTRY ?= ghcr.io
DOCKER_USERNAME ?= clintonsteiner
CONTAINER_NAME = ollama-server

help:
	@echo "ollama - Ollama LLM server for Claude CLI"
	@echo ""
	@echo "Targets:"
	@echo "  build          Build Docker image"
	@echo "  test           Run tests"
	@echo "  run            Run Ollama (default: 70B model)"
	@echo "  run-70b        Run with 70B Llama-2"
	@echo "  run-13b        Run with 13B Llama-2"
	@echo "  run-7b         Run with 7B Llama-2"
	@echo "  stop           Stop container"
	@echo "  logs           View logs"
	@echo "  clean          Remove image and container"
	@echo "  push           Push to registries"
	@echo ""

build:
	docker build -t $(IMAGE_NAME):latest -t $(IMAGE_NAME):$(VERSION) .

test:
	chmod +x test/test-image.sh
	./test/test-image.sh

run: build
	@echo "Starting Ollama with llama2-70b..."
	docker run -d --name $(CONTAINER_NAME) -p 11434:11434 \
		-e MODEL_NAME="llama2-70b" --memory 50g $(IMAGE_NAME):latest

run-70b: build
	docker run -d --name $(CONTAINER_NAME) -p 11434:11434 \
		-e MODEL_NAME="llama2-70b" --memory 50g $(IMAGE_NAME):latest

run-13b: build
	docker run -d --name $(CONTAINER_NAME) -p 11434:11434 \
		-e MODEL_NAME="llama2-13b" --memory 20g $(IMAGE_NAME):latest

run-7b: build
	docker run -d --name $(CONTAINER_NAME) -p 11434:11434 \
		-e MODEL_NAME="llama2-7b" --memory 10g $(IMAGE_NAME):latest

stop:
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true

logs:
	docker logs -f $(CONTAINER_NAME)

clean: stop
	docker rmi $(IMAGE_NAME):latest 2>/dev/null || true

push:
	docker tag $(IMAGE_NAME):latest $(REGISTRY)/$(DOCKER_USERNAME)/$(IMAGE_NAME):latest
	docker tag $(IMAGE_NAME):$(VERSION) $(REGISTRY)/$(DOCKER_USERNAME)/$(IMAGE_NAME):$(VERSION)
	docker push $(REGISTRY)/$(DOCKER_USERNAME)/$(IMAGE_NAME):latest
	docker push $(REGISTRY)/$(DOCKER_USERNAME)/$(IMAGE_NAME):$(VERSION)
	docker tag $(IMAGE_NAME):latest $(DOCKER_USERNAME)/$(IMAGE_NAME):latest
	docker tag $(IMAGE_NAME):$(VERSION) $(DOCKER_USERNAME)/$(IMAGE_NAME):$(VERSION)
	docker push $(DOCKER_USERNAME)/$(IMAGE_NAME):latest
	docker push $(DOCKER_USERNAME)/$(IMAGE_NAME):$(VERSION)

.DEFAULT_GOAL := help
