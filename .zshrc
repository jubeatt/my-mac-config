
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
# DISABLE_MAGIC_FUNCTIONS="true"

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
alias lg="lazygit"
alias bbd="brew bundle dump --force --no-vscode --file=Brewfile"
alias vs="codium"

# lazygit project switcher
alias pj='cd $(find ~/Projects -maxdepth 1 -type d | fzf)'
alias lgp='pj && lazygit'

# find file in current dir, cd to its parent
pf() {
  local file
  file=$(fd --type f --hidden --exclude .git | fzf) && cd "$(dirname "$file")"
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
        st) shift; command av sync --rebase-to-trunk "$@" ;;
        sp) shift; command av sync --push=yes "$@" ;;
        cm) shift; command av commit "$@" ;;
        ck) shift; command av switch "$@" ;;
        tr) shift; command av tree "$@" ;;
        br) shift; command av branch "$@" ;;
        re) shift; command av restack "$@" ;;
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

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"

