# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a macOS environment setup automation toolkit that uses Bash scripts and Gum (a tool for glamorous shell scripts) to bootstrap a new Mac with developer tools, applications, and configurations.

## Architecture

The repository offers two approaches for running the setup:

1. **Orchestrator Pattern** (`orchestrator.sh`): A modular approach that runs individual module scripts from the `modules/` directory sequentially. Each module is self-contained and can be run or skipped independently.

2. **All-in-One Script** (`all-in-one.sh`): A single monolithic script that contains all setup logic inline. This is useful for running the entire setup from a single file.

Both approaches implement the same functionality but differ in organization. The orchestrator pattern is preferred for maintainability.

## Key Components

### Core Scripts

- `orchestrator.sh`: Main entry point that bootstraps Homebrew and Gum, then orchestrates module execution
- `all-in-one.sh`: Standalone script with all setup steps inlined
- `modules/`: Directory containing individual setup modules

### Module Scripts

Module scripts in `modules/` follow a consistent pattern:
- `01_xcode.sh`: Installs Xcode Command Line Tools
- `02_git.sh`: Configures global Git user.name and user.email
- `03_ssh.sh`: Generates ed25519 SSH keys for GitHub
- `04_brew_tools.sh`: Installs CLI tools via Homebrew formulae
- `05_brew_casks.sh`: Installs GUI applications via Homebrew casks
- `06_fish.sh`: Sets up Fish shell as default and installs fisher plugins
- `07_macos_settings.sh`: Applies macOS system preferences via `defaults write`
- `00-clear-dock.sh`: Removes all Dock items and configures Dock settings

### Script Patterns

All scripts follow these conventions:
- Use `set -euo pipefail` for strict error handling
- Include ERR trap for line number reporting
- Check for Gum availability (except orchestrator which installs it)
- Implement idempotency (check if already installed/configured before proceeding)
- Use Gum for user confirmation and visual feedback

## Running Setup

### Full Setup
```bash
./orchestrator.sh
```

This will:
1. Install Homebrew if not present
2. Install Gum for UI
3. Present each module with option to run or skip
4. Log all output to `~/mac_setup.log`

### Individual Modules
```bash
./modules/04_brew_tools.sh
```

Note: Individual modules require Gum to be installed first.

## Modifying Tool/App Lists

### Adding CLI Tools
Edit the `TOOLS` array in `modules/04_brew_tools.sh` or the corresponding section in `all-in-one.sh`:
```bash
TOOLS=(
  bat
  eza
  # Add new tool here
)
```

### Adding Cask Applications
Edit the `CASKS` array in `modules/05_brew_casks.sh` or the corresponding section in `all-in-one.sh`:
```bash
CASKS=(
  1password
  docker
  # Add new cask here
)
```

### Adding New Modules
1. Create new script in `modules/` (e.g., `08_new_module.sh`)
2. Follow existing module pattern (strict error handling, Gum checks, idempotency)
3. Add entry to `MODULES` array in `orchestrator.sh`:
```bash
MODULES=(
  # ...
  "08_new_module.sh:Description of New Module"
)
```
4. Add corresponding inline function in `all-in-one.sh` if maintaining both approaches

## Important Notes

- Scripts assume ARM64 architecture (Apple Silicon) for Homebrew path (`/opt/homebrew/bin`), but include fallback for Intel Macs (`/usr/local/bin`)
- SSH key generation uses ed25519 algorithm and automatically copies public key to clipboard
- Fish shell plugins use fisher package manager
- macOS settings changes require Finder/Dock restart (handled via `killall`)
- All scripts are designed to be re-runnable and will skip already-completed steps

## Gum Dependency

All user interaction and visual feedback depends on [Gum](https://github.com/charmbracelet/gum):
- `gum style`: Styled output and borders
- `gum confirm`: Yes/no prompts
- `gum spin`: Loading spinners
- `gum input`: User input collection

The orchestrator ensures Gum is installed before running any modules.
