# Example Manager Wrapper

The **Example Manager Wrapper** provides a framework for managing application lifecycle tasks, combining a wrapper script (`managerw.sh`) and a customizable manager script (`manager.sh`). This README explains how to bootstrap, use, and customize the wrapper and manager scripts for your projects.

---

## Overview

### Components

1. **`managerw.sh`**:
   - Ensures the latest version of the `manager.sh` script is cached and available for execution.
   - Delegates commands to `manager.sh` while providing utilities for version checking and updates.

2. **`manager.sh`**:
   - The core script containing project-specific commands, such as building, running, or deploying an application.
   - Fully customizable to meet your application's requirements.

---

## Installation

### Bootstrap the Wrapper

To install the `managerw.sh` script, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/symphonize/app-manager-wrapper/main/bootstrap-manager.sh) install"
```

If you need to specify a custom `MANAGER_URL`, pass it as an environment variable before running the command:

```bash
MANAGER_URL="https://raw.githubusercontent.com/symphonize/app-manager-wrapper/main/manager.sh" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/symphonize/app-manager-wrapper/main/bootstrap-manager.sh) install"
```

This command:
1. Downloads the `managerw.sh` script to the current directory.
2. Creates a `.env` file with default configurations (if it does not already exist).
3. Sets up the `managerw.sh` script for immediate use.

---

## Usage

### Running the Wrapper

Use `managerw.sh` to delegate tasks to the `manager.sh` script:

```bash
./managerw.sh [COMMAND]
```

If `manager.sh` is not cached locally, `managerw.sh` will fetch the latest version before executing the command.

#### Examples:

- Run a build command:
  ```bash
  ./managerw.sh build
  ```

- Check available commands:
  ```bash
  ./managerw.sh help
  ```

### Interactive Mode

If no arguments are provided, the `managerw.sh` script defaults to an interactive menu.

```bash
./managerw.sh
```

---

## Customizing `manager.sh`

The `manager.sh` script includes both command-line support and an interactive menu for managing application tasks. It can be customized to suit your specific requirements.

### Commands

Predefined commands in the example `manager.sh` include:

- `build`: Build the application.
- `debug`: Start the application in debug mode.
- `dev`: Run the application in development mode.
- `prod`: Run the application in production mode.
- `stop`: Stop the application.
- `help`: Show the help menu.

### Interactive Menu

The interactive menu provides a guided interface for users who prefer a menu-driven experience. The default options include:

1. Build the project.
2. Debug the application.
3. Run the application in development mode.
4. Run the application in production mode.
5. Stop the application.
6. Show help.
7. Exit.

### Adding New Commands

1. Define a new function in `manager.sh`:
   ```bash
   deploy_app() {
     echo "Deploying the application..."
     # Add deployment logic here
     success "Application deployed successfully."
   }
   ```

2. Add the function to the command-line logic:
   ```bash
   case "$1" in
     deploy) deploy_app ;;
   esac
   ```

3. Add it to the interactive menu:
   ```bash
   echo "8. Deploy the application"
   ```

---

## Configuration

The wrapper and manager scripts use a `.env` file for configuration. This file resides in the same directory as `managerw.sh` and includes variables like:

```ini
MANAGER_URL="https://raw.githubusercontent.com/symphonize/app-manager-wrapper/main/manager.sh"
```

To customize, edit the `.env` file as needed.

---

## Advanced Features

### Versioning

Both scripts use CalVer (Calendar Versioning) for version management. The format is:

```
<YEAR>.<WEEK>.<TIMESTAMP>+<COMMIT_HASH>
```

For example: `2025.03.215696+example`

### Caching

The `managerw.sh` script caches the `manager.sh` script locally in:

```
~/.app-manager-wrapper/cache
```

This reduces redundant downloads and improves execution speed.

---

## Examples

### Run the Application

```bash
./managerw.sh dev
```

### Use the Interactive Menu

```bash
./managerw.sh
```

---

## Compatibility

This project is compatible with macOS and Linux systems. Ensure `bash` and `curl` are installed and available on your system.

---

