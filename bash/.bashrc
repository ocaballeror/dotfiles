# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


# TMUX
if [ "$DESKTOP_SESSION" != "i3" ] && [ -z "$TMUX_DISABLE" ]; then
	if which tmux >/dev/null 2>&1; then
		# if no session is started, start a new session
		[ -z $TMUX ] && [ $UID != 0 ] && tmux -2 -f $HOME/.tmux.conf
	fi
fi

				
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Make bash append rather than overwrite the history on disk
shopt -s histappend
#
# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
shopt -s cdspell

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# our pseudo ssh-copy-id.
which ssh-copy-id > /dev/null
if [ $? -gt 0 ]; then
    function ssh-copy-id () {
	if [ $# -eq 0 ]; then
	    echo "Usage: ssh-copy-id [user@]hostname"
	    return 92
	else
	    # Snagged from commandlinefu.com/commands/view/188
	    cat ~/.ssh/id_rsa.pub | ssh $1 "(cat > tmp.pubkey; mkdir -p .ssh; touch .ssh/authorized_keys; sed -i.bak -e '/$(awk '{print $NF}' ~/.ssh/id_rsa.pub)/d' .ssh/authorized_keys;  cat tmp.pubkey >> .ssh/authorized_keys; rm tmp.pubkey)"
	fi
    }
fi

# set an intelligible keyboard map
setxkbmap es

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
	xterm*|rxvt*)
		PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
		;;
	*)
		;;
esac

# Properly coloured ls 
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Add an "alert alias for long running commands. Use like so:
#	sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Use fuck to correct your last command. Requires python's thefuck (available through pip)
if $(which thefuck >/dev/null); then
	thefuck --alias >/dev/null
fi


# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#Disable scroll lock with Ctrl+S
stty -ixon

#Disable touchpad for one second after the keyboard has been pressed
#syndaemon -i 1 -K -d

# Go a little bit crazy with saving history
export HISTFILESIZE=500000
export HISTSIZE=100000


# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Get colored manpages
export LESS_TERMCAP_mb=$(printf '\e[01;31m') # enter blinking mode – red
export LESS_TERMCAP_md=$(printf '\e[01;35m') # enter double-bright mode – bold, magenta
export LESS_TERMCAP_me=$(printf '\e[0m') # turn off all appearance modes (mb, md, so, us)
export LESS_TERMCAP_se=$(printf '\e[0m') # leave standout mode
export LESS_TERMCAP_so=$(printf '\e[01;33m') # enter standout mode – yellow
export LESS_TERMCAP_ue=$(printf '\e[0m') # leave underline mode
export LESS_TERMCAP_us=$(printf '\e[04;36m') # enter underline mode – cyan 


export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.global"

#export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
#export ORACLE_SID=XE
#export ORACLE_BASE=/u01/app/oracle
#export PATH=$ORACLE_HOME/bin:$PATH
#export CLASSPATH=/home/ocab/workspace/lib/\*
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
export ANDROID_SDK='/opt/android-sdk/bin'

[ "$JAVA_HOME"   ] && export PATH=$PATH:$JAVA_HOME/bin
[ "$ANDROID_SDK" ] && export PATH=$PATH:$ANDROID_SDK

export VISUAL='vim'
export EDITOR='vim'
export VIMRC='$HOME/.vimrc'

#Get syntax highlighting in less. Needs GNU's source-highlight package
export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
export LESS=' -R '
export CONCURRENCY_LEVEL=5

#Some custom enviroment variables that I find useful
export VBOXHOME="/media/$USER/Data/Software/VirtualBoxVMs"
export VMWAREHOME="/media/$USER/Data/Software/VMWare"


# Load alias and function files
[ -f "${HOME}/.bash_prompt" ] && . "${HOME}/.bash_prompt"
[ -f "${HOME}/.bash_aliases" ] && . "${HOME}/.bash_aliases"
[ -f "${HOME}/.bash_functions" ] && . "${HOME}/.bash_functions"
