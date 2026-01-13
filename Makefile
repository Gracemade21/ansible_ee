# Execution Environment Build Configuration
name = ee-onbase-deployment-automation-rhel9
version = latest

# Default target
all: build

# Build the execution environment
build:
	@echo "Building execution environment: $(name):$(version)"
	@if [ -z "$$ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN" ]; then \
		echo "ERROR: ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN is not set"; \
		echo "Please run: export ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN=<your_token>"; \
		exit 1; \
	fi
	ansible-builder build --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN -t $(name):$(version)
	@echo "Build completed successfully!"

# Build with verbose output for debugging
build-verbose:
	@echo "Building with verbose output..."
	@if [ -z "$$ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN" ]; then \
		echo "ERROR: ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN is not set"; \
		exit 1; \
	fi
	ansible-builder build --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN -t $(name):$(version) --verbosity 3

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf context
	@echo "Clean completed!"

# Save the container image to tar.gz
save:
	@echo "Saving image: $(name):$(version)"
	docker image save -o $(name)-$(version).tar $(name):$(version)
	@echo "Compressing image..."
	gzip -9 $(name)-$(version).tar
	@echo "Image saved to: $(name)-$(version).tar.gz"
	@ls -lh $(name)-$(version).tar.gz

# Verify the built image
verify:
	@echo "Verifying execution environment..."
	@echo "\n=== Ansible Version ==="
	docker run --rm $(name):$(version) ansible --version
	@echo "\n=== Installed Collections ==="
	docker run --rm $(name):$(version) ansible-galaxy collection list
	@echo "\n=== AWS CLI ==="
	docker run --rm $(name):$(version) aws --version
	@echo "\n=== kubectl ==="
	docker run --rm $(name):$(version) kubectl version --client
	@echo "\n=== Terraform ==="
	docker run --rm $(name):$(version) terraform version
	@echo "\n=== Python Packages ==="
	docker run --rm $(name):$(version) pip list | grep -E "kubernetes|boto3|jmespath|PyYAML"
	@echo "\n=== Image Info ==="
	docker images | grep $(name)

# Test Python imports
test-python:
	@echo "Testing Python imports..."
	docker run --rm $(name):$(version) python3 -c "import kubernetes; import boto3; import jmespath; import yaml; print('All Python imports successful!')"

# Interactive shell in the container
shell:
	@echo "Starting interactive shell in $(name):$(version)"
	docker run -it --rm $(name):$(version) /bin/bash

# Create context without building (for inspection)
create-context:
	@echo "Creating build context..."
	ansible-builder create
	@echo "Context created in ./context directory"
	@echo "Review Containerfile: cat context/Containerfile"

# Full build, verify, and save
full: build verify save

# Remove old images and clean build
rebuild: clean
	@echo "Removing old image..."
	-docker rmi $(name):$(version) 2>/dev/null || true
	@$(MAKE) build

# Show help
help:
	@echo "Available targets:"
	@echo "  make build          - Build the execution environment (default)"
	@echo "  make build-verbose  - Build with verbose output for debugging"
	@echo "  make clean          - Remove build artifacts"
	@echo "  make save           - Save image to tar.gz file"
	@echo "  make verify         - Verify the built image"
	@echo "  make test-python    - Test Python imports"
	@echo "  make shell          - Start interactive shell in container"
	@echo "  make create-context - Create build context without building"
	@echo "  make full           - Build, verify, and save"
	@echo "  make rebuild        - Clean and rebuild from scratch"
	@echo "  make help           - Show this help message"
	@echo ""
	@echo "Environment variables required:"
	@echo "  ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN - Token for Ansible Automation Hub"

.PHONY: all build build-verbose clean save verify test-python shell create-context full rebuild help