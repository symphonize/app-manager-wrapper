#!/usr/bin/env bash
set -euo pipefail

# Metadata
# Version: 2025.03.220959+0e275c5

# Configuration
WRAPPER_URL="https://raw.githubusercontent.com/symphonize/app-manager-wrapper/main/managerw.sh"
DEFAULT_MANAGER_URL="https://raw.githubusercontent.com/symphonize/app-manager-wrapper/main/manager.sh"
MANAGERW_PATH="./managerw"
ENV_FILE="./.env_url"

# Colors for output
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

# Function to print success messages
success() {
  echo -e "${GREEN}$1${RESET}"
}

# Function to print error messages and exit
error() {
  echo -e "${RED}Error:${RESET} $1"
  exit 1
}

# Create or update the .env file
create_env_file() {
  local manager_url=$1

  cat > "$ENV_FILE" <<EOF
# Microservice Manager Configuration
MANAGER_URL=$manager_url
EOF
  success "Configuration saved to $ENV_FILE"
}

# Download and install the wrapper script
install_wrapper() {
  if [ -f "$MANAGERW_PATH" ]; then
    echo "managerw already exists at $MANAGERW_PATH."
    read -p "Do you want to overwrite it? (y/N): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
      success "Installation aborted."
      exit 0
    fi
  fi

  if ! command -v curl &>/dev/null; then
    error "curl is not installed. Please install curl and try again."
  fi

  echo "Downloading wrapper script from $WRAPPER_URL..."
  curl -sSL -o "$MANAGERW_PATH" "$WRAPPER_URL" || error "Failed to download managerw from $WRAPPER_URL."
  chmod +x "$MANAGERW_PATH"
  success "Wrapper script installed successfully to $MANAGERW_PATH."
}

# Test the Wrapper script to ensure it works
validate_wrapper() {
  if ! bash "$MANAGERW_PATH" --help &>/dev/null; then
    error "The downloaded managerw script is not valid or executable. Please check the URL or script."
  fi
  success "Wrapper script is valid and ready to use."
}

# Main function
main() {
  local manager_url="${MANAGER_URL:-$DEFAULT_MANAGER_URL}"

  case "${1:-}" in
    install)
      create_env_file "$manager_url"
      install_wrapper
      validate_wrapper
      ;;
    version)
      local version
      version=$(grep -E '^# Version:' "$0" | awk '{print $3}')
      echo "Bootstrap script version: $version"
      ;;
    *)
      echo "Usage: $0 install|version"
      echo ""
      echo "Commands:"
      echo "  install    Download and install the wrapper script."
      echo "  version    Display the bootstrap script version."
      exit 1
      ;;
  esac
}

main "$@"
