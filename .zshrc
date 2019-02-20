if [[ -f "/etc/arch-release" ]]; then
    GIT_PROMPT="/usr/share/git/completion/git-prompt.sh"
    CCACHE_BIN_DIR="/usr/lib/ccache/bin"
    PLUGIN_SYNTAX_HIGHLIGHTING="/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -f "/etc/debian_version" ]]; then
    GIT_PROMPT="/usr/lib/git-core/git-sh-prompt"
    CCACHE_BIN_DIR="/usr/lib/ccache"
    PLUGIN_SYNTAX_HIGHLIGHTING="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
else
    echo -e "\e[1;31m$0: could not detect operating system\e[0m" >&2
    return
fi

setopt CORRECT GLOB_DOTS HIST_IGNORE_DUPS HIST_REDUCE_BLANKS NUMERIC_GLOB_SORT PROMPT_SUBST
unsetopt FLOW_CONTROL MENU_COMPLETE

autoload -Uz compinit promptinit
compinit
promptinit

bindkey "^[[5~" history-beginning-search-backward
bindkey "^[[6~" history-beginning-search-forward
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "$terminfo[kdch1]" delete-char
bindkey "$terminfo[kend]" end-of-line
bindkey "$terminfo[khome]" beginning-of-line
if [[ ${+terminfo[smkx]} ]] && [[ ${+terminfo[rmkx]} ]]
then
    function zle-line-init () {
        printf "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache true
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX + $#SUFFIX) / 3)) numeric)'


if [[ -f "$GIT_PROMPT" ]]; then
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM="auto"
    source "$GIT_PROMPT"
    PS1_GIT='$(__git_ps1 "\n%%5F%s" | tr -d " " | tr "\n" " ")'
fi

PS1_SB='%4F'
PS1_EC='%B%(?.%2F0.%1F%?)%b'
PS1_JOBS='%(2j. %3F(%j jobs).%(1j. %3F(1 job).))'
PS1_ID=' %6F%n@%M'
PS1_PATH=' %6F%~'
PS1_END='%1F%(!.#.$)'
export PS1="${PS1_SB}[$PS1_EC$PS1_JOBS$PS1_ID$PS1_PATH$PS1_GIT${PS1_SB}]$PS1_END%f "


export LESS='-R'
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;44;33m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'
export LESS_TERMCAP_ue=$'\e[0m'

export CLICOLOR_FORCE="1"
export CXXFLAGS="-fdiagnostics-color=always"
export LDFLAGS="-fdiagnostics-color=always"
export PATH="$CCACHE_BIN_DIR:$PATH"


alias -g Q='>/dev/null'
alias -g Q2='2>/dev/null'
alias -g QQ='>/dev/null 2>/dev/null'

alias diff="diff --color=auto"
alias grep="grep --color=auto"
alias ls="ls --color=auto --group-directories-first"
alias pacman="pacman --color=auto"
alias sudo="sudo "

alias cmake="cmake -G Ninja"
alias ctest="ctest --output-on-fail"
alias make="make -j $(nproc) -O"

alias cninja='LDFLAGS="$LDFLAGS -fuse-ld=lld" cmake .. && ninja'
alias dockrun="docker run -it --rm"
alias gitlog="git log --all --decorate=short --oneline --graph"
alias ytdl='youtube-dl -f "bestvideo[height<=1440]+bestaudio" --all-subs --convert-subs "srt" --embed-subs --sub-format "srt"'


gitbull() {
    git fetch origin "$1:$1" "${@:2}"
}

mkcd() {
    mkdir -p "$*"
    cd "$*"
}

title() {
    printf "\e];%s\a" "$*"
}


if [[ -f "$PLUGIN_SYNTAX_HIGHLIGHTING" ]]; then
    source "$PLUGIN_SYNTAX_HIGHLIGHTING"
fi
