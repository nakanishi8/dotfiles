#Requires -RunAsAdministrator
# Windows dotfiles installer
# Usage: .\windows\install.ps1 [-DryRun]

[CmdletBinding()]
param(
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$DotfilesDir = Split-Path -Parent $PSScriptRoot
$WindowsDir  = $PSScriptRoot
$SharedDir   = Join-Path $DotfilesDir "shared"

# ============================================================
# Helpers
# ============================================================
function Write-Info    { param($msg) Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[OK]    $msg" -ForegroundColor Green }
function Write-Warn    { param($msg) Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err     { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red; exit 1 }

function Invoke-Run {
    param([scriptblock]$Block, [string]$Description)
    if ($DryRun) {
        Write-Host "[DRY]   $Description" -ForegroundColor Gray
    } else {
        & $Block
    }
}

function New-Symlink {
    param([string]$Source, [string]$Destination)
    $destDir = Split-Path $Destination -Parent
    if (-not (Test-Path $destDir)) {
        Invoke-Run { New-Item -ItemType Directory -Force -Path $destDir | Out-Null } "mkdir $destDir"
    }

    if (Test-Path $Destination) {
        $existing = Get-Item $Destination -Force
        if ($existing.LinkType -eq "SymbolicLink" -and $existing.Target -eq $Source) {
            Write-Info "Already linked: $Destination"
            return
        }
        $backup = "${Destination}.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Invoke-Run { Move-Item -Path $Destination -Destination $backup } "backup $Destination"
        Write-Warn "Backed up: $Destination -> $backup"
    }

    Invoke-Run {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -Force | Out-Null
    } "link $Destination -> $Source"
    Write-Success "Linked: $Destination -> $Source"
}

# ============================================================
# Winget packages
# ============================================================
$WingetPackages = @(
    # Core tools
    @{ Id = "Git.Git" },
    @{ Id = "Neovim.Neovim" },
    @{ Id = "BurntSushi.ripgrep.MSVC" },
    @{ Id = "sharkdp.fd" },
    @{ Id = "sharkdp.bat" },
    @{ Id = "eza-community.eza" },
    @{ Id = "junegunn.fzf" },
    @{ Id = "ajeetdsouza.zoxide" },
    @{ Id = "dandavison.delta" },
    @{ Id = "jesseduffield.lazygit" },
    @{ Id = "jqlang.jq" },
    @{ Id = "mikefarah.yq" },
    @{ Id = "Starship.Starship" },
    @{ Id = "Casey.Just" },
    # Runtime version manager
    @{ Id = "jdx.mise" },
    # GitHub CLI
    @{ Id = "GitHub.cli" },
    # Terminal
    @{ Id = "Microsoft.WindowsTerminal" },
    # Editor
    @{ Id = "Microsoft.VisualStudioCode" },
    # Fonts (via scoop or manual install recommended)
    @{ Id = "DEVCOM.JetBrainsMonoNerdFont" }
)

function Install-WingetPackages {
    if ($env:CI -eq "true") { Write-Info "CI mode: skipping winget packages."; return }
    Write-Info "Installing packages via winget..."
    foreach ($pkg in $WingetPackages) {
        Write-Info "  -> $($pkg.Id)"
        Invoke-Run {
            winget install --id $pkg.Id --accept-source-agreements --accept-package-agreements --silent
        } "winget install $($pkg.Id)"
    }
    Write-Success "Winget packages installed."
}

# ============================================================
# VSCode Extensions
# ============================================================
function Install-VSCodeExtensions {
    Write-Info "Installing VSCode extensions..."
    $codeCmd = Get-Command code -ErrorAction SilentlyContinue
    if (-not $codeCmd) {
        Write-Warn "VSCode 'code' command not found. Skipping extension install."
        Write-Warn "  -> Reopen PowerShell after VSCode installation and re-run this script."
        return
    }
    $extensionsFile = Join-Path $SharedDir "vscode\extensions.txt"
    Get-Content $extensionsFile | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object {
        Write-Info "  -> $_"
        Invoke-Run { code --install-extension $_ --force } "code --install-extension $_"
    }
    Write-Success "VSCode extensions installed."
}

# ============================================================
# PowerShell modules
# ============================================================
function Install-PSModules {
    if ($env:CI -eq "true") { Write-Info "CI mode: skipping PowerShell modules."; return }
    Write-Info "Installing PowerShell modules..."
    $modules = @(
        "PSReadLine",
        "Terminal-Icons",
        "posh-git",
        "PSFzf",
        "z"
    )
    foreach ($mod in $modules) {
        Write-Info "  -> $mod"
        Invoke-Run {
            Install-Module -Name $mod -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
        } "Install-Module $mod"
    }
    Write-Success "PowerShell modules installed."
}

# ============================================================
# Symlinks
# ============================================================
function Set-PowerShellConfig {
    Write-Info "Linking PowerShell profile..."
    $psProfileDir = Split-Path $PROFILE -Parent
    New-Symlink `
        -Source (Join-Path $WindowsDir "powershell\profile.ps1") `
        -Destination $PROFILE
}

function Set-StarshipConfig {
    Write-Info "Linking Starship config..."
    $starshipConfig = Join-Path $env:USERPROFILE ".config\starship.toml"
    New-Symlink `
        -Source (Join-Path $WindowsDir "starship\starship.toml") `
        -Destination $starshipConfig
}

function Set-GitConfig {
    Write-Info "Linking git config..."
    New-Symlink `
        -Source (Join-Path $WindowsDir "git\.gitconfig") `
        -Destination (Join-Path $env:USERPROFILE ".gitconfig")
    New-Symlink `
        -Source (Join-Path $WindowsDir "git\.gitignore_global") `
        -Destination (Join-Path $env:USERPROFILE ".gitignore_global")
    New-Symlink `
        -Source (Join-Path $SharedDir "git\.gitconfig") `
        -Destination (Join-Path $env:USERPROFILE ".config\git\shared_gitconfig")

    Invoke-Run {
        git config --global core.excludesfile "$env:USERPROFILE\.gitignore_global"
    } "git config core.excludesfile"
}

# ============================================================
# Windows Terminal settings
# ============================================================
function Set-WindowsTerminalConfig {
    Write-Info "Checking Windows Terminal config..."
    $wtSettingsDir = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    if (Test-Path $wtSettingsDir) {
        Write-Info "Windows Terminal found. Linking settings..."
        New-Symlink `
            -Source (Join-Path $WindowsDir "windows-terminal\settings.json") `
            -Destination (Join-Path $wtSettingsDir "settings.json")
    } else {
        Write-Warn "Windows Terminal not found. Skipping."
    }
}

# ============================================================
# Enable Developer Mode & long paths
# ============================================================
function Set-WindowsDefaults {
    if ($env:CI -eq "true") { Write-Info "CI mode: skipping Windows registry/defaults."; return }
    Write-Info "Configuring Windows settings..."

    # Long path support
    Invoke-Run {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
            -Name LongPathsEnabled -Value 1
    } "Enable long paths"

    # Enable WSL (optional)
    # Invoke-Run { wsl --install } "Install WSL"

    Write-Success "Windows defaults configured."
}

# ============================================================
# Main
# ============================================================
function Main {
    Write-Host "============================================================" -ForegroundColor Blue
    Write-Host "  Windows dotfiles installer" -ForegroundColor Blue
    Write-Host "  Dotfiles dir: $DotfilesDir" -ForegroundColor Blue
    if ($DryRun) { Write-Host "  [DRY RUN MODE]" -ForegroundColor Yellow }
    Write-Host "============================================================" -ForegroundColor Blue
    Write-Host

    Install-WingetPackages
    Install-VSCodeExtensions
    Install-PSModules
    Set-PowerShellConfig
    Set-StarshipConfig
    Set-GitConfig
    Set-WindowsTerminalConfig
    Set-WindowsDefaults

    Write-Host
    Write-Host "============================================================" -ForegroundColor Blue
    Write-Success "Installation complete!"
    Write-Host "  -> Reload profile: . `$PROFILE" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Blue
}

Main
