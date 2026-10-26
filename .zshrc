
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# load secret env
local_env_file="$HOME/.zsh_secrets"
if [[ -f "$local_env_file" ]]; then
    set -a
    source "$local_env_file"
    set +a
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="tonotdo"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias cpb="pbcopy < "
alias pb="pbpaste > "
alias rp="realpath"
alias so="source ~/.zshrc"
alias kc="kiro-cli"
kcc() {
  kiro-cli chat --no-interactive --trust-all-tools "$*"
}
alias lg="lazygit"
alias bbd="brew bundle dump --force --no-vscode --file=Brewfile"
alias vs="code"
alias n="nvim"
alias pn="pnpm"
alias co="codex"
alias cc="claude"
alias hd='herdr'

# lazygit project switcher
alias pj='cd $(find ~/Projects -maxdepth 1 -type d | fzf)'
alias lgp='pj && lazygit'

# download youtube music
yt() {
  yt-dlp --no-playlist -x --audio-format mp3 --embed-thumbnail --add-metadata "$@"
}

# Find files, then navigate, edit, or copy their paths.
pf() {
  local result file prompt='search: '
  local -a selection fd_args=(--type f --hidden --exclude .git --print0)
  local search_header='輸入檔名或路徑以篩選 · ↑/↓ 選擇結果'
  local action_header='v: Neovim · c: VS Code · y: 複製相對路徑 · Y: 複製絕對路徑 · j: 切換資料夾'

  # -n: search only ./node_modules, which ignore rules would otherwise hide.
  if [[ "$1" == -n ]]; then
    shift
    [[ -d node_modules ]] || { print -u2 'pf: 目前目錄沒有 node_modules'; return 1; }
    fd_args+=(--no-ignore --search-path node_modules)
    prompt='node_modules: '
  else
    fd_args+=(--strip-cwd-prefix)
  fi

  # Skip global Git ignores while preserving project and fd ignore rules.
  # Keep paths NUL-delimited so spaces and newlines are preserved.
  result=$(
    GIT_CONFIG_GLOBAL=<(printf '[core]\nexcludesFile = /dev/null\n') \
      command fd "${fd_args[@]}" |
      FZF_DEFAULT_OPTS= FZF_DEFAULT_OPTS_FILE= command fzf \
        --read0 --print0 --height=60% --layout=reverse --border \
        --border-label=' Find files · 搜尋模式 ' \
        --prompt="$prompt" --query="$*" --header="$search_header" \
        --preview-window='right,50%,border-rounded,wrap' \
        --preview-label=' 預覽 · Shift+↑/↓ ' \
        --preview='
          if [ ! -r {} ]; then
            printf "%s\n" "無法讀取檔案"
          elif [ ! -s {} ]; then
            printf "%s\n" "空白檔案"
          elif [ "$(file --brief --mime-encoding -- {})" = binary ]; then
            printf "%s\n" "二進位檔案"
            file --brief -- {}
          else
            head -c 262144 -- {} | head -n 300
          fi' \
        --footer='Enter: open · Tab: 切換模式 · Esc: 取消' \
        --bind='start:unbind(v,c,y,Y,j),enter:print(open)+accept,esc:abort,ctrl-k:clear-query' \
        --bind='v:print(nvim)+accept,c:print(code)+accept,y:print(relative)+accept,Y:print(absolute)+accept,j:print(cd)+accept' \
        --bind="tab:transform:
          if [ \"\$FZF_INPUT_STATE\" = hidden ]; then
            printf '%s' 'show-input+unbind(v,c,y,Y,j)+change-border-label( Find files · 搜尋模式 )+change-header($search_header)'
          else
            printf '%s' 'hide-input+rebind(v,c,y,Y,j)+change-border-label( Find files · 操作模式 )+change-header($action_header)'
          fi"
  ) || return $?

  selection=("${(@0)result}")
  (( ${#selection} >= 2 )) || return 1
  file=${selection[2]}
  [[ -n "$file" ]] || return 1

  case "${selection[1]}" in
    cd) builtin cd -- "${file:a:h}" ;;
    nvim) command nvim -- "$file" ;;
    code) command code "${file:a}" ;;
    open) command open "${file:a}" ;;
    relative) printf '%s' "$file" | command pbcopy ;;
    absolute) printf '%s' "${file:a}" | command pbcopy ;;
  esac
}

# cmux shortcuts
cm() {
  case "$1" in
    md)
      shift
      local output
      output=$(cmux markdown open "$@" 2>&1) || { echo "$output"; return 1; }
      local surface=$(echo "$output" | grep -o 'surface=surface:[0-9]*' | head -1 | cut -d= -f2)
      local my_pane=$(cmux identify --json 2>/dev/null | grep pane_ref | head -1 | grep -o 'pane:[0-9]*')
      if [[ -n "$surface" && -n "$my_pane" ]]; then
        cmux move-surface --surface "$surface" --pane "$my_pane" --focus true >/dev/null 2>&1
      fi
      ;;
    *) echo "Usage: cm md <path>" ;;
  esac
}

# av shortcuts
av() {
    case "$1" in
        sy) shift; command av sync "$@" ;;
        st) shift; [[ "$*" == *"--push"* ]] && command av sync --rebase-to-trunk "$@" || command av sync --rebase-to-trunk --push=no "$@" ;;
        sp) shift; command av sync --push=yes "$@" ;;
        cm) shift; command av commit "$@" ;;
        ck) shift; command av switch "$@" ;;
        tr) shift; command av tree "$@" ;;
        br) shift; command av branch "$@" ;;
        rs) shift; command av restack "$@" ;;
        ad) shift; command av adopt --parent main "$@" ;;
        last)  shift; command av next --last "$@" ;;
        first) shift; command av prev --first "$@" ;;
        *)  command av "$@" ;;
    esac
}

# Git
# generate .gitignore from toptal templates (e.g. gi node,macos)
gi() { curl -sL "https://www.toptal.com/developers/gitignore/api/$1" -o .gitignore && echo "Created .gitignore for: $1" }


# fnm (Node.js version manager)
eval "$(fnm env --use-on-cd)"

# for uv package
export PATH="$HOME/.local/bin:$PATH"

# openvpn
export PATH="/opt/homebrew/sbin:$PATH"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
