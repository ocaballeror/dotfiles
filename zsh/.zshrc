if [[ -r ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
fi

# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  export USE_POWERLINE=false
  source /usr/share/zsh/manjaro-zsh-prompt
fi
# Load custom aliases
if [[ -e ~/.zsh_aliases ]]; then
  source ~/.zsh_aliases
fi
# Load custom functions
if [[ -e ~/.zsh_functions ]]; then
  source ~/.zsh_functions
fi
# Load custom stuff
if [[ -e ~/.zsh_customs ]]; then
  source ~/.zsh_customs
fi
# Load envvars
if [[ -e ~/.env ]]; then
  source ~/.env
fi
# Load p10k config
if [[ -e ~/.p10k.zsh ]]; then
    source ~/.p10k.zsh
fi
# Load custom dircolors
if [ -f ~/.dircolors ] && hash dircolors 2>/dev/null; then
    eval $(dircolors ~/.dircolors)
fi

# custom aliases
alias reload='source ~/.zshrc'
alias customs='$EDITOR ~/.zsh_customs'

# completion
# fpath=/home/oscar/.zsh/completion
autoload -Uz compinit && compinit -1
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
zstyle ':completion:*' history yes
zstyle ':completion:*' rehash true
zstyle :compinstall filename '/home/oscar/.zshrc'
# autoload -Uz compinit && compinit -i
[ hash uv 2>/dev/null ] && eval "$(uv generate-shell-completion zsh)"

# disable correction prompt
# i find it easier to retype the command than to read the correction prompt and decide which option to pick
unsetopt correct

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_verify            # show command with history expansion to user before running it
# setopt share_history          # share history accross all terminal sessions
export HISTFILE=~/.zsh_history
export HISTSIZE=999999999
export SAVE_HIST=$HISTSIZE

bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

export LESS='-FXRi'
export BROWSER='open'
export VISUAL='nvim'
export EDITOR='nvim'

export LESS_TERMCAP_mb=$(printf '\e[01;31m') # enter blinking mode – red
export LESS_TERMCAP_md=$(printf '\e[01;35m') # enter double-bright mode – bold, magenta
export LESS_TERMCAP_me=$(printf '\e[0m') # turn off all appearance modes (mb, md, so, us)
export LESS_TERMCAP_se=$(printf '\e[0m') # leave standout mode
export LESS_TERMCAP_so=$(printf '\e[01;33m') # enter standout mode – yellow
export LESS_TERMCAP_ue=$(printf '\e[0m') # leave underline mode
export LESS_TERMCAP_us=$(printf '\e[04;36m') # enter underline mode – cyan
export GROFF_NO_SGR=1

# auto ls after cd
autoload -U add-zsh-hook
add-zsh-hook -Uz chpwd (){ ls; }

export CONDA_CHANGEPS1=false
export VIRTUAL_ENV_DISABLE_PROMPT=1

export CARGO_ROOT=$HOME/.cargo
[ -d "$CARGO_ROOT/bin" ] && export PATH="$CARGO_ROOT/bin:$PATH"

export PIPENV_IGNORE_VIRTUALENVS=1
export SQLALCHEMY_SILENCE_UBER_WARNING=1
# export SQLALCHEMY_WARN_20=1
[ -f /usr/share/nvm/init-nvm.sh ] && source /usr/share/nvm/init-nvm.sh

[ -d ~/.local/bin ] && export PATH="$HOME/.local/bin:$PATH"
