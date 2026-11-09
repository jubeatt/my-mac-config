# my-mac-config

個人開發環境設定檔，透過 symlink 和自動化 script 管理，換電腦時可以快速還原。

## 前置需求

- macOS（Apple Silicon）

## 目錄結構

```
.
├── ai/
│   └── AGENTS.md        # Claude Code / Codex 共用的全域 rules
├── docs/
│   └── nvim.html        # Neovim 架構、選用取捨與日常操作說明
├── ide/
│   ├── nvim/            # Neovim 設定（init.lua 入口、lua/ 模組、vim.pack lockfile）
│   └── vscode/          # VS Code settings, keybindings, extensions
├── terminal/
│   ├── iterm2/          # iTerm2 設定（自動同步）
│   ├── oh-my-zsh/       # 自訂 zsh theme
│   ├── ghostty/         # Ghostty 終端設定
│   ├── herdr/           # herdr 終端設定
│   ├── herdr-app/       # Herdr 桌面 App 設定（版面、主題）
│   └── lazygit/         # Lazygit 設定
├── scripts/
│   ├── link-configs.js          # 建立 symlink
│   ├── setup-terminal.sh        # 安裝 Oh My Zsh、zsh plugin，設定 iTerm2
│   ├── install-extensions.js    # 安裝 VS Code extensions
│   └── gen-vscode-extensions.js # 同步 VS Code extensions 清單
├── hooks/               # git hooks
├── setup.sh             # 依序執行所有 setup 步驟
├── .zshrc               # zsh 設定
├── .gitconfig            # Git 設定
├── .gitignore_global     # Git global ignore 設定
├── .editorconfig         # EditorConfig
├── Brewfile              # Homebrew 套件清單
├── uv.toml               # uv 的 Python 來源設定
└── .oxfmtrc.json         # oxfmt 設定，也是全域預設的 formatter 設定
```

## 快速開始

```bash
git clone https://github.com/jubeatt/my-mac-config.git ~/Projects/my-mac-config
cd ~/Projects/my-mac-config
./setup.sh
```

每個步驟都會先檢查是否已完成，重跑只會補上缺的部分。symlink 的目標位置已有檔案時會直接覆寫，以 repo 的設定為準。

## setup.sh 會做的事

1. 安裝 Homebrew（沒裝才裝）
2. `brew bundle` 安裝 `Brewfile` 的套件，包含 fnm、字體與各個 App
3. 透過 fnm 安裝 Node.js LTS 並設為預設版本
4. `scripts/setup-terminal.sh`：安裝 Oh My Zsh、zsh-autosuggestions、zsh-syntax-highlighting，並把 iTerm2 的設定資料夾指向 `terminal/iterm2/`
5. `scripts/link-configs.js`：建立所有設定的 symlink，見下方對照表
6. 設定 `core.hooksPath` 為 `hooks/`
7. 安裝 Herdr App 的 desktop-notifications mod
8. 執行官方腳本安裝 Collie（沒裝才裝）
9. `scripts/install-extensions.js`：安裝 `ide/vscode/extensions.json` 裡還沒裝的 VS Code extensions

跑完後要手動處理：

- 重啟 iTerm2 載入設定
- 到「系統設定 → 通知」允許 `terminal-notifier`
- 執行 `exec zsh` 重新載入 shell
- 登入 Tailscale 並配對 Collie，見[手機遠端操作](#手機遠端操作collie)

`scripts/` 裡的每支 script 都可以單獨執行，例如只重建 symlink：

```bash
node scripts/link-configs.js
```

## 維護用指令

把本機的狀態寫回 repo：

```bash
# 以目前 VS Code 已安裝的 extensions 為主，更新 ide/vscode/extensions.json
node scripts/gen-vscode-extensions.js

# 預覽變更，不寫入檔案
node scripts/gen-vscode-extensions.js --dryrun

# 重新產生 Brewfile（不會移除套件）
bbd
```

## Symlink 對照表

| 設定       | Repo 位置                              | 目標位置                                           |
| ---------- | -------------------------------------- | -------------------------------------------------- |
| VS Code    | `ide/vscode/`                          | `~/Library/Application Support/Code/User/`         |
| Neovim     | `ide/nvim/`                            | `~/.config/nvim`                                   |
| uv         | `uv.toml`                              | `~/.config/uv/uv.toml`                             |
| Git        | `.gitconfig`                           | `~/.gitconfig`                                     |
| Git ignore | `.gitignore_global`                    | `~/.gitignore_global`                              |
| oxfmt      | `.oxfmtrc.json`                        | `~/.oxfmtrc.json`                                  |
| Zsh        | `.zshrc`                               | `~/.zshrc`                                         |
| Zsh Theme  | `terminal/oh-my-zsh/tonotdo.zsh-theme` | `~/.oh-my-zsh/custom/themes/`                      |
| iTerm2     | `terminal/iterm2/`                     | iTerm2 Preferences → Custom Folder                 |
| Ghostty    | `terminal/ghostty/config`              | `~/.config/ghostty/config`                         |
| herdr      | `terminal/herdr/config.toml`           | `~/.config/herdr/config.toml`                      |
| Herdr App  | `terminal/herdr-app/`                  | `~/.config/herdr-app/`（逐檔連結，見下方）         |
| Lazygit    | `terminal/lazygit/config.yml`          | `~/Library/Application Support/lazygit/config.yml` |

## Herdr App

`~/.config/herdr-app/` 同時放著手寫設定和 App 自己寫的狀態檔，所以只連結手寫的部分：`settings.json`、`keys.json`、`themes/catppuccin-mocha.json` 與 `layouts/peanu.json`。App 寫檔時會沿著 symlink 寫回 repo，改 repo 裡的檔案也會即時套用。

- `keys.json`：以 App 預設快捷鍵為底，改掉會撞到 nvim fzf-lua 的 F 鍵：重新命名 tab／space 改用 `cmd-r`／`cmd-shift-r`。App 只會替沒改過的 `keys.json` 換上新版預設，這份改過就整份歸自己管，App 更新新增的快捷鍵要看 update notes 手動補上。

- `layouts/peanu.json`：複製自內建的 `main` 版面，多一個 0px 區塊給 desktop-notifications mod 執行。內建版面每次啟動都會被覆蓋，所以自訂都放這份。
- desktop-notifications mod 沒有授權條款，不收進 repo，由 `setup.sh` 從 [benjaminsicard/herdr-mods](https://github.com/benjaminsicard/herdr-mods) 下載安裝。通知走 `terminal-notifier`。

## 手機遠端操作（Collie）

用 iPhone 上的 [ColliePWA](https://colliepwa.dev) 透過 Tailscale 私有網路操作 Herdr TUI 裡的 agent。Tailscale 由 `Brewfile` 安裝；Collie 沒有 Homebrew 套件，由 `setup.sh` 執行官方腳本安裝。

`setup.sh` 跑完後手動完成：

1. 開啟 Tailscale App 登入並啟用 CLI，iPhone 的 Tailscale 登入同一個 tailnet。
2. 到 [Tailscale DNS 設定](https://login.tailscale.com/admin/dns)確認 MagicDNS 與 HTTPS Certificates 已啟用。
3. 在一個終端機執行 `herdr` 並保持開啟，再從另一個終端機啟動 Collie：

   ```bash
   COLLIE_MUX=herdr collie start
   collie status
   collie qr
   ```

4. 用 iPhone 掃描 QR code，在 Safari 開啟後加入主畫面，之後都從主畫面圖示開啟。
5. 執行 `collie pair`，到 Collie 的 Settings → System → Paired devices 輸入配對碼。

- Collie 只看得到 Herdr TUI 的 pane，Herdr App 的 session 不會出現。
- 網址跟著機器名稱走，換電腦後手機要重新加入主畫面並配對。
- 對外只走 Tailscale Serve，不開 Funnel。
- 遠端操作時 Mac 要保持開機、連網且不睡眠。
- 和其他 VPN 同時連線時若網址解析逾時、網頁打不開，執行 `tailscale set --accept-dns=false`，不使用 Tailscale DNS。這台 Mac 的 App 會無法解析 tailnet 名稱，連其他裝置要改用 `100.x` IP，手機連 Mac 不受影響。還原用 `tailscale set --accept-dns=true`。

## Python 環境

專案的 Python 版本與虛擬環境由 uv 管理。`uv.toml` 設定 `python-preference = "only-managed"`，讓 uv 使用自己管理的 Python；Homebrew 管理 uv CLI，以及 `yt-dlp` 等工具所需的 Python 依賴。

在 uv 專案根目錄執行：

```bash
uv python install
uv sync --locked
uv run python -c "import sys; print(sys.version); print(sys.executable); print(sys.base_prefix)"
```

專案的 `.python-version` 指定 Python 版本，`pyproject.toml` 與 `uv.lock` 記錄套件依賴；`.venv` 留在本機。上面的檢查指令會列出版本、專案解譯器與基底 Python 路徑。

uv 管理的 Python 安裝與專案環境由 uv 維護。

## Git Hooks

`setup.sh` 會把 `core.hooksPath` 指向 `hooks/`，目前包含：

- **pre-commit** — 自動對 staged 檔案執行 `oxfmt`，oxfmt 不支援的檔案類型會略過
