#!/bin/bash
# Omarchy (Arch + Hyprland) setup. Mirrors macOS terminal/wm setup.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$(uname -s)" = "Darwin" ]; then
    echo "This script is for Linux only."
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman not found. This script targets Arch/Omarchy."
    exit 1
fi

echo "=== Omarchy Mirror Setup ==="

# --- yay (AUR helper) ---
if ! command -v yay >/dev/null 2>&1; then
    echo "Installing yay..."
    sudo pacman -S --needed --noconfirm base-devel git
    tmpdir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin"
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmpdir"
fi

# --- Core packages ---
echo "Installing packages..."
sudo pacman -S --needed --noconfirm \
    zsh git curl unzip \
    wezterm \
    tmux \
    eza \
    wl-clipboard grim slurp \
    zsh-syntax-highlighting zsh-autosuggestions \
    noto-fonts noto-fonts-emoji ttf-nerd-fonts-symbols \
    fontconfig

# Cairo font (AUR)
yay -S --needed --noconfirm ttf-cairo || true
# Nerd Font (matches mac WezTerm font family)
yay -S --needed --noconfirm ttf-noto-nerd || true

# --- Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Link pacman-installed plugins into oh-my-zsh custom dir
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    ln -sf /usr/share/zsh/plugins/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null \
        || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    ln -sf /usr/share/zsh/plugins/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null \
        || git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# --- pyenv (AUR) ---
if ! command -v pyenv >/dev/null 2>&1; then
    yay -S --needed --noconfirm pyenv || true
fi

# --- nvm ---
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# --- TPM (tmux plugin manager) ---
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# --- Copy configs ---
echo ""
echo "Copying configs..."

cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
echo "  -> ~/.zshrc"

cp "$SCRIPT_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
echo "  -> ~/.wezterm.lua"

cp "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"
echo "  -> ~/.tmux.conf"

mkdir -p "$HOME/.config/hypr"
cp "$SCRIPT_DIR/hyprland-mac-mirror.conf" "$HOME/.config/hypr/hyprland-mac-mirror.conf"
echo "  -> ~/.config/hypr/hyprland-mac-mirror.conf"

# Source the override from the main hyprland.conf if not already
HYPR_MAIN="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPR_MAIN" ] && ! grep -q "hyprland-mac-mirror.conf" "$HYPR_MAIN"; then
    echo "" >> "$HYPR_MAIN"
    echo "# Mac mirror overrides" >> "$HYPR_MAIN"
    echo "source = ~/.config/hypr/hyprland-mac-mirror.conf" >> "$HYPR_MAIN"
    echo "  -> appended source line to hyprland.conf"
fi

# --- Refresh font cache ---
fc-cache -fv >/dev/null

# --- Default shell ---
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

echo ""
echo "=== Done ==="
echo "1. Reload Hyprland: SUPER+ESC or 'hyprctl reload'"
echo "2. Open WezTerm and run: tmux, then prefix + I to install tmux plugins"
echo "3. Restart your shell: exec zsh"
