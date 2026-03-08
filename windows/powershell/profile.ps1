# PowerShell Profile
# Location: $PROFILE (typically ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1)

# ============================================================
# Encoding
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

# ============================================================
# Prompt (Starship)
# ============================================================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    $ENV:STARSHIP_SHELL = "powershell"
    function Invoke-Starship-TransientFunction { "&" }
    Invoke-Expression (&starship init powershell)
}

# ============================================================
# Aliases
# ============================================================

# Editor
Set-Alias -Name v    -Value nvim   -ErrorAction SilentlyContinue
Set-Alias -Name vi   -Value nvim   -ErrorAction SilentlyContinue
Set-Alias -Name vim  -Value nvim   -ErrorAction SilentlyContinue

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# ls -> eza
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls  { eza --icons --group-directories-first @args }
    function ll  { eza -l --icons --group-directories-first --git @args }
    function la  { eza -la --icons --group-directories-first --git @args }
    function lt  { eza --tree --icons --group-directories-first @args }
} else {
    function ll { Get-ChildItem -Force @args }
    function la { Get-ChildItem -Force @args }
}

# cat -> bat
if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat { bat --style=plain @args }
}

# cd -> zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# grep -> ripgrep
if (Get-Command rg -ErrorAction SilentlyContinue) {
    Set-Alias -Name grep -Value rg
}

# General
function c     { Clear-Host }
function q     { exit }
function reload { . $PROFILE }

# Git shortcuts
function g    { git @args }
function gs   { git status }
function ga   { git add @args }
function gc   { git commit @args }
function gp   { git push @args }
function gpl  { git pull }
function gl   { git lg }
function gco  { git checkout @args }
function gbr  { git branch @args }
function gdf  { git diff @args }

# ============================================================
# Functions
# ============================================================

# Create directory and cd into it
function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    Set-Location $Path
}

# Show PATH entries one per line
function showpath {
    $env:PATH -split ";" | ForEach-Object { $_ }
}

# Get public IP
function ip {
    (Invoke-WebRequest -Uri "https://ifconfig.me" -UseBasicParsing).Content.Trim()
}

# Extract archives
function extract {
    param([string]$Path)
    $item = Get-Item $Path
    switch ($item.Extension) {
        ".zip" { Expand-Archive -Path $Path -DestinationPath $item.DirectoryName }
        ".7z"  { 7z x $Path }
        ".tar" { tar -xf $Path }
        default { Write-Error "Unsupported archive format: $($item.Extension)" }
    }
}

# ============================================================
# PSReadLine
# ============================================================
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete
    Set-PSReadLineKeyHandler -Key Ctrl+d    -Function DeleteCharOrExit
    Set-PSReadLineKeyHandler -Key Ctrl+l    -Function ClearScreen
}

# ============================================================
# Modules
# ============================================================
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}

# ============================================================
# fzf integration
# ============================================================
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    if (Get-Module -ListAvailable -Name PSFzf) {
        Import-Module PSFzf
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
        Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
    }
}

# ============================================================
# mise (runtime version manager)
# ============================================================
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Out-String | Invoke-Expression
}

# ============================================================
# Local overrides
# ============================================================
$localProfile = Join-Path (Split-Path $PROFILE) "profile.local.ps1"
if (Test-Path $localProfile) { . $localProfile }
