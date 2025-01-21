#!/usr/bin/env bash
set -euo pipefail

# Metadata
# Version: 2025.03.220956+0e275c5

# Configuration
WRAPPER_URL="https://raw.githubusercontent.com/symphonize/app-manager-wrapper/main/managerw.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
CACHE_DIR="${HOME}/.app-manager-wrapper/cache"
CACHE_TTL=$((60 * 60))  # 1 hour in seconds

# Dynamically set the cache file name based on MANAGER_URL
if [[ -f "$ENV_FILE" ]]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  echo "Configuration file $ENV_FILE not found. Please create it using the bootstrap-manager.sh script."
  exit 1
fi

CACHE_FILE="${CACHE_DIR}/$(basename "$MANAGER_URL")"

# Colors for output
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# Print messages
success() { echo -e "${GREEN}$1${RESET}"; }
warning() { echo -e "${YELLOW}Warning:${RESET} $1"; }
error() { echo -e "${RED}Error:${RESET} $1"; exit 1; }

# Ensure cache directory exists
ensure_cache_dir() { mkdir -p "$CACHE_DIR"; }

# Check if the cache file is valid
is_cache_valid() {
  if [[ -f "$CACHE_FILE" ]]; then
    local cache_mtime now
    if [[ "$(uname)" == "Darwin" ]]; then
      cache_mtime=$(stat -f %m "$CACHE_FILE")
    else
      cache_mtime=$(stat -c %Y "$CACHE_FILE")
    fi
    now=$(date +%s)
    (( (now - cache_mtime) < CACHE_TTL ))
  else
    return 1
  fi
}

# Extract version from a source
extract_version() {
  local source=$1
  if [[ "$source" == "local" ]]; then
    grep -E "^# Version:" "$0" | awk '{print $3}'
  elif [[ "$source" == "remote" ]]; then
    curl -sSL "$WRAPPER_URL" | grep -E "^# Version:" | awk '{print $3}'
  else
    echo "unknown"
  fi
}

# Fetch the latest manager script
fetch_manager() {
  echo "Fetching the latest manager script from $MANAGER_URL..."
  curl -sSL -o "$CACHE_FILE" "$MANAGER_URL" || error "Failed to download manager script from $MANAGER_URL."
  chmod +x "$CACHE_FILE"
  success "Fetched and cached the latest manager script."
}

# Check for updates to managerw
check_self_update() {
  local local_version remote_version
  local_version=$(extract_version local)
  remote_version=$(extract_version remote || echo "unknown")

  if [[ "$remote_version" != "$local_version" && "$remote_version" != "unknown" ]]; then
    warning "A new version of managerw is available: $remote_version."
    warning "Run './managerw update' to update to the latest version."
  fi
}

# Update managerw
update_self() {
  local current_version remote_version
  current_version=$(extract_version local)
  remote_version=$(extract_version remote || echo "unknown")

  echo "Updating managerw to the latest version [${current_version} -> ${remote_version}]..."
  curl -sSL -o "$0" "$WRAPPER_URL" || error "Failed to download managerw from $WRAPPER_URL."
  chmod +x "$0"
  success "managerw successfully updated to version ${remote_version}."
}

# Ensure the latest manager script is available
ensure_latest_manager() {
  ensure_cache_dir
  if ! is_cache_valid; then
    fetch_manager
  else
    echo "Using cached manager script."
  fi
}

# Append managerw-specific help
append_help() {
cat <<EOF

Managerw-Specific Commands:
  update    Update the managerw script to the latest version.
  version   Show the current and latest versions of managerw.
EOF
}

# Main function
main() {
  case "${1:-}" in
    update)
      update_self
      ;;
    version)
      local local_version remote_version
      local_version=$(extract_version local)
      remote_version=$(extract_version remote || echo "unknown")
      echo "Local version: $local_version"
      echo "Remote version: $remote_version"
      ;;
    help|--help)
      check_self_update
      ensure_latest_manager
      "$CACHE_FILE" "$@" || true
      append_help
      ;;
    *)
      check_self_update
      ensure_latest_manager
      exec "$CACHE_FILE" "$@"
      ;;
  esac
}

main "$@"
