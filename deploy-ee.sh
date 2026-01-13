#!/bin/bash
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
EE_NAME="ee-onbase-deployment-automation-rhel9"
EE_VERSION="latest"

# Functions
print_step() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

check_prereqs() {
    print_step "Checking prerequisites..."
    
    # Check for docker or podman
    if command -v docker &> /dev/null; then
        CONTAINER_CMD="docker"
    elif command -v podman &> /dev/null; then
        CONTAINER_CMD="podman"
    else
        print_error "Neither docker nor podman found. Please install one."
        exit 1
    fi
    echo "Container runtime: $CONTAINER_CMD"
    
    # Check for python3
    if ! command -v python3 &> /dev/null; then
        print_error "python3 not found. Please install Python 3."
        exit 1
    fi
    echo "Python version: $(python3 --version)"
}

setup_venv() {
    print_step "Setting up Python virtual environment..."
    
    if [ ! -d "venv" ]; then
        python3 -m venv --upgrade-deps venv
    fi
    
    source venv/bin/activate
    
    print_step "Installing ansible-builder..."
    pip install ansible-builder
    
    echo "Ansible-builder version: $(ansible-builder --version)"
}

login_registries() {
    print_step "Authenticating to Red Hat registry..."
    
    echo "Please enter your Red Hat credentials:"
    $CONTAINER_CMD login registry.redhat.io
}

get_galaxy_token() {
    print_step "Setting up Ansible Galaxy token..."
    
    if [ -z "$ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN" ]; then
        print_warning "ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN not set"
        echo "Please get your token from: https://console.redhat.com/ansible/automation-hub/token"
        echo "Enter your token (input will be hidden):"
        read -rs ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN
        export ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN
    else
        echo "Token already set in environment"
    fi
}

build_image() {
    print_step "Building execution environment image..."
    
    ansible-builder build \
        --build-arg ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN \
        --tag "$EE_NAME:$EE_VERSION" \
        --verbosity 3
    
    print_step "Build completed successfully!"
}

verify_image() {
    print_step "Verifying built image..."
    
    echo "Checking ansible version:"
    $CONTAINER_CMD run --rm "$EE_NAME:$EE_VERSION" ansible --version
    
    echo -e "\nChecking AWS CLI:"
    $CONTAINER_CMD run --rm "$EE_NAME:$EE_VERSION" aws --version
    
    echo -e "\nChecking kubectl:"
    $CONTAINER_CMD run --rm "$EE_NAME:$EE_VERSION" kubectl version --client
    
    echo -e "\nChecking terraform:"
    $CONTAINER_CMD run --rm "$EE_NAME:$EE_VERSION" terraform version
    
    echo -e "\nImage details:"
    $CONTAINER_CMD images | grep "$EE_NAME"
}

save_image() {
    print_step "Saving image to tar archive..."
    
    ARCHIVE_NAME="$EE_NAME-$EE_VERSION.tar"
    
    $CONTAINER_CMD image save -o "$ARCHIVE_NAME" "$EE_NAME:$EE_VERSION"
    
    print_step "Compressing archive..."
    gzip -9 -f "$ARCHIVE_NAME"
    
    echo "Archive created: ${ARCHIVE_NAME}.gz"
    echo "Size: $(ls -lh ${ARCHIVE_NAME}.gz | awk '{print $5}')"
}

# Main execution
main() {
    echo "========================================"
    echo "Ansible Execution Environment Builder"
    echo "========================================"
    echo ""
    
    # Check prerequisites
    check_prereqs
    
    # Setup virtual environment
    setup_venv
    
    # Login to registries
    login_registries
    
    # Get Galaxy token
    get_galaxy_token
    
    # Build the image
    build_image
    
    # Verify the build
    verify_image
    
    # Save the image
    save_image
    
    echo ""
    print_step "Deployment preparation completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Upload ${EE_NAME}-${EE_VERSION}.tar.gz to your target environment"
    echo "2. Load and push to private automation hub"
    echo "3. Configure in Ansible Automation Platform"
    echo ""
    echo "For detailed instructions, see the deployment guide."
}

# Run main function
main