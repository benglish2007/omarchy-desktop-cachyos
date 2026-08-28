# CYBEROPS CachyOS

A dark zero-trust command-deck desktop layer for **CachyOS + Hyprland + Quickshell**.

It ports the visual language of the
[`cyberops-omarchy-theme`](https://github.com/benglish2007/cyberops-omarchy-theme)
to a native CachyOS setup without installing Omarchy or replacing CachyOS.

## Look

Canonical palette:

| Role | Color |
|---|---|
| Grid black | `#050816` |
| Electric cyan | `#00F5FF` |
| Hot magenta | `#FF2D95` |
| Acid green | `#39FF14` |
| Threat red | `#FF3147` |
| Signal yellow | `#FFE600` |

The active Hyprland border uses the original cyan → magenta → green gradient.

## What is included

- Hyprland borders, gaps, blur, shadows and animations
- Native Quickshell top bar
  - multi-monitor support
  - Hyprland workspaces
  - focused-window title
  - date/time
  - CyberOps status styling
- Original CyberOps wallpaper support
- Fuzzel and Rofi launcher themes
- Mako notification theme
- Kitty, Foot, Ghostty and Alacritty palettes
- btop theme
- JetBrains Mono Nerd Font integration
- safe installer / uninstaller
- automatic backups

## Requirements

Required:

- CachyOS / Arch-based system
- Hyprland
- Quickshell

Recommended:

```bash
sudo pacman -S --needed \
  ttf-jetbrains-mono-nerd \
  fuzzel \
  mako \
  kitty \
  btop \
  swww
```

`hyprpaper` can be used instead of `swww`.

## Install

```bash
git clone https://github.com/YOUR-USERNAME/cyberops-cachyos.git
cd cyberops-cachyos
./install.sh
```

Then log out/in once if you want to verify clean autostart behavior.

## Key bindings

| Binding | Action |
|---|---|
| `SUPER + Space` | CyberOps launcher |
| `SUPER + SHIFT + W` | Cycle wallpaper |
| `SUPER + SHIFT + R` | Reload CyberOps |
| `SUPER + Enter` | Terminal |

## Quickshell

CYBEROPS is installed as a named Quickshell configuration:

```bash
quickshell -c cyberops
```

This is intentional. It avoids overwriting an existing `~/.config/quickshell`
configuration and gives the theme a clean boundary.

The shell uses Quickshell's Hyprland integration for live workspace and
focused-window state.

## Updating

Pull the repository and rerun the installer:

```bash
git pull
./install.sh
```

The installer is idempotent and makes a new timestamped backup before replacing
managed files.

## Uninstall

From the repository:

```bash
./uninstall.sh
```

The uninstaller removes CyberOps-managed files and leaves timestamped backups
under:

```text
~/.local/state/cyberops-cachyos/backups/
```

Backups are intentionally not auto-restored because the user may have edited
those files after installation.

## Wallpaper assets

For licensing/provenance clarity, this package expects the original artwork
from `cyberops-omarchy-theme`. Copy the three PNG files into `backgrounds/`
before publishing if you want the GitHub repository to be fully self-contained.

If the images are absent, the installer fetches them from the original
repository automatically.

## Design goal

**CachyOS underneath. Omarchy-quality ergonomics on top. CyberOps everywhere.**

The project intentionally avoids becoming a separate distribution. CachyOS
continues to own updates, kernel tuning, hardware support and package
management; this repository owns the reproducible desktop experience.
