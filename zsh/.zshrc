# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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
if [[ -f ~/.dircolors ]]; then
    eval $(dircolors ~/.dircolors)
fi

# custom aliases
alias reload='source ~/.zshrc'
alias customs='$EDITOR ~/.zsh_customs'

# completion
# fpath=(~/.zsh/completion $path)
# autoload -Uz compinit && compinit -1

# disable correction prompt
# i find it easier to retype the command than to read the correction prompt and decide which option to pick
unsetopt correct

export LESS='-FXRi'
export BROWSER='firefox'
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

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export PIPENV_IGNORE_VIRTUALENVS=1
source /usr/share/nvm/init-nvm.sh
