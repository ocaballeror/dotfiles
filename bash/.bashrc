# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

# Use .bash_customs to set special environmental variables that are
# specific to a system. This file is not in the git repo
[ -f "$HOME/.bash_customs"   ] && . "$HOME/.bash_customs"

# TMUX
if [ -n "$SSH_TTY" ] || [ -n "$SSH_CLIENT" ]; then
	export TMUX_DISABLE=true
fi
if ! $TMUX_DISABLE || [ -z "$TMUX_DISABLE" ]; then
	anti_tmux="linux eterm eterm-color"
	for term in $anti_tmux; do
		[ "$TERM" = "$term" ] && export TMUX_DISABLE=true
	done
	unset anti_tmux

	if [ -n "$DESKTOP_SESSION" ] && ( [ "$DESKTOP_SESSION" = "i3" ] || [ "$(basename "$DESKTOP_SESSION")" = "i3" ] ); then
		export TMUX_DISABLE=true
	fi

	if ! $TMUX_DISABLE || [ -z "$TMUX_DISABLE" ]; then
		if hash tmux 2>/dev/null; then
			# if no session is started, start a new session
			if [ -z "$TMUX" ] && [ $UID != 0 ]; then
				tmux -2 -f "$HOME/.tmux.conf"
			fi
		fi
	fi
fi


# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Make bash append rather than overwrite the history on disk
shopt -s histappend

# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
shopt -s cdspell

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# If set, and Readline is being used, Bash will not attempt to search the PATH
# for possible completions when completion is attempted on an empty line.
shopt -s no_empty_cmd_completion

# If enabled, and the cmdhist option is enabled, multi-line commands are saved
# to the history with embedded newlines rather than using semicolon separators
# where possible.
shopt -s lithist

# Use vi-mode (this may be confusing for first-time users)
# set -o vi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# Properly coloured ls
if [ -x /usr/bin/dircolors ]; then
	if [ -r ~/.dircolors ]; then
		eval "$(dircolors -b ~/.dircolors)"
	else
		eval "$(dircolors -b)"
	fi
fi

# Add an "alert alias for long running commands. Use like so:
#	sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Enable completion in interactive shells
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


# export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
# export ANDROID_SDK='/opt/android-sdk/bin'

# Add java to the path
[ "$JAVA_HOME"   ] && export PATH=$PATH:$JAVA_HOME/bin
[ "$ANDROID_SDK" ] && export PATH=$PATH:$ANDROID_SDK

# Add flatpak directories to xdg data dirs
if hash flatpak 2>/dev/null; then
	for dir in /var/lib/flatpak/exports/share "$HOME/.local/share/flatpak/exports/share"; do
		[ -d "$dir" ] && export XDG_DATA_DIRS="$XDG_DATA_DIRS:$dir"
	done
	[ ${XDG_DATA_DIRS:0:1} = ':' ] && export XDG_DATA_DIRS=${XDG_DATA_DIRS:1}
fi

# Activate conda environments
for dir in .miniconda3 .miniconda .conda Miniconda3 miniconda3; do
	if [ -f "$HOME/$dir/etc/profile.d/conda.sh" ]; then
		. "$HOME/$dir/etc/profile.d/conda.sh"
		conda activate
		envs=$(ls "$HOME/$dir/envs")
		complete -W "$envs" sa
		break
	fi
done

# Add ruby gems directory to the path
ruby_version="$(ruby --version 2>/dev/null | grep -Po 'ruby \K(\d\.?){1,3}')"
if [ -d "$HOME/.gem/ruby/$ruby_version/bin" ]; then
	export PATH=$PATH:$HOME/.gem/ruby/$ruby_version/bin
fi
if [ -d "$HOME/.rvm/bin" ]; then
	export PATH="$PATH:$HOME/.rvm/bin"
fi

# Some default programs
if hash nvim 2>/dev/null; then
	export VISUAL='nvim'
	export EDITOR='nvim'
	alias vim='nvim'
	alias vimdiff='nvim -d'
else
	export VISUAL='vim'
	export EDITOR='vim'
fi
export VIMRC="$HOME/.vimrc"
export BROWSER='firefox'

#Get syntax highlighting in less. Needs GNU's source-highlight package
export LESS=' -FXR '
[ -f /usr/bin/src-hilite-lesspipe.sh ] && export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"

#Some custom enviroment variables that I find useful
export VBOXHOME="$HOME/Data/Software/VirtualBoxVMs"
export VMWAREHOME="$HOME/Data/Software/VMWare"
export MUSICHOME="$HOME/Data/Music"

#Directly stolen from Fedora
export LS_COLORS="rs=0:di=38;5;33:ln=38;5;51:mh=00:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=01;05;37;41:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;40:*.tar=38;5;9:*.tgz=38;5;9:*.arc=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lha=38;5;9:*.lz4=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.tzo=38;5;9:*.t7z=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lrz=38;5;9:*.lz=38;5;9:*.lzo=38;5;9:*.xz=38;5;9:*.bz2=38;5;9:*.bz=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.war=38;5;9:*.ear=38;5;9:*.sar=38;5;9:*.rar=38;5;9:*.alz=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.cab=38;5;9:*.jpg=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.mov=38;5;13:*.mpg=38;5;13:*.mpeg=38;5;13:*.m2v=38;5;13:*.mkv=38;5;13:*.webm=38;5;13:*.ogm=38;5;13:*.mp4=38;5;13:*.m4v=38;5;13:*.mp4v=38;5;13:*.vob=38;5;13:*.qt=38;5;13:*.nuv=38;5;13:*.wmv=38;5;13:*.asf=38;5;13:*.rm=38;5;13:*.rmvb=38;5;13:*.flc=38;5;13:*.avi=38;5;13:*.fli=38;5;13:*.flv=38;5;13:*.gl=38;5;13:*.dl=38;5;13:*.xcf=38;5;13:*.xwd=38;5;13:*.yuv=38;5;13:*.cgm=38;5;13:*.emf=38;5;13:*.ogv=38;5;13:*.ogx=38;5;13:*.aac=38;5;45:*.au=38;5;45:*.flac=38;5;45:*.m4a=38;5;45:*.mid=38;5;45:*.midi=38;5;45:*.mka=38;5;45:*.mp3=38;5;45:*.mpc=38;5;45:*.ogg=38;5;45:*.ra=38;5;45:*.wav=38;5;45:*.oga=38;5;45:*.opus=38;5;45:*.spx=38;5;45:*.xspf=38;5;45:"


# Load alias and function files
[ -f "$HOME/.bash_aliases"   ] && . "$HOME/.bash_aliases"
[ -f "$HOME/.bash_functions" ] && . "$HOME/.bash_functions"
[ -f "$HOME/.bash_prompt"    ] && . "$HOME/.bash_prompt"
