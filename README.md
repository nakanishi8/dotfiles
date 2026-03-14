# dotfiles

macOS (Apple Silicon) と Windows 向けの dotfiles です。

## 構成

```
dotfiles/
├── macos/                    # macOS (M-series / zsh / Ghostty)
│   ├── zsh/
│   │   ├── .zshenv           # 環境変数・PATH 設定
│   │   ├── .zshrc            # zsh 設定
│   │   └── sheldon/
│   │       └── plugins.toml  # sheldon プラグイン設定
│   ├── ghostty/
│   │   └── config            # Ghostty ターミナル設定
│   ├── starship/
│   │   └── starship.toml     # プロンプト設定
│   ├── git/
│   │   ├── .gitconfig        # macOS 固有の git 設定
│   │   └── .gitignore_global
│   ├── homebrew/
│   │   └── Brewfile          # パッケージリスト
│   └── install.sh            # インストールスクリプト
│
├── windows/                  # Windows (PowerShell / Windows Terminal)
│   ├── powershell/
│   │   └── profile.ps1       # PowerShell プロファイル
│   ├── starship/
│   │   └── starship.toml     # プロンプト設定
│   ├── git/
│   │   ├── .gitconfig        # Windows 固有の git 設定
│   │   └── .gitignore_global
│   ├── windows-terminal/
│   │   └── settings.json     # Windows Terminal 設定
│   └── install.ps1           # インストールスクリプト
│
└── shared/
    └── git/
        └── .gitconfig        # OS 共通の git エイリアス等
```

## macOS セットアップ

### 要件

- Apple Silicon Mac (M1/M2/M3/M4 シリーズ)
- macOS 13 Ventura 以降

### インストール

```bash
git clone https://github.com/<your-username>/dotfiles2.git ~/dotfiles2
cd ~/dotfiles2
./macos/install.sh
```

ドライランで確認する場合:

```bash
./macos/install.sh --dry-run
```

### 含まれる設定

| ツール             | 説明                                             |
| ------------------ | ------------------------------------------------ |
| **zsh**            | `.zshenv` / `.zshrc` / 補完・履歴設定            |
| **sheldon**        | zsh プラグインマネージャー                       |
| **Ghostty**        | ターミナルエミュレータ (Catppuccin Mocha テーマ) |
| **Starship**       | クロスシェルプロンプト                           |
| **Homebrew**       | パッケージ管理 (Brewfile)                        |
| **git**            | エイリアス・delta diff・osxkeychain              |
| **macOS defaults** | Finder / Dock / キーボード等のシステム設定       |

### 主要ツール (Brewfile より)

| ツール     | 役割                                    |
| ---------- | --------------------------------------- |
| `eza`      | `ls` の代替                             |
| `bat`      | `cat` の代替                            |
| `zoxide`   | スマートな `cd`                         |
| `ripgrep`  | 高速 `grep`                             |
| `fzf`      | ファジーファインダー                    |
| `delta`    | git diff の可視化                       |
| `lazygit`  | git TUI                                 |
| `mise`     | Node / Python / Ruby 等のバージョン管理 |
| `starship` | プロンプト                              |
| `sheldon`  | zsh プラグインマネージャー              |
| `neovim`   | エディタ                                |

---

## Windows セットアップ

### 要件

- Windows 10 21H2 以降 / Windows 11
- PowerShell 7 以降
- winget (App Installer)
- 管理者権限

### インストール

PowerShell を**管理者として**起動し:

```powershell
git clone https://github.com/<your-username>/dotfiles2.git $HOME\dotfiles2
cd $HOME\dotfiles2
.\windows\install.ps1
```

ドライランで確認:

```powershell
.\windows\install.ps1 -DryRun
```

### 含まれる設定

| ツール               | 説明                                          |
| -------------------- | --------------------------------------------- |
| **PowerShell**       | プロファイル (PSReadLine / エイリアス / 関数) |
| **Starship**         | クロスシェルプロンプト                        |
| **Windows Terminal** | Catppuccin Mocha テーマ / キーバインド        |
| **git**              | CRLF 設定・Git Credential Manager             |

### 主要パッケージ (winget)

| ツール     | 役割                                    |
| ---------- | --------------------------------------- |
| `eza`      | `ls` の代替                             |
| `bat`      | `cat` の代替                            |
| `zoxide`   | スマートな `cd`                         |
| `ripgrep`  | 高速 `grep`                             |
| `fzf`      | ファジーファインダー                    |
| `delta`    | git diff の可視化                       |
| `lazygit`  | git TUI                                 |
| `mise`     | Node / Python / Ruby 等のバージョン管理 |
| `starship` | プロンプト                              |
| `neovim`   | エディタ                                |
| `gh`       | GitHub CLI                              |

---

## カスタマイズ

### ローカル設定

バージョン管理したくない設定 (名前・メールアドレス・会社固有の設定等) はローカルファイルに書きます:

**macOS:**

```bash
# ~/.config/zsh/.zshrc.local
export GIT_AUTHOR_NAME="Your Name"
export GIT_AUTHOR_EMAIL="you@example.com"
```

**Windows:**

```powershell
# ~\Documents\PowerShell\profile.local.ps1
$env:GIT_AUTHOR_NAME = "Your Name"
```

**git (両OS共通):**

```ini
# ~/.gitconfig に追記
[user]
    name = Your Name
    email = you@example.com
```

---

## テーマ

両 OS とも **Catppuccin Mocha** カラースキームを使用。

- Ghostty: 組み込みテーマを使用
- Windows Terminal: `settings.json` 内に配色を定義
- Starship: カラー設定を統一
