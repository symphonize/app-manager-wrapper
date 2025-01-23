#!/usr/bin/env bash
set -euo pipefail

# Metadata
# Version: 2025.03.384306+5e409a8

# Example Manager Script
# This script provides a basic template for creating your own manager.sh script.
# Replace the example functions and logic with your application's specific needs.

# Configuration
APP_NAME="example-app"

LOG_DIR="${LOG_FILE_DIR:-./}"
DEFAULT_LOG_FILE="${LOG_DIR}/${APP_NAME}_log.txt"


# Colors for output
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# Utility functions
success() { echo -e "${GREEN}$1${RESET}"; }
warning() { echo -e "${YELLOW}Warning:${RESET} $1"; }
error() { echo -e "${RED}Error:${RESET} $1"; exit 1; }

# Example functions
build_project() {
  echo "Building $APP_NAME..."
  touch build_output.txt
  success "$APP_NAME built successfully."
}

debug_local() {
  echo "Starting $APP_NAME in debug mode..."
  success "$APP_NAME started in debug mode."
}

run_local_dev() {
  echo "Running $APP_NAME in dev mode..."
  echo "App is running in dev mode." > "$DEFAULT_LOG_FILE"
  success "$APP_NAME is running in dev mode. Logs are in $DEFAULT_LOG_FILE."
}

run_local_prod() {
  echo "Running $APP_NAME in production mode..."
  echo "App is running in production mode." > "$DEFAULT_LOG_FILE"
  success "$APP_NAME is running in production mode. Logs are in $DEFAULT_LOG_FILE."
}

stop_app() {
  echo "Stopping $APP_NAME..."
  rm -f "$DEFAULT_LOG_FILE"
  success "$APP_NAME stopped."
}

show_help() {
  cat <<EOF
Usage: $0 [COMMAND]

Commands:
  build                Build the project.
  debug                Start the application in debug mode.
  dev                  Run the application in development mode.
  prod                 Run the application in production mode.
  stop                 Stop the application.
  help                 Show this help message.

Options:
  --help               Show this help message.

Environment Variables:
  LOG_FILE_DIR     Base directory for log files (default: ./).

Examples:
  $0 build
  $0 debug
  $0 dev
  $0 prod
  $0 stop
EOF
  exit 0
}

interactive_menu() {
  echo "Please choose an option:"
  echo "1. Build Project"
  echo "2. Debug Application"
  echo "3. Run Application (Dev Mode)"
  echo "4. Run Application (Production Mode)"
  echo "5. Stop Application"
  echo "6. Show Help"
  echo "7. Exit"
  read -r -p "Enter choice [1-7]: " choice

  case $choice in
    1) build_project ;;
    2) debug_local ;;
    3) run_local_dev ;;
    4) run_local_prod ;;
    5) stop_app ;;
    6) show_help ;;
    7) echo "Exiting."; exit 0 ;;
    *) echo "Invalid choice. Exiting."; exit 1 ;;
  esac
}

main() {
  if [[ $# -eq 0 ]]; then
    interactive_menu
  else
    case "$1" in
      build) build_project ;;
      debug) debug_local ;;
      dev) run_local_dev ;;
      prod) run_local_prod ;;
      stop) stop_app ;;
      help|--help) show_help ;;
      *) echo "Invalid argument. Use 'help' to see available commands."; exit 1 ;;
    esac
  fi
}

main "$@"
