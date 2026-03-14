#!/usr/bin/env bash
# macOS dotfiles installer
# Usage: ./macos/install.sh [--dry-run]

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MACOS_DIR="$DOTFILES_DIR/macos"
SHARED_DIR="$DOTFILES_DIR/shared"

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

# ============================================================
# Helpers
# ============================================================
info()    { echo "[INFO]  $*"; }
success() { echo "[OK]    $*"; }
warn()    { echo "[WARN]  $*" >&2; }
error()   { echo "[ERROR] $*" >&2; exit 1; }

run() {
  if $DRY_RUN; then
    echo "[DRY]   $*"
  else
    "$@"
  fi
}

symlink() {
  local src="$1"
  local dst="$2"
  local dst_dir
  dst_dir="$(dirname "$dst")"

  if [[ ! -d "$dst_dir" ]]; then
    run mkdir -p "$dst_dir"
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
      info "Already linked: $dst -> $src"
      return
    fi
    run mv "$dst" "${dst}.bak.$(date +%Y%m%d%H%M%S)"
    warn "Backed up existing: $dst"
  fi

  run ln -sf "$src" "$dst"
  success "Linked: $dst -> $src"
}

# ============================================================
# Checks
# ============================================================
check_macos() {
  [[ "$(uname)" == "Darwin" ]] || error "This script is for macOS only."
}

check_apple_silicon() {
  [[ "$(uname -m)" == "arm64" ]] || error "This script requires Apple Silicon (M-series) Mac."
}

# ============================================================
# Homebrew
# ============================================================
install_homebrew() {
  info "Checking Homebrew..."
  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    success "Homebrew already installed."
  fi
}

install_brew_packages() {
  info "Installing Homebrew packages..."
  run brew bundle install --file="$MACOS_DIR/homebrew/Brewfile" --no-lock
  success "Homebrew packages installed."
}

# ============================================================
# Symlinks
# ============================================================
link_zsh() {
  info "Linking zsh config..."
  symlink "$MACOS_DIR/zsh/.zshenv"  "$HOME/.zshenv"
  symlink "$MACOS_DIR/zsh/.zshrc"   "$HOME/.config/zsh/.zshrc"
  symlink "$MACOS_DIR/zsh/sheldon/plugins.toml" \
          "$HOME/.config/sheldon/plugins.toml"
}

link_starship() {
  info "Linking Starship config..."
  symlink "$MACOS_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
}

link_ghostty() {
  info "Linking Ghostty config..."
  symlink "$MACOS_DIR/ghostty/config" \
          "$HOME/.config/ghostty/config"
}

link_git() {
  info "Linking git config..."
  symlink "$MACOS_DIR/git/.gitconfig"        "$HOME/.gitconfig"
  symlink "$MACOS_DIR/git/.gitignore_global" "$HOME/.gitignore_global"
  symlink "$SHARED_DIR/git/.gitconfig"       "$HOME/.config/git/shared_gitconfig"
  run git config --global core.excludesfile "$HOME/.gitignore_global"
}

# ============================================================
# VSCode Extensions
# ============================================================
install_vscode_extensions() {
  info "Installing VSCode extensions..."
  if ! command -v code &>/dev/null; then
    warn "VSCode 'code' command not found. Skipping extension install."
    warn "  -> Open VSCode and run: Shell Command: Install 'code' command in PATH"
    return
  fi
  local extensions_file="$SHARED_DIR/vscode/extensions.txt"
  while IFS= read -r ext || [[ -n "$ext" ]]; do
    [[ -z "$ext" || "$ext" == \#* ]] && continue
    info "  -> $ext"
    run code --install-extension "$ext" --force
  done < "$extensions_file"
  success "VSCode extensions installed."
}

# ============================================================
# macOS System Defaults
# ============================================================
set_macos_defaults() {
  info "Applying macOS system defaults..."

  # Finder
  run defaults write com.apple.finder AppleShowAllFiles -bool true
  run defaults write com.apple.finder ShowStatusBar -bool true
  run defaults write com.apple.finder ShowPathbar -bool true
  run defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  run defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  run defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Dock
  run defaults write com.apple.dock autohide -bool true
  run defaults write com.apple.dock autohide-delay -float 0
  run defaults write com.apple.dock autohide-time-modifier -float 0.3
  run defaults write com.apple.dock show-recents -bool false
  run defaults write com.apple.dock tilesize -int 48

  # Keyboard
  run defaults write NSGlobalDomain KeyRepeat -int 2
  run defaults write NSGlobalDomain InitialKeyRepeat -int 15
  run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  # Trackpad
  run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  run defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Screenshots
  run defaults write com.apple.screencapture location -string "$HOME/Desktop"
  run defaults write com.apple.screencapture type -string "png"
  run defaults write com.apple.screencapture disable-shadow -bool true

  # Miscellaneous
  run defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  run defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  success "macOS defaults applied. Restart may be required for some settings."
}

# ============================================================
# Main
# ============================================================
main() {
  echo "============================================================"
  echo "  macOS dotfiles installer"
  echo "  Dotfiles dir: $DOTFILES_DIR"
  $DRY_RUN && echo "  [DRY RUN MODE - no changes will be made]"
  echo "============================================================"
  echo

  check_macos
  check_apple_silicon
  install_homebrew
  install_brew_packages
  link_zsh
  link_starship
  link_ghostty
  link_git
  install_vscode_extensions
  set_macos_defaults

  echo
  echo "============================================================"
  success "Installation complete!"
  echo "  -> Reload shell: exec zsh"
  echo "============================================================"
}

main "$@"
