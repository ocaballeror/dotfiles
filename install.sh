#!/bin/bash
#TODO Add option for minimal output
#TODO Eval is evil. Stop using it
#TODO '-x vim -g' doesn't really work
#TODO Test -y, -o, -n
#TODO Add option to specify git override of an installed program

#BUG Make sure wget is installed before running the pathogen script
#BUG More bugs reported in the pathogen script

####### VARIABLE INITIALIZATION #############
thisfile="$(basename $0)"
thisdir="$(dirname $(readlink -f $thisfile))"

updated=false
assumeyes=false
rootaccess=true
internet=true
gitversion=false

# A poor emulation of arrays for pure compatibility with other shells
dotfiles="bash vim powerline tmux nano ranger ctags cmus"
install="bash vim powerline tmux nano ranger ctags cmus" #Dotfiles to install. This will change over the course of the program

#Exclusions from deployall specifiable with --exclude
#This loop sets to false n variables named xbash xvim xtmux etc
for dotfile in $dotfiles; do
	eval x$dotfile=false # Yes, I know eval is evil but I couldn't find any other way to do this and it seems to work fine
	#eval echo \$x$dotfile
done

####### VARIABLE INITIALIZATION ##############

####### MISC FUNCTIONS DECLARATION ###########
errcho() {
	>&2 echo "$*"
	pdebug "$*"
}

pdebug(){
	local debug=true
	if $debug; then
		[ ! -p "$thisdir/output" ] && mkfifo "$thisdir/output"
		echo "$*" > "$thisdir/output"
	fi
}

quit(){
	if [ -n "$1" ]; then
		pdebug "Quitting with return code $1"
	else
		pdebug "Quitting with return code 0"
	fi
	[ -e "$thisdir/output" ] && rm -f "$thisdir/output" 
	[ -n "$1" ] && exit $1
	exit 0
	pdebug "Why the hell am I printing this"
}

help(){
	echo "Install the necessary dotfiles for the specified programs. These will be installed
	automatically when trying to deploy their corresponding dotfiles.
	Usage: $thisfile [options] [${dotfiles// /|}] 

	Run this script  with no commands to install all dotfiles.
	Use any number of arguments followed by a list of the space-separated programs that you want to install dotfiles for.
	TIP: Run this script again as root to install dotfiles for that user as well

	Supported arguments:	
	-h|--help:        Show this help message
	-g|--git:         Prefer git versions if available
	-n|--no-root:     Ignore commands that require root access
	-o|--offline:     Ignore commands that require internet access
	-p|--no-plugins:  Don't install vim plugins
	-y|--assume-yes:  Assume yes to all questions
	-x|--exclude:     Specify the programs which configurations will NOT be installed"
}

# Prompts the user a Y/N question specified in $1. Returns 0 on "y" and 1 on "n"
askyn(){
	$assumeyes && return 0
	local opt="default" 
	while [ -n "$opt" ] && [ "$opt" != "y" ] && [ "$opt" != "Y" ] && [ "$opt" != "n" ] && [ "$opt" != "N" ]; do 
		read -p "$1" -n1 opt
		printf "\n"
	done

	if [ "$opt" = "n" ] || [ "$opt" = "N" ]; then
		return 1
	else # Will catch empty input too, since Y is the recommended option
		return 0 
	fi
}

####### MISC FUNCTIONS DECLARATION ###########

####### FUNCTIONS DECLARATION ################

#TODO Add support for other programming languages and compiling paradigms (like cmake, python, node etc)
#Return codes
# 0 - Successful installation
# 1 - $gitversion is not even true
# 2 - Build error
# 3 - Git repo not found
# 4 - Git error
# 5 - Skip installation of this program completely
gitinstall(){
	_exitgitinstall(){
		if [ -d "$tmpdir" ]; then
			cd "$cwd"
		   	rm -rf "$tmpdir"
		fi
	}

	$gitversion || { _exitgitinstall && return 1; }
	if ! hash git 2>/dev/null; then
		install -ng git
		[ $? = 0 ] || { _exitgitinstall && return 4; }
	fi

	local first="$1"
	local repotemplate="https://github.com/"
	while [ $# -gt 0 ]; do
		local repo="$repotemplate"
		pdebug "gitinstall processing $1"
		case "$1" in
			tmux) repo+=tmux/tmux.git
				install -ng -y automake
				install -ng -y libevent-dev
				install -ng -y libncurses libncurses-dev;;
			vim) repo+=vim/vim.git
				install -ng -y libevent-dev
				install -ng -y libncurses libncurses-dev;;
			ctags|psutils|fonts-powerline|\
				python-pip) { _exitgitinstall && return 3; };;
			*) repo+="$1/$1.git"
				git ls-remote "$repo" >/dev/null 2>&1
				if [ $? != 0 ] ; then 
					if [ $# = 0 ]; then
						errcho "Err: Could not find git repository for $first"
						{ _exitgitinstall && return 3; }
					else
						shift
						pdebug "$repo doesn't seem to exist. Continuing"
						continue
					fi
				else
					pdebug "$repo aparently exists. Cloning into it"
					#else do nothing and exit the case block
				fi ;;
		esac
		local cwd=$(pwd)
		local tmpdir=$(mktemp -d)
		cd "$tmpdir" 
		pdebug "Cloning $repo"
		git clone "$repo"

		#Get the name of the directory we just cloned
		local cloneddir="${repo##*/}" #Get the substring from the last occurrence of / (the *.git part)
		cloneddir="${cloneddir%%.*}"  #Remove the .git to get only the name

		cd "$cloneddir"
		if [ -f autogen.sh ]; then 
			pdebug "Found autogen"
			install -y -ng automake
			if [ $? -gt 0 ]; then 
				errcho "Err: Could not install package automake necessary for compilation"
				cd "$cwd"
				rm -rf "$tmpdir"
				{ _exitgitinstall && return 2; }
			else
				pdebug "Running autogen"
				chmod +x autogen.sh
				source autogen.sh
			fi
		fi

		if [ -f configure ]; then
			pdebug "Found configure"
			chmod +x configure
			./configure
			if [ $? != 0 ]; then
				errcho "Err: Couldn't satisfy dependencies."
				{ _exitgitinstall && return 2; }
			else
				pdebug "Configure ran ok"
			fi
		fi
		if [ -f Makefile ] || [ -f makefile ]; then
			pdebug "Found makefile"
			make
			if [ $? != 0 ]; then
				errcho "Err: Couldn't build this project"
				{ _exitgitinstall && return 2; }
			else
				pdebug "Make ran ok"
				sudo make install
				if [ $? != 0 ]; then
					pdebug "Error sudo-make-installing"
					{ _exitgitinstall && return 2; }
				else
					pdebug "Make install ran ok. Exiting installation."
					{ _exitgitinstall && return 0; }
				fi
			fi
		else
			errcho "Err: No makefile found. Couldn't build this project"
			{ _exitgitinstall && return 2; }
		fi
		{ _exitgitinstall && return 0; }
	done
	{ _exitgitinstall && return 3; }
}

#TODO Check git for a new version if program is already installed and -g has been set

#Check package managers and install program $1 if it's not installed. The rest of the 
#arguments are other possible names for this program

#Return codes
# 0 - Installation succesful (or program is installed already)
# 1 - User declined installation
# 2 - Program not installed and there's no internet connection
# 3 - Program not installed and there's no root access available
# 4 - Error executing installation
# 5 - Package manager error
install() {
	pdebug "Whattup installing $*"
	auto=$assumeyes
	ignoregit=false
	while [ ${1:0:1} = "-" ]; do
		[ "$1" = "-y" ] &&  { auto=true; shift; pdebug "Yo. -y. Installing in auto mode"; }
		[ "$1" = "-ng" ] && { ignoregit=true; shift; pdebug "Yo. -ng. Ignoring git"; }
	done

	local installcmd=""
	for name in "$@"; do #Check if the program is installed under any of the names provided
		if ( ! $gitversion || $ignoregit ) && hash $name 2>/dev/null; then
			pdebug "This is installed already"
			return 0
		else
			if ! $internet ;then
				pdebug "No interent connection. Exiting installation 4"
				return 2
			fi
		fi
	done

	if ! $rootaccess; then
		pdebug "No root access. Exiting installation 3."
		return 3
	fi

	if ! $auto; then
		local prompt
		#XOR conditions weren't working properly. Maybe a bug in bash?
		if hash "$1" 2>/dev/null; then
			local installed=true
		else
			local installed=false
		fi
		if echo "$*" | grep -w "git" >/dev/null; then
			installed=false
		fi
		if ! $installed; then
			prompt="$1 is not installed. Do you want to try and install it? (Y/n): "
		else
			prompt="$1 is already installed. Do you want to try and install the git version instead? (Y/n): "
		fi
		askyn "$prompt"
		if [ $? = 1 ]; then
			pdebug "User declined. Exiting installation 1."
			return 1
		fi
	fi

	#Clone and install using git if we need to
	if $gitversion && ! $ignoregit && ! $(echo "$1" | grep -w "git" >/dev/null); then
		pdebug "Git version is true. Gitinstalling..."
		while true; do
			gitinstall $*
			local ret=$?
			if [ $ret = 5 ]; then #Return code 5 means we should skip this package completely
				return 1
			elif [ $ret -gt 0 ]; then #An error has ocurred
				askyn "Installation through git failed. Do you want to fall back to the repository version of $1? (Y/n): "
				if [ $? = 0 ]; then
					break
				else
					askyn "Do you want to skip installing $1? (Y/n): "
					if [ $? = 0 ]; then
						errcho "Skipping $1..."
						return 1
					else
						continue	
					fi
				fi
			else
				pdebug "Gitinstallation successful"
				return 0
			fi
		done
	else
		pdebug "Gitversion is false. Installing regularly"
	fi


	# We'll use the awesome pacapt script from https://github.com/icy/pacapt/tree/ng to install packages on any distro (even OSX!)
	if [ ! -x pacapt ]; then 
		wget -O pacapt https://github.com/icy/pacapt/raw/ng/pacapt
		chmod 755 pacapt
	fi
	while [ $# -gt 0 ]; do
		if ! $updated; then
			./pacapt -Sy
		fi
		./pacapt -Qs $1
		if [ $? = 0 ]; then
			pdebug "Found it!"
			sudo ./pacapt $1
			local ret=$?
			if [ $ret != 0 ]; then
				pdebug "Some error encountered while installing $1"
				return $ret
			else
				pdebug "Everything went super hunky dory"
				return 0
			fi	
		else
			pdebug "Nope. Not in the repos"
			shift
		fi
	done
	echo "Package $* not found"
	pdebug "Package $* not found"
}


deploybash(){
	pdebug "Installing bash"
	dumptohome bash
}

deployvim(){
	pdebug "Installing vim"
	install vim
	local ret=$?
	if [ $ret != 0 ]; then
		[ $ret -lt 3 ] && return 1
		[ $ret -gt 3 ] && return 2
	fi

	dumptohome vim

	if ! $novimplugigns; then
		if [ -f "$thisdir/vim/pathogen.sh" ]; then
			source "$thisdir/vim/pathogen.sh"
		else
			errcho "W:Could not find vim/pathogen.sh. Vim addons will not be installed"
		fi
	fi

}


deploypowerline(){
	pdebug "Installing powerline"
	if ! hash powerline 2>/dev/null; then
		( $rootaccess && $internet ) || return 0

		askyn "Powerline is not installed. Do you want to install it? (Y/n): "
		local ret=$?
		[ $ret -lt 3 ] && return 1
		[ $ret -gt 3 ] && return 2

		if ! hash pip 2>/dev/null; then
			echo "Installation of powerline through python's pip is recommended"
		fi
		install -ng "python-pip" "python2-pip" "pip2" "pip"
		ret=$?
		if [ $ret -gt 0 ]; then
			if [ $ret != 2 ]; then
				errcho "W: Couldn't install pip. Will attempt installation of the (potentially outdated) version of powerline in the distro's repositories"
			fi
			install -y "powerline" "python-powerline"
			[ $? -gt 0 ] && return
		else
			#Pip2 is preferred, this configuration has only been tested on python2.
			local pip="pip2"

			if ! hash pip2 2>/dev/null; then 
				pip="pip"
			fi

			sudo $pip install powerline-status
			install -y "psutils"
			[ $? -gt 0 ] && sudo $pip install powerline-mem-segment
		fi

		install -y "fonts-powerline" "powerline-fonts"
		[ $? -gt 0 ] && errcho "W: Could not install patched fonts for powerline. Prompt may look glitched"

		#install -y "python-dev"
		#[ $? = 1 ] || [ $? = 4 ] && return

	fi
	[ ! -d "$HOME/.config" ] && mkdir -p "$HOME/.config"
	cp -r "$thisdir/powerline" "$HOME/.config/"

	if hash tmux 2>/dev/null || hash tmux-git 2>/dev/null; then
		local powerline_root="$(python2.7 -c 'from powerline.config import POWERLINE_ROOT; print (POWERLINE_ROOT)' 2>/dev/null)"
		if [ -z "$powerline_root" ]; then
			powerline_root="$(python2 -c 'from powerline.config import POWERLINE_ROOT; print (POWERLINE_ROOT)' 2>/dev/null)"
			if [ -z "$powerline_root" ]; then
				powerline_root="$(python -c 'from powerline.config import POWERLINE_ROOT; print (POWERLINE_ROOT)' 2>/dev/null)"
				if [ -n "$powerline_root" ]; then
					pdebug "Oh fuck yeah, I found powerline root on the third try"
				fi
			else
				pdebug "Oh fuck yeah, I found powerline root on the second try"
			fi
		else
			pdebug "Oh fuck yeah, I found powerline root on the first try"
		fi
		if [ -n "$powerline_root" ]; then
			pdebug "So yeah, I got powerline_root, it is '$powerline_root'"
			if [ -f "$powerline_root/powerline/bindings/tmux/powerline.conf" ]; then
				mkdir "$HOME/.config/tmux"
				cp "$powerline_root/powerline/bindings/tmux/powerline.conf" "$HOME/.config/tmux/"
			else
				errcho "W: Could not find powerline configuration file in $powerline_root/powerline/bindings/tmux"
			fi
		else
			errcho "W: Could not find and install bindings for tmux"
		fi
	fi
}

deploytmux(){
	pdebug "Installing tmux"
	install "tmux" "tmux-git"
	local ret=$?
	[ $ret -lt 3 ] && return 1
	[ $ret -gt 3 ] && return 2

	if hash powerline 2>/dev/null || hash powerline-status 2>/dev/null; then
		local powerline_root="$(python2.7 -c 'from powerline.config import POWERLINE_ROOT; print (POWERLINE_ROOT)' 2>/dev/null)"
		if [ -z "$powerline_root" ]; then
			powerline_root="$(python2 -c 'from powerline.config import POWERLINE_ROOT; print (POWERLINE_ROOT)' 2>/dev/null)"
			if [ -z "$powerline_root" ]; then
				powerline_root="$(python -c 'from powerline.config import POWERLINE_ROOT; print (POWERLINE_ROOT)' 2>/dev/null)"
				if [ -n "$powerline_root" ]; then
					pdebug "Oh fuck yeah, I found powerline root on the third try"
				fi
			else
				pdebug "Oh fuck yeah, I found powerline root on the second try"
			fi
		else
			pdebug "Oh fuck yeah, I found powerline root on the first try"
		fi
		if [ -n "$powerline_root" ]; then
			pdebug "So yeah, I got powerline_root, it is '$powerline_root'"
			if [ -f "$powerline_root/powerline/bindings/tmux/powerline.conf" ]; then
				mkdir "$HOME/.config/tmux"
				cp "$powerline_root/powerline/bindings/tmux/powerline.conf" "$HOME/.config/tmux/"
			else
				errcho "W: Could not find powerline configuration file in $powerline_root/powerline/bindings/tmux"
			fi
		else
			errcho "W: Could not find and install bindings for tmux"
		fi
	fi

	dumptohome tmux 
}

deploynano(){
	pdebug "Installing nano"
	dumptohome nano
}

deployranger(){
	pdebug "Installing ranger"
	install ranger
	local ret=$?

	[ $ret -lt 3 ] && return 1
	[ $ret -gt 3 ] && return 2

	cp -r "$thisdir/ranger" "$HOME/.config"
}

deployctags(){
	pdebug "Installing ctags"
	install ctags
	local ret=$?
	[ $ret -lt 3 ] && return 1
	[ $ret -gt 3 ] && return 2

	dumptohome ctags
}

deploycmus(){
	pdebug "Installing cmus"
	install cmus
	local ret=$?
	[ $ret -lt 3 ] && return 1
	[ $ret -gt 3 ] && return 2

	[ ! -d "$HOME/.config/cmus" ] && mkdir -p "$HOME/.config/cmus"
	cp "$thisdir/cmus/"* "$HOME/.config/cmus/"
}

deployall(){
	for dotfile in $install; do
		( deploy$dotfile )
		local ret=$?
		pdebug "Ret: $ret"
		if [ $ret = 5 ]; then
			errcho "Err: There was an error using your package manager. You may want to quit the script now and fix it manually before coming back
			
			Press any key to continue"
			read -n1
			printf '\n'
		elif [ $ret = 1 ]; then
			true #User declined installation, but an error message has been shown already
		elif [ $ret != 0 ]; then
			errcho "There was an error installing $dotfile"
		fi
		read -n1
		printf '\n'
	done
}

#Copies every dotfile (no folders) from $1 to $HOME
dumptohome(){
	pdebug "Dumping $1 to home"
	for file in "$thisdir/$1"/.[!.]*; do
		if [ -f "$file" ] && [ "${file##*.}" != ".swp" ]; then
			cp "$file" "$HOME"
		else
			pdebug "W: File $file does not exist"
		fi
	done
}


####### FUNCTIONS DECLARATION ################

####### MAIN LOGIC ###########################

echo "HELLO WORLD"
pdebug "HELLO WORLD"

trap "printf '\nAborted\n'; quit 127"  1 2 3 20

if [ -z "$BASH_VERSION"  ]; then
	echo "W: This script was wrote using bash with portability in mind. However, compatibility with other shells hasn't been tested yet. Bear
	that in mind and run it at your own risk.

	Press any key to continue"

	read -n1
fi

#Deploy and reload everything
install="$dotfiles"
if [ $# = 0 ]; then
	deployall
else
	pdebug "Args: [$*]"
	while [ $# -gt 0 ] &&  [ ${1:0:1} = "-" ]; do 
		pdebug "Parsing arg $1"
		case $1 in
			-h|--help)               help; pdebug "Feel helped already, Im out"; quit;;
			-g|--git|--git-version)  gitversion=true; pdebug "Setting gitversion to true";;
			-n|--no-root)            rootaccess=false;;
			-o|--offline)            internet=false;;
			-p|--no-plugins)         novimplugigns=true;;
			-y|--assume-yes)         assumeyes=true;;
			-x|--exclude)
				shift
				pdebug "Exclude got args: $*"
				while [ $# -gt 0 ] && [ ${1:0:1} != "-" ]; do
					#Check if the argument is present in the array
					found=false
					for dotfile in $dotfiles; do
						if [ "$1" = "$dotfile" ]; then
							install=$(echo $install | sed -r "s/ $1 / /g") #Remove the word $1 from $install
							found=true
							pdebug "Excluding $1"
						fi
					done
					$found || errcho "Program $1 not recognized. Skipping..."
					shift
				done;;
			*) errcho   "Err: Argument '$1' not recognized"; help; quit 1;;
		esac
		shift
	done
	pdebug "No more dash options. Now parsing commands ($# left)"
	if [ $# = 0 ]; then
		pdebug "No commands to parse. Installing all dotfiles"
		deployall
	else # A list of programs has been specified. Will install only those, so we'll first clear the installation list
		install=""
		while [ $# -gt 0 ]; do 	
			pdebug "Parsing command $1"
			# Check if the argument is in our list. Actually checking if it's a substring in a portable way. Cool huh?
			if [ -z ${dotfiles##*$1*} ]; then
				if [ -n ${install##*$1*} ]; then
					install+="$1 "
				#else skip it because it's already in the install list
				fi
			else
				errcho "Err: Program '$1' not recognized. Skipping."
			fi		    
			shift
		done	
		deployall
	fi
	pdebug "Done parsing commands"
fi

#TODO Why the fuck is this not working????
source "$HOME/.bashrc"

quit
