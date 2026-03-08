# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Cross-platform dotfiles for macOS (Apple Silicon / zsh / Ghostty) and Windows (PowerShell / Windows Terminal). All config files are managed as symlinks pointing into this repository.

## Running the installers

**macOS** (from repo root):
```bash
./macos/install.sh            # full install
./macos/install.sh --dry-run  # preview only, no changes
```

**Windows** (PowerShell as Administrator):
```powershell
.\windows\install.ps1           # full install
.\windows\install.ps1 -DryRun  # preview only, no changes
```

Both installers are idempotent — re-running them is safe. Existing files are backed up with a timestamp suffix (`.bak.YYYYMMDDHHMMSS`) rather than overwritten.

## Architecture

### Symlink model
The installers create symlinks from `$HOME` locations into this repo. No file copying occurs.

| Symlink target | Source in repo |
|---|---|
| `~/.zshenv` | `macos/zsh/.zshenv` |
| `~/.config/zsh/.zshrc` | `macos/zsh/.zshrc` |
| `~/.config/sheldon/plugins.toml` | `macos/zsh/sheldon/plugins.toml` |
| `~/.config/ghostty/config` | `macos/ghostty/config` |
| `~/.config/starship.toml` | `macos/starship/starship.toml` |
| `~/.gitconfig` | `macos/git/.gitconfig` or `windows/git/.gitconfig` |
| `~/.config/git/shared_gitconfig` | `shared/git/.gitconfig` |

### git config layering
Three layers are composited at runtime via `[include]`:
1. `shared/git/.gitconfig` — aliases, cross-platform settings
2. `macos/git/.gitconfig` or `windows/git/.gitconfig` — OS-specific (credential helper, autocrlf, delta)
3. `~/.config/git/local_gitconfig` — machine-local overrides (user.name, user.email); **not tracked**

### Machine-local overrides (not tracked by git)
| File | Purpose |
|---|---|
| `~/.zshenv.local` | machine-specific env vars (sourced at end of `.zshenv`) |
| `~/.config/zsh/.zshrc.local` | machine-specific shell config (sourced at end of `.zshrc`) |
| `~/.config/git/local_gitconfig` | user.name, user.email, work-specific git settings |
| `~/Documents/PowerShell/profile.local.ps1` | machine-specific PS config (sourced at end of profile) |

### macOS zsh loading order
`.zshenv` (sets `$ZDOTDIR`) → `$ZDOTDIR/.zshrc` (interactive config)

`.zshenv` handles: XDG dirs, Homebrew PATH (`/opt/homebrew`), EDITOR, LANG, Cargo env, ZDOTDIR.
`.zshrc` handles: options, completion, Starship prompt, keybindings, aliases, functions, sheldon plugins, mise, fzf.

### Tool management
- **macOS packages**: `macos/homebrew/Brewfile` — update with `brew bundle dump --force --file=macos/homebrew/Brewfile`
- **zsh plugins**: `macos/zsh/sheldon/plugins.toml` (sheldon lazy-loads via `zsh-defer`)
- **Runtime versions** (Node, Python, etc.): mise on both platforms

## Key design decisions

- macOS assumes **Apple Silicon** only; `install.sh` will exit on Intel Macs.
- `autocrlf = input` on macOS, `autocrlf = true` on Windows — edit OS-specific `.gitconfig` files, not `shared/git/.gitconfig`.
- Both platforms use the same Catppuccin Mocha color scheme and Starship config structure for visual consistency.
- The `symlink()` / `New-Symlink` helpers skip silently if the link already points to the correct target, making re-runs safe.
