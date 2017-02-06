# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac


# TMUX
if which tmux >/dev/null 2>&1; then
    # if no session is started, start a new session
    [ -z $TMUX ] && [ $UID != 0 ] && tmux -2 -f $HOME/.tmux.conf
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

########################################### BASH PROMPT STUFF ############################################################
##  I adapated most of this from aaron bieber's dotfiles, found at: 
##  https://github.com/aaronbieber/dotfiles/blob/master/configs/bashrc
##########################################################################################################################

#Powerline goes first
export POWERLINE_ROOT="$(python2 -c 'from powerline.config import POWERLINE_ROOT; print (POWERLINE_ROOT)' 2>/dev/null)"
if [ -z "$POWERLINE_ROOT" ]; then
    export POWERLINE_ROOT="$(python -c 'from powerline.config import POWERLINE_ROOT; print (POWERLINE_ROOT)' 2>/dev/null)"
fi
[ -n "$POWERLINE_ROOT" ] && export POWERLINE_ROOT="$POWERLINE_ROOT/powerline"

# If powerline is installed, load it
if [ -n "$POWERLINE_ROOT" ] && [ -f $POWERLINE_ROOT/bindings/bash/powerline.sh ]; then
    . $POWERLINE_ROOT/bindings/bash/powerline.sh
else
    
	if [ "$color_prompt" = yes ]; then

		# Reset
		Color_Off="\[\033[0m\]"       # Text Reset

		# Regular Colors
		Black="\[\033[0;30m\]"        # Black
		Red="\[\033[0;31m\]"          # Red
		Green="\[\033[0;32m\]"        # Green
		Yellow="\[\033[0;33m\]"       # Yellow
		Blue="\[\033[0;34m\]"         # Blue
		Purple="\[\033[0;35m\]"       # Purple
		Cyan="\[\033[0;36m\]"         # Cyan
		White="\[\033[0;37m\]"        # White
		Grey="\[\033[38;5;8m\]"	      # Grey
		Magenta="\[\033[38;5;163m\]"  # Magenta

		# Bold
		BBlack="\[\033[1;30m\]"       # Black
		BRed="\[\033[1;31m\]"         # Red
		BGreen="\[\033[1;32m\]"       # Green
		BYellow="\[\033[1;33m\]"      # Yellow
		BBlue="\[\033[1;34m\]"        # Blue
		BPurple="\[\033[1;35m\]"      # Purple
		BCyan="\[\033[1;36m\]"        # Cyan
		BWhite="\[\033[1;37m\]"       # White
		BGrey="\[\033[1;38;5;8m\]"	      # Grey
		BMagenta="\[\033[1;38;5;163m\]"  # Magenta

		# Background
		On_Black="\[\033[40m\]"       # Black
		On_Red="\[\033[41m\]"         # Red
		On_Green="\[\033[42m\]"       # Green
		On_Yellow="\[\033[43m\]"      # Yellow
		On_Blue="\[\033[44m\]"        # Blue
		On_Purple="\[\033[45m\]"      # Purple
		On_Cyan="\[\033[46m\]"        # Cyan
		On_White="\[\033[47m\]"       # White

		# High Intensty
		IBlack="\[\033[0;90m\]"       # Black
		IRed="\[\033[0;91m\]"         # Red
		IGreen="\[\033[0;92m\]"       # Green
		IYellow="\[\033[0;93m\]"      # Yellow
		IBlue="\[\033[0;94m\]"        # Blue
		IPurple="\[\033[0;95m\]"      # Purple
		ICyan="\[\033[0;96m\]"        # Cyan
		IWhite="\[\033[0;97m\]"       # White

		# Bold High Intensty
		BIBlack="\[\033[1;90m\]"      # Black
		BIRed="\[\033[1;91m\]"        # Red
		BIGreen="\[\033[1;92m\]"      # Green
		BIYellow="\[\033[1;93m\]"     # Yellow
		BIBlue="\[\033[1;94m\]"       # Blue
		BIPurple="\[\033[1;95m\]"     # Purple
		BICyan="\[\033[1;96m\]"       # Cyan
		BIWhite="\[\033[1;97m\]"      # White

		# High Intensty backgrounds
		On_IBlack="\[\033[0;100m\]"   # Black
		On_IRed="\[\033[0;101m\]"     # Red
		On_IGreen="\[\033[0;102m\]"   # Green
		On_IYellow="\[\033[0;103m\]"  # Yellow
		On_IBlue="\[\033[0;104m\]"    # Blue
		On_IPurple="\[\033[10;95m\]"  # Purple
		On_ICyan="\[\033[0;106m\]"    # Cyan
		On_IWhite="\[\033[0;107m\]"   # White

		# Various variables you might want for your PS1 prompt instead
		Time12h="\T"
		Time12a="\@"
		TimeShort="\A"
		PathFull="\w"
		PathShort="\W"
		NewLine="\n"
		Jobs="\j"

		# This PS1 snippet was adopted from code for MAC/BSD I saw from:
		# http://allancraig.net/index.php?option=com_content&view=article&id=108:ps1-export-command-for-git&catid=45:general&Itemid=96
		# I tweaked it to work on UBUNTU 11.04 & 11.10 plus made it mo' better

		pwdtail () { #returns the last 2 fields of the working directory
			pwd|awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
		}


		function prompt_command(){

			if [ $? -ne 0 ]; then
				ERRPROMPT='$? '
			else
				ERRPROMPT=""
			fi

			local GIT=""
			local PATHSHORT=`pwdtail`
			local LOAD=`uptime | sed 's/,//g' | awk '{min=NF-2;print $min}'`
			
			function git_status() {
				git_status_output=$(git status 2> /dev/null) || return 1

				branch_name() {
					sed -n 's/.*On branch //p' <<< "$git_status_output"
				}

				number_of_commits() {
					local branch_prefix='# Your branch is '
					local branch_suffix='by [[:digit:]]+'
					if [[ "$git_status_output" =~ ${branch_prefix}"$1".*${branch_suffix} ]]
					then
						echo ${BASH_REMATCH[0]//[^0-9]/}
					else
						echo 0 && return 1
					fi
				}

				match_against_status() {
					local pattern="$1"
					[[ "$git_status_output" =~ ${pattern} ]]
				}

				working_dir_clean() {
					match_against_status 'working tree clean' || match_against_status 'working directory clean'
				}

				local_changes() {
					local added='Changes to be committed'
					local not_added='Changes not staged for commit'
					match_against_status "$added|$not_added"
				}

				untracked_files() {
					match_against_status 'Untracked files'
				}

				dashline() {
					printf '%.0s-' {1..$1}
				}

				ahead_arrow() {
					if commits_ahead=$(number_of_commits "ahead")
					then
						echo -e "$bold$(dashline $commits_ahead)$Color_Off> $commits_ahead ahead"
					fi
				}

				behind_arrow() {
					if commits_behind=$(number_of_commits "behind")
					then
						echo "$commits_behind behind <$bold$(dashline $commits_behind)$Color_Off"
					fi
				}

				branch_part() {
					local branch_colour=""

					if $( untracked_files )
					then
						branch_colour=$Red
					elif $( local_changes )
					then
						branch_colour=$Yellow
					elif $( working_dir_clean )
					then
						branch_colour=$Green
					fi
					echo "$branch_colour$(branch_name)$Color_Off"
				}

				local behind_part=$(behind_arrow)
				local ahead_part=$(ahead_arrow)

				if [[ ! "$behind_part" && ! "$ahead_part" ]]
				then
					git_prompt="$(branch_part)"
				else
					git_prompt="$(branch_part) $behind_part|$ahead_part"
				fi

				echo -e "$White($git_prompt$White)"
			}

			function nl(){
				git_status
				dirs -c
				local path=$(dirs)
				local promptlength=$((${#USER}+${#HOSTNAME}+${#path}+${#git_prompt}))
				if [ $(($(tput cols) - $promptlength)) -lt 30 ]; then
					printf '\n'
				else
					printf 'n'
				fi
			}

			if  [ $UID = 0 ]; then
				#For performance reasons, ignore git when logged in as root. You shouldn't be coding as root anyway.
				#export PS1=$Red$ERRPROMPT$IBlue'['$BRed'\u'$IRed'@'$BRed'\h'$IBlack' '$Grey$TimeShort$IBlue'] '$IYellow'\w'$Color_Off' '$(git_status)'\$ '
				export PS1=$Red$ERRPROMPT$IBlue'['$BRed'\u'$IRed'@'$BRed'\h'$IBlack' '$Grey$TimeShort$IBlue'] '$IYellow'\w'$Color_Off$(nl)'\$ '
			else
				export PS1=$Red$ERRPROMPT$IBlue'['$BMagenta'\u'$Magenta'@'$BMagenta'\h'$IBlack' '$Grey$TimeShort$IBlue'] '$ICyan'\w'$(git_status)$Color_Off$(nl)'\$ '
			fi
		}


		PROMPT_COMMAND=( prompt_command )

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


# Load alias and function files
[ -f "${HOME}/.bash_aliases" ] && . "${HOME}/.bash_aliases"
[ -f "${HOME}/.bash_functions" ] && . "${HOME}/.bash_functions"

