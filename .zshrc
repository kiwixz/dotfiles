if [ -f "/etc/arch-release" ]; then
    GIT_PROMPT="/usr/share/git/completion/git-prompt.sh"
    CCACHE_BIN_DIR="/usr/lib/ccache/bin"
    PLUGIN_SYNTAX_HIGHLIGHTING="/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [ -f "/etc/debian_version" ]; then
    GIT_PROMPT="/usr/lib/git-core/git-sh-prompt"
    CCACHE_BIN_DIR="/usr/lib/ccache"
    PLUGIN_SYNTAX_HIGHLIGHTING="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
else
    echo -e "\e[1;31m$0: could not detect operating system\e[0m" >&2
    return
fi

setopt CORRECT EXTENDED_GLOB GLOB_DOTS HIST_IGNORE_DUPS HIST_REDUCE_BLANKS NUMERIC_GLOB_SORT PROMPT_SUBST
unsetopt FLOW_CONTROL MENU_COMPLETE NOMATCH

HISTFILE="$HOME/.zhistory"
HISTSIZE="65536"
SAVEHIST="$HISTSIZE"
TIMEFMT="%J:  %U user  %S system  %E total  %P cpu  %MKB memory"
WORDCHARS=""

autoload -Uz bashcompinit && bashcompinit
autoload -Uz compinit && compinit

bindkey "\e[1~" beginning-of-line  # for ssh from Windows
bindkey "\e[4~" end-of-line        #
bindkey "$terminfo[kdch1]" delete-char
bindkey "$terminfo[kcbt]" reverse-menu-complete
bindkey "$terminfo[kich1]" overwrite-mode
bindkey "$terminfo[khome]" beginning-of-line
bindkey "$terminfo[kend]" end-of-line
bindkey "$terminfo[knp]" history-beginning-search-forward
bindkey "$terminfo[kpp]" history-beginning-search-backward
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word
bindkey "\e[3;5~" delete-word
bindkey "^H" backward-delete-word

if [ ${+terminfo[smkx]} -a ${+terminfo[rmkx]} ]; then
    function zle-line-init () { echoti smkx }
    function zle-line-finish () { echoti rmkx }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

eval "$(dircolors)"

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' list-colors "$LS_COLORS"
zstyle ':completion:*' matcher-list "" "m:{a-zA-Z}={A-Za-z}"
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache true
zstyle ':completion:*:approximate:*' max-errors 3 numeric
zstyle ':completion:*:match:*' original only


if [ -f "$GIT_PROMPT" ]; then
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM="auto"
    source "$GIT_PROMPT"
    PS1_GIT='$(__git_ps1 "\n%%5F%s" | tr -d " " | tr "\n" " ")'
fi

PS1_SB='%4F'
PS1_LVL='%(2L.%B$(printf ">%.0s" {2..$SHLVL})%b .)'
PS1_EC='%B%(?.%2F0.%1F%?)%b'
PS1_JOBS='%(2j. %3F(%j jobs).%(1j. %3F(1 job).))'
PS1_ID='%6F%n@%M'
PS1_PATH='%6F%~'
PS1_END='%($(($COLUMNS - 40))l.'$'\n''.)%1F%(!.#.$)'
PS1="${PS1_SB}[$PS1_LVL$PS1_EC$PS1_JOBS $PS1_ID $PS1_PATH$PS1_GIT${PS1_SB}]$PS1_END%f "


export ASAN_OPTIONS="check_initialization_order=1:detect_stack_use_after_return=1"
export CLICOLOR_FORCE="1"
export CMAKE_EXPORT_COMPILE_COMMANDS="ON"
export CXXFLAGS="-fdiagnostics-color=always"
export LDFLAGS="-fdiagnostics-color=always"
export MAKEFLAGS="-j $(($(nproc) + 2))"
export NINJA_STATUS="[%f|%r|%u] "
export PATH="$HOME/bin:$CCACHE_BIN_DIR:$PATH"
export PYTHONFAULTHANDLER="1"
export UBSAN_OPTIONS="print_stacktrace=1"

export LESS="-R"
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;44;33m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'
export LESS_TERMCAP_ue=$'\e[0m'


alias -g G='|grep'
alias -g Q='>/dev/null'
alias -g Q2='2>/dev/null'
alias -g QQ='>/dev/null 2>/dev/null'

alias diff="diff --color=auto"
alias grep="grep --color=auto"
alias ls="ls --color=auto --group-directories-first"
alias pacman="pacman --color=auto"
alias sudo="sudo "

alias cmake="cmake -G Ninja"
alias ctest="ctest --output-on-failure"

alias dockrun="docker run -it --rm"
alias gdbrq='gdb -ex "set confirm on" -ex "r" -ex "q" -args'
alias lldbrq='lldb -o r -o "script lldb.frame or os._exit(0)" --'
alias ytdl='youtube-dl -f "bestvideo+bestaudio" --all-subs --convert-subs "srt" --embed-subs --sub-format "srt"'


mkcd() {
    mkdir -p "$*"
    cd "$*"
}

title() {
    printf "\e];%s\a" "$*"
}


title "$USERNAME@$HOST"

[ -f "$PLUGIN_SYNTAX_HIGHLIGHTING" ] && source "$PLUGIN_SYNTAX_HIGHLIGHTING"


for rc in $HOME/.zshrc.d/*(#qN); do
    source $rc
done
