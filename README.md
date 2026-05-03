# my-config

個人開發環境設定檔，透過 symlink 和自動化 script 管理，換電腦時可以快速還原。

## 前置需求

- macOS
- [Homebrew](https://brew.sh)
- Node.js（用於 IDE 相關 script）

## 目錄結構

```
.
├── ai/.kiro/            # Kiro CLI 設定（agents, skills, steering, hooks）
├── ide/
│   ├── vscode/          # VS Code settings, keybindings, extensions
│   └── kiro/            # Kiro IDE settings, keybindings, extensions
├── terminal/
│   ├── iterm2/          # iTerm2 設定（自動同步）
│   ├── oh-my-zsh/       # 自訂 zsh theme
│   ├── ghostty/         # Ghostty 終端設定
│   ├── cmux/            # cmux 設定（layout commands, settings）
│   └── lazygit/         # Lazygit 設定
├── scripts/
│   ├── link-configs.js  # 建立 symlink
│   ├── setup-terminal.sh        # 終端環境一鍵設定
│   ├── install-extensions.js    # 安裝 IDE extensions
│   └── gen-vscode-extensions.js # 同步 IDE extensions 清單
├── .zshrc               # zsh 設定
├── .vimrc               # Vim 設定
├── .gitconfig            # Git 設定
├── .editorconfig         # EditorConfig
├── Brewfile              # Homebrew 套件清單
└── biome.json            # Biome formatter/linter 設定
```

## 快速開始

### 1. 安裝 Homebrew 套件

```bash
brew bundle
```

### 2. 設定終端環境

一鍵安裝字體、Oh My Zsh、plugin、iTerm2 設定、zsh theme 和 .zshrc symlink：

```bash
bash scripts/setup-terminal.sh
```

完成後重啟 iTerm2 即可。

### 3. 建立 Symlink

```bash
node scripts/link-configs.js --all
node scripts/link-configs.js --vscode
node scripts/link-configs.js --codium
node scripts/link-configs.js --kiro
node scripts/link-configs.js --vim
node scripts/link-configs.js --git
node scripts/link-configs.js --zsh
node scripts/link-configs.js --kiro-cli
node scripts/link-configs.js --ghostty
node scripts/link-configs.js --cmux
node scripts/link-configs.js --lazygit
```

> 不帶參數時會互動式提示選擇。目標目錄不存在的設定會自動跳過。

### 4. 安裝 IDE Extensions

```bash
node scripts/install-extensions.js --vscode
node scripts/install-extensions.js --codium
node scripts/install-extensions.js --kiro
```

## 其他 Script

### 同步 Extensions 清單

以目前 IDE 已安裝的 extensions 為主，更新 `ide/<editor>/extensions.json`：

```bash
node scripts/gen-vscode-extensions.js --vscode
node scripts/gen-vscode-extensions.js --codium
node scripts/gen-vscode-extensions.js --kiro

# 預覽變更，不寫入檔案
node scripts/gen-vscode-extensions.js --vscode --dryrun
node scripts/gen-vscode-extensions.js --codium --dryrun
```

## Symlink 對照表

| 設定 | Repo 位置 | 目標位置 |
|------|----------|---------|
| VS Code | `ide/vscode/` | `~/Library/Application Support/Code/User/` |
| VSCodium | `ide/vscode/` | `~/Library/Application Support/VSCodium/User/` |
| Kiro IDE | `ide/kiro/` | `~/Library/Application Support/Kiro/User/` |
| Kiro CLI | `ai/.kiro/` | `~/.kiro/` |
| Vim | `.vimrc` | `~/.vimrc` |
| Git | `.gitconfig` | `~/.gitconfig` |
| Zsh | `.zshrc` | `~/.zshrc` |
| Zsh Theme | `terminal/oh-my-zsh/tonotdo.zsh-theme` | `~/.oh-my-zsh/custom/themes/` |
| iTerm2 | `terminal/iterm2/` | iTerm2 Preferences → Custom Folder |
| Ghostty | `terminal/ghostty/config` | `~/.config/ghostty/config` |
| cmux | `terminal/cmux/cmux.json`, `settings.json` | `~/.config/cmux/` |
| Lazygit | `terminal/lazygit/config.yml` | `~/Library/Application Support/lazygit/config.yml` |

## Git Hooks

專案使用 `hooks/` 目錄管理 git hooks，clone 後需設定一次：

```bash
git config core.hooksPath hooks
```

目前包含：

- **pre-commit** — 自動對 staged 的 JS/TS/JSON 檔案執行 `biome format --write`

## 備註

- iTerm2 設定透過內建的 Custom Folder 功能自動同步，不需要手動 symlink
- 字體（JetBrains Mono Nerd Font）透過 Homebrew Cask 管理，記錄在 Brewfile
- Oh My Zsh 和 zsh-autosuggestions 由 `setup-terminal.sh` 自動安裝
