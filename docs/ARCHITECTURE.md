# Architecture

CYBEROPS CachyOS is deliberately a layer, not a distribution fork.

## Base
- CachyOS provides kernel, packages, security/performance tuning and updates.
- Hyprland remains the compositor.
- Quickshell provides the desktop shell.

## Theme layer
- `colors.toml` is the canonical palette.
- `hypr/cyberops.conf` defines compositor visuals.
- `quickshell/cyberops` implements the top command bar.
- App-specific directories map the same palette into terminal, launcher,
  notification and monitoring tools.

## Safety model
The installer:
1. does not replace CachyOS packages;
2. does not overwrite the user's main Hyprland config;
3. sources two isolated fragments;
4. runs Quickshell as a named `cyberops` config;
5. backs up touched files to XDG state storage.

This makes the desktop reproducible while retaining CachyOS as the underlying OS.
