#!/bin/bash
# Terminal setup for Ubuntu/Debian

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$(uname -s)" = "Darwin" ]; then
    echo "This script is for Linux only. Use mac_setup.sh instead."
    exit 1
fi

echo "=== Linux Terminal Setup ==="

# --- Base packages ---
echo "Installing base packages..."
sudo apt update
sudo apt install -y git curl zsh unzip fontconfig

# --- Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- Zsh plugins ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# --- WezTerm ---
if ! command -v wezterm >/dev/null 2>&1; then
    echo "Installing WezTerm..."
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo apt update && sudo apt install -y wezterm
fi

# --- Copy config files ---
echo ""
echo "Copying config files..."

cp "$SCRIPT_DIR/.zshrc.linux" "$HOME/.zshrc"
echo "  -> ~/.zshrc"

cp "$SCRIPT_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
echo "  -> ~/.wezterm.lua"

# --- Fonts ---
echo ""
echo "Installing fonts..."
mkdir -p "$HOME/.local/share/fonts"

# Noto Sans Mono Nerd Font
if ! fc-list | grep -qi "NotoSansM Nerd"; then
    echo "Downloading NotoSansM Nerd Font..."
    curl -fsSL -L -o /tmp/NotoSansMono.tar.xz \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/NotoSansMono.tar.xz" && \
        mkdir -p "$HOME/.local/share/fonts/NotoSansMono" && \
        tar -xf /tmp/NotoSansMono.tar.xz -C "$HOME/.local/share/fonts/NotoSansMono/" && \
        rm /tmp/NotoSansMono.tar.xz && \
        echo "  NotoSansM Nerd Font installed." || \
        echo "WARNING: Could not install Nerd Font."
fi

# Cairo font
if ! fc-list | grep -qi "Cairo"; then
    sudo apt install -y fonts-cairo || echo "WARNING: Could not install Cairo font."
fi

fc-cache -fv

# --- Set default shell to zsh ---
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ""
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

echo ""
echo "=== Done ==="
echo "Close and reopen your terminal."
