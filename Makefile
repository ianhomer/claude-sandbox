.PHONY: build run clean help setup

IMAGE_NAME := claude-sandbox
CONTAINER_NAME := claude-sandbox-container

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the Docker image
	docker build -t $(IMAGE_NAME) .

run: ## Run the container with current directory mounted
	docker run -it \
		-v $$(pwd):/workspace/$${PWD##*/} \
		-v ~/.claude-sandbox/.claude:/home/appuser/.claude \
		-v ~/.claude-sandbox/.claude.json:/home/appuser/.claude.json \
		--network="host" \
		-w /workspace/$${PWD##*/} \
		$(IMAGE_NAME)

run-published: ## Run the container with current directory mounted
	docker run -it \
		-v $$(pwd):/workspace/$${PWD##*/} \
		-v ~/.claude-sandbox/.claude:/home/appuser/.claude \
		-v ~/.claude-sandbox/.claude.json:/home/appuser/.claude.json \
		--network="host" \
		-w /workspace/$${PWD##*/} \
		ghcr.io/adaptivekind/claude-sandbox:latest

run-debian: ## Run the a debian container
	docker run -it debian:bookworm-slim

list-apt-versions: ## Run the a debian container
	docker run debian:bookworm-slim \
		sh -c "apt-get update ; apt list -a nodejs zsh npm zsh"

setup: ## Set up the local .claude directory and config
	mkdir -p ~/.claude-sandbox/.claude
	cp .claude.json ~/.claude-sandbox/.claude.json

clean: ## Remove the Docker image
	docker rmi $(IMAGE_NAME) || true

clean-all: ## Remove image and clean up local directories
	docker rmi $(IMAGE_NAME) || true
	rm -r ~/.claude-sandbox
