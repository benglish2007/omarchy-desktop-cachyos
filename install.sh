#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/cyberops-cachyos"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}/cyberops-cachyos"
BACKUP="$STATE/backups/$(date +%Y%m%d-%H%M%S)"
MANIFEST="$STATE/installed-files.txt"

mkdir -p "$STATE" "$DATA" "$BACKUP"
: > "$MANIFEST"

cyan='\033[1;36m'; green='\033[1;32m'; yellow='\033[1;33m'; reset='\033[0m'
say() { printf "%b==>%b %s\n" "$cyan" "$reset" "$*"; }
ok()  { printf "%b ✓ %b%s\n" "$green" "$reset" "$*"; }
warn(){ printf "%b ! %b%s\n" "$yellow" "$reset" "$*"; }

backup_file() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        local rel="${target#$HOME/}"
        mkdir -p "$BACKUP/$(dirname "$rel")"
        cp -a "$target" "$BACKUP/$rel"
    fi
}

install_file() {
    local src="$1" target="$2"
    mkdir -p "$(dirname "$target")"
    backup_file "$target"
    cp -a "$src" "$target"
    printf '%s\n' "$target" >> "$MANIFEST"
}

append_once() {
    local file="$1" line="$2"
    mkdir -p "$(dirname "$file")"
    touch "$file"
    grep -Fqx "$line" "$file" || {
        backup_file "$file"
        printf '\n%s\n' "$line" >> "$file"
    }
}

say "CYBEROPS // CachyOS theme installer"

for cmd in hyprctl quickshell; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "Required command not found: $cmd" >&2
        exit 1
    }
done

if ! fc-match "JetBrainsMono Nerd Font" 2>/dev/null | grep -qi "JetBrains"; then
    warn "JetBrains Mono Nerd Font not detected."
    if command -v pacman >/dev/null 2>&1; then
        warn "Recommended: sudo pacman -S ttf-jetbrains-mono-nerd"
    fi
fi

# Core data and scripts
rm -rf "$DATA/backgrounds"
mkdir -p "$DATA/backgrounds"
if compgen -G "$REPO_DIR/backgrounds/*" >/dev/null; then
    cp -a "$REPO_DIR"/backgrounds/* "$DATA/backgrounds"/
fi

mkdir -p "$HOME/.local/bin"
for s in cyberops-shell cyberops-launch cyberops-reload cyberops-wallpaper cyberops-terminal; do
    install_file "$REPO_DIR/scripts/$s" "$HOME/.local/bin/$s"
    chmod +x "$HOME/.local/bin/$s"
done

# Hyprland
install_file "$REPO_DIR/hypr/cyberops.conf" "$HOME/.config/hypr/cyberops.conf"
install_file "$REPO_DIR/hypr/cyberops-autostart.conf" "$HOME/.config/hypr/cyberops-autostart.conf"

HYPR_MAIN="$HOME/.config/hypr/hyprland.conf"
if [ ! -f "$HYPR_MAIN" ]; then
    warn "No ~/.config/hypr/hyprland.conf found. Created a minimal one."
    mkdir -p "$(dirname "$HYPR_MAIN")"
    touch "$HYPR_MAIN"
fi

append_once "$HYPR_MAIN" 'source = ~/.config/hypr/cyberops.conf'
append_once "$HYPR_MAIN" 'source = ~/.config/hypr/cyberops-autostart.conf'

# Named Quickshell configuration
QS_DIR="$HOME/.config/quickshell/cyberops"
mkdir -p "$QS_DIR"
for f in shell.qml Theme.qml qmldir; do
    install_file "$REPO_DIR/quickshell/cyberops/$f" "$QS_DIR/$f"
done
touch "$QS_DIR/.qmlls.ini" 2>/dev/null || true

# Optional app integrations
if command -v kitty >/dev/null 2>&1; then
    install_file "$REPO_DIR/kitty/cyberops.conf" "$HOME/.config/kitty/cyberops.conf"
    append_once "$HOME/.config/kitty/kitty.conf" 'include cyberops.conf'
    ok "Kitty"
fi

if command -v foot >/dev/null 2>&1; then
    install_file "$REPO_DIR/foot/cyberops.ini" "$HOME/.config/foot/cyberops.ini"
    warn "Foot palette installed as ~/.config/foot/cyberops.ini (Foot has no portable include convention)."
fi

if command -v ghostty >/dev/null 2>&1; then
    install_file "$REPO_DIR/ghostty/cyberops" "$HOME/.config/ghostty/themes/cyberops"
    warn "Ghostty theme installed. Add 'theme = cyberops' to Ghostty config if not already themed."
fi

if command -v alacritty >/dev/null 2>&1; then
    install_file "$REPO_DIR/alacritty/cyberops.toml" "$HOME/.config/alacritty/cyberops.toml"
    warn "Alacritty theme installed. Import cyberops.toml from alacritty.toml if desired."
fi

if command -v btop >/dev/null 2>&1; then
    install_file "$REPO_DIR/btop/cyberops.theme" "$HOME/.config/btop/themes/cyberops.theme"
    ok "btop theme"
fi

if command -v mako >/dev/null 2>&1; then
    install_file "$REPO_DIR/mako/config" "$HOME/.config/mako/config"
    makoctl reload >/dev/null 2>&1 || true
    ok "mako"
fi

if command -v fuzzel >/dev/null 2>&1; then
    install_file "$REPO_DIR/fuzzel/fuzzel.ini" "$HOME/.config/fuzzel/cyberops.ini"
    ok "fuzzel"
fi

if command -v rofi >/dev/null 2>&1; then
    install_file "$REPO_DIR/rofi/cyberops.rasi" "$HOME/.config/rofi/cyberops.rasi"
    ok "rofi"
fi

# GTK / icon hints — non-fatal and no package forcing.
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' >/dev/null 2>&1 || true
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11' >/dev/null 2>&1 || true

# Try to obtain the original theme wallpapers when this repo does not contain them.
if ! compgen -G "$DATA/backgrounds/*" >/dev/null; then
    say "Fetching original CYBEROPS wallpapers from the Omarchy theme repo"
    "$HOME/.local/bin/cyberops-wallpaper" apply || warn "Wallpaper fetch failed; theme itself is installed."
else
    "$HOME/.local/bin/cyberops-wallpaper" apply || true
fi

hyprctl reload >/dev/null 2>&1 || true

# Replace any previous named cyberops shell instance only.
if command -v qs >/dev/null 2>&1; then
    qs -c cyberops kill >/dev/null 2>&1 || true
fi
nohup quickshell -c cyberops >/tmp/cyberops-quickshell.log 2>&1 &

cat > "$STATE/latest-backup" <<EOF
$BACKUP
EOF

echo
ok "CYBEROPS installed"
echo "Backup: $BACKUP"
echo "Quickshell log: /tmp/cyberops-quickshell.log"
echo
echo "Key bindings:"
echo "  SUPER + Space       launcher"
echo "  SUPER + SHIFT + W   next wallpaper"
echo "  SUPER + SHIFT + R   reload theme"
echo
echo "Rollback:"
echo "  ./uninstall.sh"
