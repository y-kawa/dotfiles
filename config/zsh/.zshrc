### history
export HISTFILE="$XDG_STATE_HOME/zsh_history"
export HISTSIZE=12000
export SAVEHIST=10000

setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt GLOBDOTS
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INTERACTIVE_COMMENTS
setopt SHARE_HISTORY
setopt MAGIC_EQUAL_SUBST
setopt PRINT_EIGHT_BIT
setopt NO_FLOW_CONTROL

### 補完機能
mkdir -p $XDG_CACHE_HOME/zsh
autoload -U compinit && compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION

### homebrew ###
if [ "$(uname)" = "Darwin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

### Added by Zinit's installer ###
if [[ ! -f $XDG_DATA_HOME/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$XDG_DATA_HOME/zinit" && command chmod g-rwX "$XDG_DATA_HOME/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$XDG_DATA_HOME/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$XDG_DATA_HOME/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

### programs ###

## プロンプト
# starship
__starship_atclone() {
    ./starship init zsh > init.zsh
    ./starship completions zsh > _starship
}
zinit lucid light-mode as'command' from'gh-r' for \
    atclone'__starship_atclone' \
    atpull'%atclone' \
    src'init.zsh' \
    @'starship/starship'

## パッケージマネージャー
# asdf-vm
__asdf_atinit() {
    export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"
    export ASDF_CONFIG_FILE="$XDG_CONFIG_HOME/asdf/asdfrc"
}
zinit wait lucid light-mode for \
    atinit'__asdf_atinit' \
    atpull'asdf plugin update --all' \
    @'asdf-vm/asdf'

## その他
# fzf
zinit wait lucid light-mode as'program' from'gh-r' for @'junegunn/fzf'

### zsh plugins ###
zinit wait lucid blockf light-mode for \
    @'zsh-users/zsh-autosuggestions' \
    @'zsh-users/zsh-completions' \
    @'zdharma-continuum/fast-syntax-highlighting' \
    @'b4b4r07/enhancd'

### key bindings ###

# historyの検索
__fzf__history() {
    BUFFER=$(history -n -r 1 | fzf --exact --reverse --query="$LBUFFER" --prompt="History > ")
    CURSOR=${#BUFFER}
}
zle -N __fzf__history
bindkey '^r' __fzf__history

# git switch を fzf でインタラクティブに操作する
__fzf__git_switch() {
    branches=$(git branch --format="%(refname:short)%09%(authordate:relative)%09%(authorname)" | grep -v HEAD)
    branch=$(echo "$branches" | column -ts "$(printf '\t')" | fzf)
    git switch $(echo "$branch" | awk '{print $1}' )
}
zle -N __fzf__git_switch
bindkey '^b' __fzf__git_switch
