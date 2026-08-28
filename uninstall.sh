#!/usr/bin/env bash
set -euo pipefail

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/cyberops-cachyos"
MANIFEST="$STATE/installed-files.txt"
LATEST="$STATE/latest-backup"

if command -v qs >/dev/null 2>&1; then
    qs -c cyberops kill >/dev/null 2>&1 || true
fi

if [ -f "$MANIFEST" ]; then
    while IFS= read -r f; do
        [ -n "$f" ] && rm -f "$f"
    done < "$MANIFEST"
fi

HYPR="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPR" ]; then
    sed -i '\|source = ~/.config/hypr/cyberops.conf|d' "$HYPR"
    sed -i '\|source = ~/.config/hypr/cyberops-autostart.conf|d' "$HYPR"
fi

if [ -f "$HOME/.config/kitty/kitty.conf" ]; then
    sed -i '\|include cyberops.conf|d' "$HOME/.config/kitty/kitty.conf"
fi

if [ -f "$LATEST" ]; then
    BACKUP="$(cat "$LATEST")"
    if [ -d "$BACKUP" ]; then
        echo "CYBEROPS files removed."
        echo "Backups were preserved at:"
        echo "  $BACKUP"
        echo
        echo "They are not automatically restored because files may have changed since installation."
    fi
fi

hyprctl reload >/dev/null 2>&1 || true
echo "CYBEROPS uninstalled."
