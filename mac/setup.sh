#!/bin/bash
# Terminal setup for macOS

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$(uname -s)" != "Darwin" ]; then
    echo "This script is for macOS only. Use linux_setup.sh instead."
    exit 1
fi

echo "=== macOS Terminal Setup ==="

# --- Zsh (already default on macOS, but just in case) ---
if ! command -v zsh >/dev/null 2>&1; then
    echo "Installing zsh..."
    brew install zsh
fi

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
    brew install --cask wezterm
fi

# --- Tmux ---
if ! command -v tmux >/dev/null 2>&1; then
    echo "Installing tmux..."
    brew install tmux
fi

# --- TPM (Tmux Plugin Manager) ---
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# --- Copy config files ---
echo ""
echo "Copying config files..."

cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
echo "  -> ~/.zshrc"

cp "$SCRIPT_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
echo "  -> ~/.wezterm.lua"

cp "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"
echo "  -> ~/.tmux.conf"

cp "$SCRIPT_DIR/.zprofile" "$HOME/.zprofile"
echo "  -> ~/.zprofile"

# --- Fonts ---
echo ""
echo "Installing fonts..."
brew install --cask font-noto-sans-mono-nerd-font || true
brew install --cask font-cairo || true

# --- Set default shell to zsh ---
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ""
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

echo ""
echo "=== Done ==="
echo "Restart your terminal or run: exec zsh"
