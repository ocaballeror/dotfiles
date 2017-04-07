#!/bin/bash

#TODO Minimize output. Add option for full output of external commands

## To extend this script and add new programs:
# 1. Create a dir with the name of the program in the dotfiles directory
# 2. Add the name of the program to the dotfiles array a few lines below
# 3. Create a function called "deploy<name-of-the-program>" that copies the required
#    files to their respective directories. 
#
#    Tip: Use dumptohome "name-of-the-program" to copy everything in the folder to the home directory
# 4. If you don't want your program to be cloned and build manually with git, use the -ng flag for the install function
# 5. Done!



####### VARIABLE INITIALIZATION #############
# Environment definition
thisfile="$(basename $0)"
thisdir="$(dirname $(readlink -f $0))"
tempdir="$(mktemp -d)"

# Default values for cli parameters
updated=false
assumeyes=false
rootaccess=true
internet=true
gitversion=false
novimplugins=false
skipinstall=false
gitoverride=false
debug=false

# Misc global variables
highlight=`tput setaf 6`    # Set the color for highlighted debug messages
errhighlight=`tput setaf 1` # Set the color for highlighted debug messages
reset=`tput sgr0`           # Get the original output color back
makeopts="-j2 "              # Will be invoked on every make command

if [ -n "$XDG_CONFIG_HOME" ]; then 
	config="$XDG_CONFIG_HOME"
else
	config="$HOME/.config"
fi
[ ! -d $config ] && mkdir -p "$config"

# A poor emulation of arrays for pure compatibility with other shells
dotfiles="bash cmus ctags emacs i3 lemonbar nano powerline ranger tmux vim neovim X"
install="" #Dotfiles to install. This will change over the course of the program

####### VARIABLE INITIALIZATION ##############

####### MISC FUNCTIONS DECLARATION ###########
errcho() {
	>&2 echo "${errhighlight}$*${reset}"
	pdebug "${errhighlight}$*${reset}"
}

pdebug(){
	if $debug; then
		#[ ! -p "$thisdir/output" ] && mkfifo "$thisdir/output"
		echo $* >> "$thisdir/output"
	fi
}

quit(){
	local ret
	if [ -n "$1" ]; then
		ret=$1
	else
		ret=0
	fi
	pdebug "Quitting with return code $ret"

	#[ -p "$thisdir/output" ] && rm "$thisdir/output"
	[ -f "$thisdir/output" ] && rm "$thisdir/output"
	if [ -d "$tempdir" ]; then
		if ! rm -rf "$tempdir" >/dev/null 2>&1; then
			errcho "W: Temporary directory $temdir could not be removed automatically. Delete it to free up space"
		fi
	fi

	exit $ret
}

help(){
	echo "Usage: $thisfile [options] [${dotfiles// /|}] 

Run this script  with no commands to install all dotfiles.
Use any number of arguments followed by a list of the space-separated programs that you want to install dotfiles for.

Supported arguments:	
	-h|--help:        Show this help message
	-g|--git:         Prefer git versions if available
	-i|--no-install:  Skip all installations. Only copy files
	-n|--no-root:     Ignore commands that require root access
	-o|--offline:     Ignore commands that require internet access
	-p|--no-plugins:  Don't install vim plugins
	-d|--debug: 	  Print debug information to an external pipe
	-y|--assume-yes:  Assume yes to all questions
	-x|--exclude:     Specify the programs which configurations will NOT be installed
	--override: 	  Override currently installed version with the git one. (Implies -g).

TIP: Run this script again as root to install dotfiles for that user as well"
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

# Pretty self explainatory. Creates a directory in ~/.fonts/$1 and clones the git repo $2 into it
# If no $2 is passed, it will try to find the font in the .fonts directory of this repo
installfont (){
	local fonts="$HOME/.fonts"
	[ -d $fonts ] ||  mkdir "$fonts"
	local path="$fonts/$1"
	local cwd="$(pwd)"
	cd "$fonts"

	if [ $# -lt 2 ]; then
		[ -d "$thisdir/.fonts/$1" ] && cp  -r "$thisdir/.fonts/$1" .
	else
		if ! hash git 2>/dev/null || ! $internet; then
			if $skipinstall || ! $internet; then
				if fc-list | grep -i "$1" >/dev/null; then
					return 0
				else
					echo "W: Font '$1' could not be installed"
					return 2
				fi
			else
				install -y -ng git
			fi
		fi

		shift
		if ! [ -d "$path" ]; then
			git clone $*
		else
			if [ ! -d "$path/.git" ]; then
				rm -rf "$path"
				git clone $*
			else
				pushd . >/dev/null
				cd "$path"
				git pull
				popd >/dev/null
			fi
		fi

		# If we're not going to install X, at least append this to xprofile
		if [ -n "${install##*X*}" ]; then
			echo "xset fp+ $fonts" >> $HOME/.xprofile
		fi
	fi

	cd "$cwd"
}

pacapt(){
	# We'll use the awesome pacapt script from https://github.com/icy/pacapt/tree/ng to install packages on any distro (even OSX!)
	if [ ! -f "$tempdir/pacapt" ]; then
		echo "Detecting distro's package manager..."
		pdebug "Downloading pacapt and stuff"

		local ret
		if hash curl 2>/dev/null; then
			curl -skL https://github.com/icy/pacapt/raw/ng/pacapt -o "$tempdir/pacapt"
			ret=$?
		elif hash wget 2>/dev/null; then
			wget --no-check-certificate -qO "$tempdir/pacapt" https://github.com/icy/pacapt/raw/ng/pacapt 
			ret=$?
		else
			echo "Err: Please install either curl or wget to continue"
		fi
		if [ $ret != 0 ]; then
			errcho "Err: Could not connect to the internet. Make sure you are connected or use -o to run this script offline"	
			return 127
		fi
	fi

	local usesudo
	[ "$1" = "sudo" ] &&  { usesudo="sudo"; shift; }

	chmod +x "$tempdir/pacapt"
	$usesudo "$tempdir/pacapt" $*
	local ret=$?

	return $ret
}

# Used when deploying i3status. Compares two version numbers.
# Returns 0 if they are equal, 1 if the first one is bigger, 2 if the second one is bigger
# (Avoid having to call the function twice) Returns 3 if the first is bigger or equal, 4 if second is bigger or equal
# Return codes:
# 0 - Versions are equal
# 1 - $1 is bigger
# 2 - $2 is bigger
# 
compare_versions()  {
	local v1="$(echo "$1" | awk -F. '{ printf("%03d%03d%03d\n", $1,$2,$3); }')"
	local v2="$(echo "$2" | awk -F. '{ printf("%03d%03d%03d\n", $1,$2,$3); }')"

	if [ "$v1" -ge "$v2" ]; then
		return 3	
	elif [ "$v1" -le "$v2" ]; then
		return 4
	elif [ "$v1" -lt "$v1" ]; then
		return 2
	elif [ "$v1" -gt "$v2" ]; then
		return 1
	else
		return 0
	fi
}
####### MISC FUNCTIONS DECLARATION ###########

####### FUNCTIONS DECLARATION ################

# Ok, this is the shittiest code I've ever written, but here is a custom function to install tmux from git. 
# It "parses" the github page of tmux to find the version number of the latest release, then injects it into
# the configure script, so when it's installed, tmux -V reports the latest version instead of "tmux master", which
# can be problematic for other programs  (i.e. powerline)
gitinstall_tmux() {
	install -y -ng libevent-dev libevent
	install -y -ng libncurses-dev libncurses.-dev ncurses-devel ncurses-devel.*
	install -y -ng pkg-config
	install -y -ng automake

	if hash curl 2>/dev/null; then
		local version="$(curl -sL https://github.com/tmux/tmux/releases/latest  | grep -Po '/tmux/tmux/releases/tag/\K[^\"]*' | head -1)"
	elif hash wget 2>/dev/null; then
		local version="$(wget -qO- https://github.com/tmux/tmux/releases/latest | grep -Po '/tmux/tmux/releases/tag/\K[^\"]*' | head -1)"
	else
		errcho "Err: Neither curl nor wget are installed. Please install one of them before continuing"
		return 127
	fi
	[ -z "$version" ] && version="2.3"

	cwd="$(pwd)"
	cd "$tempdir"
	git clone https://github.com/tmux/tmux.git
	[ $? != 0 ] && { errcho "Err: Couldnt clone git repository for tmux"; return 4; }

	cd tmux
	if [ -f autogen.sh ]; then 
		pdebug "Found autogen"
		chmod +x autogen.sh
		./autogen.sh
		local ret=$?
		[ $ret != 0 ] && { pdebug "Error running autogen. Returned: $ret"; _exitgitinstall; return 2; }
	else
		errcho "Err: No autogen found. Could not build tmux"
	fi

	if [ -f configure ]; then
		pdebug "Found configure"

		# Modify the version number so tmux -V doesn't report "tmux master"
		sed -ir "s/VERSION='.*'/VERSION='$version'/g" configure
		chmod +x configure
		./configure
		if [ $? != 0 ]; then
			errcho "Err: Couldn't satisfy dependencies for tmux."
			{ _exitgitinstall && return 2; }
		else
			pdebug "Configure ran ok"
		fi
	fi

	if [ -f Makefile ] || [ -f makefile ]; then
		pdebug "Found makefile"
		make
		if [ $? != 0 ]; then
			errcho "Err: Couldn't build sources for tmux"
			{ _exitgitinstall && return 2; }
		else
			pdebug "Make ran ok"
			sudo make install
			if [ $? != 0 ]; then
				errcho "Err: Couldn't install tmux"
				{ _exitgitinstall && return 2; }
			else
				pdebug "Make install ran ok. Exiting installation."
				{ _exitgitinstall && return 0; }
			fi
		fi
	else
		errcho "Err: No makefile found. Couldn't build tmux"
		{ _exitgitinstall && return 2; }
	fi
}


# Pretty self explainatory. Installs a package through pip (default), searches for it (-s), or
# checks if it's installed already (-q)
#
# Return codes
# 0 - Successful installation / Package found
# 1 - Package not found in pip
# 2 - Pip error
# 3 - Can't install pip

pipinstall() {
	local search=false
	local query=false
	if [ "$1" = "-s" ]; then
		search=true
		shift
	elif [ "$1" = "-q" ]; then
		query=true
		shift
	fi
	if ! hash pip 2>/dev/null; then
		install -ng pip python-pip
		local ret=$?
		if [ $ret != 0 ]; then
			pdebug "Installation of pip returned $ret. Exiting pipinstall with 3"
			return 3
		fi
	fi

	local first=$1
	while [ $# -gt 0 ]; do 
		if $query; then
			if [ "$(pip freeze | grep "$1=")" ]; then
				return 0
			else
				return 1
			fi
		else
			if ! [ "$(pip search $1 | grep "^$1 ")" ]; then
				pdebug "$1 not found in pip repos"
				shift
			else
				if $search; then
					return 0
				else
					sudo pip install $1
					if [ $? = 0 ]; then
						return 0
					else
						return 2
					fi
				fi
			fi
		fi
	done

	errcho "Err: Package $first not found in python-pip's repos"
}

# Pretty self explainatory. Clones the git repo, and then builds and installs the program.
# Accepts -f as an argument to ignore $gitversion global option and install the program anyway
#
# This function is called automatically by the install function when needed. It is not intended to be called directly
#
#Return codes
# 0 - Successful installation
# 1 - Build error
# 2 - Git repo not found
# 3 - Git error
# 4 - Don't ask questions and fall back to the repo version
# 5 - Skip installation of this program completely
# 127 - Fatal error. Quit this script
gitinstall(){
	_exitgitinstall(){
		cd "$cwd"
	}

	if [ -n "$1" ] && [ "$1" = "-f" ]; then
		shift
	fi

	if ! hash git 2>/dev/null; then
		install -ng git
		[ $? = 0 ] || { _exitgitinstall && return 3; }
	fi

	local first="$1"
	local repotemplate="https://github.com/"
	while [ $# -gt 0 ]; do
		local repo="$repotemplate"
		pdebug "gitinstall processing $1"
		case "$1" in
			tmux)
				gitinstall_tmux
				return $?;;
			vim)
				install -y -ng libevent-dev libevent
				install -y -ng libncurses-dev libncurses.-dev ncurses-devel ncurses-devel.*
				repo+="vim/vim.git";;
			neovim)
				install -y -ng libtool-bin libtool
				install -y -ng m4 gnum4 gm4
				install -y -ng automake
				install -y -ng autoconf
				install -y -ng unzip
				makeopts+="CMAKE_BUILD_TYPE=RelWithDebInfo"
				repo+="neovim/neovim.git";;
			cmus)
				install -y -ng libncurses-dev libncurses.-dev ncurses-devel ncurses-devel.*
				repo+="cmus/cmus.git";;
			emacs)
				install -y -ng libgtk2.0-dev 'libgtk.*-dev'
				install -y -ng libxpm-dev libxpm
				install -y -ng libjpeg-dev libjpeg
				install -y -ng libgif-dev libgif giflib
				install -y -ng libtiff-dev libtiff
				install -y -ng libgnutls-dev libgnutls28-dev libgnutls.*-dev
				install -y -ng libncurses-dev libncurses.-dev ncurses-devel
				install -y -ng makeinfo texinfo
				repo="-b master git://git.sv.gnu.org/emacs.git";;
			playerctl)
				install -y -ng gtk-doc gtk-doc-tools gtkdocize
				install -y -ng gobject-introspection
				repo+="acrisci/playerctl.git";;
			lemonbar)
				install -y -ng libxcb1-dev libxcb*-dev libxcb-dev
				install -y -ng libxcb-randr0-dev libxcb-randr*-dev libxcb-randr-dev
				install -y -ng libxcb-xinerama0-dev libxcb-xinerama*-dev libxcb-xinerama-dev
				repo+="LemonBoy/bar.git";;
			# conky)
			# 	install -y -ng libiw-dev
			# 	install -y -ng libpulse-dev libpulse
			# 	install -y -ng libncurses-dev libncurses.-dev ncurses-devel
			# 	install -y -ng wireless_tools
			# 	cmakeopts="-D BUILD_WLAN=ON -D BUILD_PULSEAUDIO=ON -D BUILD_CMUS=ON"
			# 	repo="https://github.com/brndnmtthws/conky.git";;
			ctags|fonts-powerline|python-pip|conky)
				{ _exitgitinstall && return 4; };;
			*)
				repo+="$1/$1.git"
				git ls-remote "$repo" >/dev/null 2>&1
				if [ $? != 0 ] ; then 
					if [ $# = 0 ]; then
						errcho "Err: Could not find git repository for $first"
						{ _exitgitinstall && return 2; }
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
		cd "$tempdir" 
		pdebug "Cloning $repo"
		if ! git clone $repo; then
			errcho "Err: Error cloning the git repository"
			read -n1
			printf '\n'
			{ _exitgitinstall && return 3; }
		fi

		#Get the name of the directory we just cloned
		local cloneddir="${repo##*/}" #Get the substring from the last occurrence of / (the *.git part)
		cloneddir="${cloneddir%%.*}"  #Remove the .git to get only the name
		cd "$cloneddir"

		if [ -f setup.py ]; then
			install -y -ng setuptools python-setuptools python2-setuptools
			sudo python setup.py install
			if [ $? = 0 ]; then
				pdebug "Setup.py ran ok"
				{ _exitgitinstall && return 0; }
			else
				errcho "Err: Error building and installing $1"
				{ _exitgitinstall && return 1; }
			fi
		fi
		if [ -f autogen.sh ]; then 
			pdebug "Found autogen"
			install -y -ng automake
			if [ $? -gt 0 ]; then 
				errcho "Err: Could not install package automake necessary for compilation"
				{ _exitgitinstall && return 1; }
			else
				pdebug "Running autogen"
				chmod +x autogen.sh
				./autogen.sh
				local ret=$?
				[ $ret != 0 ] && { pdebug "Error running autogen. Returned: $ret"; _exitgitinstall; return 1; }
			fi
		elif [ -f configure.ac ] || [ -f configure.in ]; then
			pdebug "Found configure.ac or configure.in"
			install -y -ng automake
			if [ $? -gt 0 ]; then 
				errcho "Err: Could not install package automake necessary for compilation"
				{ _exitgitinstall && return 1; }
			else
				autoreconf -fi
				[ $? != 0 ] && { _exitgitinstall; return 1; }
			fi
		elif [ -f CMakeLists.txt ] || [ -d cmake ]; then
			install -y -ng cmake
			if [ $? -gt 0 ]; then 
				errcho "Err: Could not install package cmake necessary for compilation"
				{ _exitgitinstall && return 1; }
			else
				if [ ! -f Makefile ]; then
					mkdir build
					cd build
					cmake $cmakeopts .. 2>/dev/null
				fi
			fi
		fi

		if [ -f configure ]; then
			pdebug "Found configure"
			chmod +x configure
			./configure $configureopts
			if [ $? != 0 ]; then
				errcho "Err: Couldn't satisfy dependencies for $1."
				{ _exitgitinstall && return 1; }
			else
				pdebug "Configure ran ok"
			fi
		fi
		if [ -f Makefile ] || [ -f makefile ]; then
			pdebug "Found makefile"
			make $makeopts
			if [ $? != 0 ]; then
				errcho "Err: Couldn't build sources for $1"
				{ _exitgitinstall && return 1; }
			else
				pdebug "Make ran ok"
				sudo make install
				if [ $? != 0 ]; then
					errcho "Err: Couldn't install $1"
					{ _exitgitinstall && return 1; }
				else
					pdebug "Make install ran ok. Exiting installation."
					{ _exitgitinstall && return 0; }
				fi
			fi
		else
			errcho "Err: No makefile found. Couldn't build $1"
			{ _exitgitinstall && return 1; }
		fi
		{ _exitgitinstall && return 0; }
	done
	errcho "Err: Could not build this project"
	pdebug "Got to the end and project is not built. Returning 2"
	{ _exitgitinstall && return 2; }
}

#Check package managers and install program $1 if it's not installed. The rest of the 
#arguments are other possible names for this program

#Return codes
# 0 - Installation succesful (or program is installed already)
# 1 - User declined installation
# 2 - Program not installed and there's no internet connection
# 3 - Program not installed and there's no root access available
# 4 - Package not found
# 5 - Package manager error
# 6 - Pip error
# 127 - Fatal error. Quit this script
install() {
	pdebug "Whattup installing $*"
	local auto=$assumeyes
	local ignoregit=false
	local pip=false
	while [ ${1:0:1} = "-" ]; do
		if [ "$1" = "-y" ]; then
		   	auto=true
			pdebug "Yo. -y. Installing in auto mode"
			shift
		fi
		if [ "$1" = "-ng" ]; then
		   	ignoregit=true
			pdebug "Yo. -ng. Ignoring git"
			shift
		fi
		if [ "$1" = "-pip" ]; then
			pip=true
			pdebug "Yo. -pip. Installing with pip"
			shift
		fi
	done

	local installcmd=""
	for name in "$@"; do #Check if the program is installed under any of the names provided
		if hash "$name" 2>/dev/null; then
			pdebug "This is installed already"
		else
			pdebug "No hashing detected for $name"
		fi

		if $pip; then
			pipinstall -q "$name"
			local ret=$?
		else
			 [ -n "$(pacapt -Qs "^$name$")" ]
			 local ret=$?
		fi

		if [ $ret = 0 ]; then
			pdebug "This is installed already"
			return 0
		elif [ $ret = 127 ]; then
			# Exit the script completely
			quit 127
		else
			if $skipinstall; then
				pdebug "skipinstall is true. Exiting installation 1"
				return 1
			elif ! $internet ;then
				pdebug "No interent connection. Exiting installation 2"
				return 2
			elif ! $rootaccess; then
				pdebug "No root access. Exiting installation 3."
				return 3
			fi
		fi
	done


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
			prompt="$1 is not installed. Do you want to install it? (Y/n): "
		elif $gitversion; then
			prompt="$1 is already installed. Do you want to install the git version instead? (Y/n): "
		else
			prompt=""
		fi

		# If there are no options or the user answered "n", exit installation
		#Not using -n so it returns 1 on error
		[ "$prompt" ] && askyn "$prompt"
		if [ $? = 1 ]; then
			pdebug "User declined. Exiting installation 1."
			return 1
		fi
	fi
	
	if $pip; then
		pdebug "Pip version is true. Pipinstalling..."	
		pipinstall $*
		case $? in
			0) pdebug "Pipinstalled correctly. Exiting installation"
				return 0;;
			1) pdebug "Package not found in pip. Exiting 4"
				return 4;;
			2) pdebug "Pip error. Exiting 6"
				return 6;;
			3) pdebug "Cant install pip. Exiting 127"
				return 127;;
		esac
	fi

	#Clone and install using git if we need to
	if $gitversion && ! $ignoregit && ! $(echo "$1" | grep -w "git" >/dev/null); then
		pdebug "Git version is true. Gitinstalling..."
		while true; do
			gitinstall $*
			local ret=$?
			if [ $ret = 127 ]; then
				return 127
			elif [ $ret = 5 ]; then #Return code 5 means we should skip this package completely
				return 1
			elif [ $ret = 4 ]; then #Return code 4 means fall back to the repo version
				break
			elif [ $ret -gt 0 ]; then #An error has ocurred
				askyn "Installation through git failed. Do you want to fall back to the repository version of $1? (Y/n): "
				if [ $? = 0 ]; then
					echo "Installing the standard repository version"
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

	local args=$*
	while [ $# -gt 0 ]; do
		if ! $updated; then
			pacapt sudo -Sy
			updated=true
		fi
		if [ -n "$(pacapt -Ss "^$1$")" ]; then #Give it a regex so it only matches packages with exactly that name
			pdebug "Found it!. It's called $1 here"
			pacapt sudo -S --noconfirm $1
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

	# Package not found in the repos. Let's see if git has it
	if ! $gitversion && ! $ignoregit; then
		gitinstall $args && return 0
	fi

	echo "Package $* not found"
	pdebug "Package $* not found"

	return 4
}

uninstall() {
	pacapt sudo -Rn --noconfirm $1
}

deploybash(){
	if ! $skipinstall; then
		install -ng bash 
		local ret=$?
		[ $ret = 0 ] || return $ret
	fi
	dumptohome bash
}

deployvim(){
	if ! $skipinstall; then
		install vim
		local ret=$?
		[ $ret = 0 ] || return $ret
	fi

	dumptohome vim

	if ! $novimplugins; then
		if [ -f "$thisdir/vim/pathogen.sh" ]; then
			if install -ng git; then
				pdebug "Running pathogen script"
				if ! source "$thisdir/vim/pathogen.sh"; then
					errcho "W: Ran into an error while installing vim plugins"
					return 1
				else
					return 0
				fi
			fi
		else
			errcho "W: Could not find vim/pathogen.sh. Vim plugins will not be installed"
		fi
	fi
}

deploypowerline(){
	install -pip powerline-status 
	[ $? != 0 ] && return $ret
	
	install -y -ng python-dev
	install -pip powerline-mem-segment
	[ $? != 0 ] && errcho "W: Could not install powerline-mem-segment. Expect an error from tmux"
	

	if ! $skipinstall; then
		install -y "fonts-powerline" "powerline-fonts"
		if [ $? != 0 ]; then
			errcho "W: Could not install patched fonts for powerline. Prompt may look glitched"
		else
			echo "Powerline installed successfully. You may need to reset your terminal or log out to see the changes"
		fi
	fi

	cp -r "$thisdir/powerline" "$config"
}

deploytmux(){
	if ! $skipinstall; then
		install tmux 
		local ret=$?
		[ $ret = 0 ] || return $ret
	fi

	dumptohome tmux 
}

deploynano(){
	if ! $skipinstall; then
		install -ng nano 
		local ret=$?
		[ $ret = 0 ] || return $ret
	fi
	dumptohome nano
}

deployranger(){
	if ! $skipinstall; then
		install ranger
		local ret=$?

		[ $ret = 0 ] || return $ret
	fi

	cp -r "$thisdir/ranger" "$config"
}

deployctags(){
	if ! $skipinstall; then
		install ctags
		local ret=$?
		[ $ret = 0 ] || return $ret
	fi

	dumptohome ctags
}

deploycmus(){
	if ! $skipinstall; then
		install cmus
		local ret=$?
		[ $ret = 0 ] || return $ret
	fi

	[ ! -d "$config/cmus" ] && mkdir -p "$config/cmus"
	cp "$thisdir/cmus/"* "$config/cmus/"
}

deployemacs(){
	if ! $skipinstall; then
		install emacs 
		local ret=$?
		[ $ret = 0 ] || return $ret
	fi

	[ ! -d "$HOME/.emacs.d" ] && mkdir -p "$HOME/.emacs.d"
	dumptohome emacs
}

deployX(){
	dumptohome X
	[ ! -f "$HOME/.xinitrc" ] && ln -s "$HOME/.xprofile" "$HOME/.xinitrc"
	[ -f "$HOME/.Xresources" ] && xrdb "$HOME/.Xresources"
}

deployi3(){
	if ! $skipinstall; then
		install -ng i3 i3wm i3-wm
		local ret=$?
		[ $ret = 0 ] || return $ret

		install -ng i3status i3-status
		local ret=$?
		if [ $ret != 0 ]; then
			uninstall i3 i3wm i3-wm
			return $ret
		fi

		install -y -ng dmenu i3-dmenu i3dmenu dmenu-i3 suckless-tools suckless_tools
		local ret=$?
		if [ $ret != 0 ]; then
			uninstall i3 i3wm i3-wm
			uninstall i3status i3-status	
			return $ret
		fi

		install -y -ng i3lock-fancy i3lock i3-lock
		local ret=$?
		if [ $ret != 0 ]; then
			errcho "W: Could not install i3lock"
		fi 
	fi

	[ ! -d "$config/i3" ] && mkdir -p "$config/i3"
	[ ! -d "$config/i3status" ] && mkdir -p "$config/i3status"

	cp "$thisdir/i3/config" "$config/i3"

	local localversion="$(i3status --version | awk '{print $2}')"
	compare_versions $localversion 2.0
	if [ $? = 2 ]; then
		errcho "W: i3status version too old. Configuration will not be copied"
	else
		local conffile version ret prev
		local versions
		for conffile in $thisdir/i3/i3status*.conf; do
			conffile="$(basename $conffile)"
			version=${conffile#i3status}
			version=${version%.conf}
			versions+="$version\n"
		done
		if [ -z "$(sort --help | grep '\-V')" ]; then
			# This is just for compatibility. It just works for very simple cases (like the ones we have), but
			# ideally, the system will have a proper version of sort with the -V option
			versions="$(printf  "$versions" | sort -r -k1.4)"
		else
			versions="$(printf "$versions" | sort -r -V)"
		fi

		# Copy the newest conf file available
		for version in $versions; do
			compare_versions $localversion $version
			if [ $? = 3 ]; then
				cp "$thisdir/i3/i3status$version.conf" "$config/i3status/i3status.conf"
				break
			fi
		done
	fi
	pdebug "Copied i3 conf files"

	## That's it for the config files, here's where the fun begins
	# Needed for playback controls
	$skipinstall || install -y playerctl

	# Fonts
	if ! $internet; then
		if ! fc-list | grep -Ei "source.?code.?pro" >/dev/null 2>&1; then
			errcho "W: Source code pro is not installed."
		fi
		if ! fc-list | grep -Ei "font.?awesome" >/dev/null 2>&1; then
			errcho "W: Font awesome is not installed. i3status bar may appear glitched"
		fi
	else
		installfont Font-Awesome        --branch master https://github.com/FortAwesome/Font-Awesome.git
		installfont source-code-pro 	--depth 1 --branch release https://github.com/adobe-fonts/source-code-pro.git 

		cp -R "$thisdir/.fonts/misc" "$HOME/.fonts"
		cp -r "$thisdir/.fonts/terminesspowerline" "$HOME/.fonts"

		echo "Rebuilding font cache..."
		pdebug "Rebuilding font cache..."
		fc-cache -f 
	fi

	# We'll want to use urxvt
	if ! $skipinstall; then
		pdebug "Installing urxvt"
		install -ng urxvt rxvt-unicode-256 rxvt-unicode-256color rxvt-unicode
		local ret=$?
		if [ $ret = 0 ]; then
			cp "$thisdir/X/.Xresources" "$HOME"
			xrdb -merge "$HOME/.Xresources"
		else
			pdebug "Error installing urxvt. Returned $ret"
		fi
	fi
}

deploylemonbar() {
	# First install some stuff 
	if ! python -c "import i3"  2>/dev/null && ! $skipinstall; then
		install -pip i3-py
		local ret=$?
		[ $ret = 0 ] || { pdebug "Installing lemonbar. Could not install i3-py"; return $ret; }
	fi

	install -ng conky

	local ret=$?
	[ $ret = 0 ] || { pdebug "Installing lemonbar. Could not install conky"; return $ret; }

	# This is necessary to avoid build errors on ArchLinux
	if ! hash pod2man 2>/dev/null; then
		export PATH="$PATH:/usr/bin/core_perl"
	fi

	install lemonbar
	local ret=$?
	[ $ret = 0 ] || { pdebug "Installing lemonbar. Could not install lemonbar"; return $ret; }


	# Install necessary fonts
	install -y -ng xorg-xlsfonts
	[ $? != 0 ] && errcho "W: Could not install xorg-xlsfonts. Lemonbar may look glitched"

	installfont terminesspowerline
	installfont misc

	echo "Rebuilding font cache..."
	pdebug "Rebuilding font cache..."
	fc-cache -f 

	cp -R "$thisdir/lemonbar" "$config"
}

deployneovim(){
	install neovim
	local ret=$?
	[ $ret = 0 ] || return $ret

	[ ! -d "$config/nvim" ] && mkdir "$config/nvim"
	cp "$thisdir"/neovim/*.vim "$config/nvim"

	# If we're going to install vim, we'll symlink the config directories. Otherwise, we run the
	# pathogen script and download all the plugins directly into the nvim config directory
	if [ -z "${dotfiles##*vim*}" ]; then
		for folder in "$thisdir"/vim/.vim/*; do
			if [ -d "$folder" ]; then
				if [ ! -d "$config/nvim/$folder" ]; then
					ln -s "$HOME/.vim/$(basename $folder)" "$config/nvim/"
				else
					if [ -d "$config/nvim/$folder" ]; then
						[ -d "$HOME/.vim/$folder" ] && cp -R "$HOME/.vim/$folder" "$config/nvim/$folder"
					fi
				fi
			fi
		done
	else
		if ! $novimplugins; then
			if [ -f "$thisdir/vim/pathogen.sh" ]; then
				if install -ng git; then
					pdebug "Running pathogen script for neovim"
					if ! "$thisdir"/vim/pathogen.sh neovim; then
						errcho "W: Ran into an error while installing neovim plugins"
						return 1
					else
						return 0
					fi
				fi
			else
				errcho "W: Could not find vim/pathogen.sh. Neovim plugins won't be installed"
			fi
		fi
	fi
}

deployall(){
	pdebug "Deploy all"
	for dotfile in $install; do
		pdebug "${highlight}Installing $dotfile${reset}"
		( deploy$dotfile )
		local ret=$?
		pdebug "${highlight}Deploy$dotfile returned: $ret${reset}"
		#Return codes
		# 0 - Installation succesful (or program is installed already)
		# 1 - User declined installation
		# 2 - Program not installed and there's no internet connection
		# 3 - Program not installed and there's no root access available
		# 4 - Package not found
		# 5 - Package manager error
		# 127 - Fatal error. Quit this script
		case $ret in 
			0) pdebug "Deploy$dotfile finished with no errors";;
			1) true;; #User declined installation, but an error message has been shown already
			2) errcho "$dotfile not installed and there's no internet connection";;
			3) errcho "$dotfile not installed and there's no root access";;
			4) errcho "Err: Package $dotfile not found";;
			5) 
				errcho "Err: There was an error using your package manager. You may want to quit the script now and fix it manually before coming back"
				printf '\n'
				echo "Press any key to continue"
				pdebug "Press any key to continue"
				read -n1
				printf '\n';;
			127)
				errcho "Fatal error. Exiting script"
				quit 127;;
		esac

		if $debug; then
			$assumeyes || read -n1 -p "Press any key to continue..."
			printf '\n'
		fi
	done
}

#Copies every dotfile from $1 to $HOME
dumptohome(){
	pdebug "Dumping $1 to home"
	for file in "$thisdir/$1"/.[!.]*; do
		if [ -e "$file" ] && [ "${file##*.}" != ".swp" ]; then
			cp -R "$file" "$HOME"
		else
			pdebug "W: File $file does not exist"
		fi
	done
}


####### FUNCTIONS DECLARATION ################

####### MAIN LOGIC ###########################

pdebug "HELLO WORLD"
pdebug "Temp dir: $tempdir"

trap "printf '\nAborted\n'; quit 127"  1 2 3 20

if [ -z "$BASH_VERSION"  ]; then
	echo "W: This script was written using bash with portability in mind. However, compatibility with other shells hasn't been tested yet. Bear
	that in mind and run it at your own risk.

	Press any key to continue"

	read -n1
fi

#Deploy and reload everything
if [ $# = 0 ]; then
	install="$dotfiles"
	deployall
else
	pdebug "Args: [$*]"
	install="$dotfiles"
	while [ $# -gt 0 ] &&  [ ${1:0:1} = "-" ]; do 
		pdebug "Parsing arg $1"
		case $1 in
			-g|--git|--git-version)  gitversion=true;;
			-i|--no-install) 		 skipinstall=true;;
			-n|--no-root)            rootaccess=false;;
			-o|--offline)            internet=false;;
			--override) 			 gitoverride=true; gitversion=true;;
			-p|--no-plugins)         novimplugins=true;;
			-y|--assume-yes)         assumeyes=true;;
			-d|--debug) 			 debug=true;;
			-h|--help)               
				echo "
				Install the necessary dotfiles for the specified programs. These will be installed
				automatically when trying to deploy their corresponding dotfiles.
				"
				help
				quit;;
			-x|--exclude)
				shift
				pdebug "Exclude got args: $*"
				while [ $# -gt 0 ] && [ ${1:0:1} != "-" ]; do
					#Check if the argument is present in the array
					found=false
					for dotfile in $dotfiles; do
						if [ "$1" = "$dotfile" ]; then
							install="$(echo $install | sed -r "s/ ?$1 ?/ /g")" #Remove the word $1 from $install
							found=true
							pdebug "Excluding $1. Install: $install"
						fi
					done
					$found || errcho "Program $1 not recognized. Skipping..."
					shift
				done;;
			*) errcho   "Err: Argument '$1' not recognized"; help; quit 1;;
		esac
		shift
	done
	pdebug "Done parsing dash options. State:
	gitversion = $gitversion
	skipinstall = $skipinstall
	rootaccess = $rootaccess
	internet = $internet
	gitoverride = $gitoverride
	novimplugins = $novimplugins
	assumeyes = $assumeyes
	debug = $debug

	Now parsing commands ($# left)"
	if [ $# = 0 ]; then
		pdebug "No commands to parse. Installing all dotfiles"
	else # A list of programs has been specified. Will install only those, so we'll first clear the installation list
		install=""
		while [ $# -gt 0 ]; do 	
			pdebug "Parsing command $1"
			# Check if the argument is not in our list. (Actually checking if it's a substring in a portable way)
			if [ -z "${dotfiles##*$1*}" ]; then
				if [ -z "$install" ] || [ -n "${install##*$1*}" ]; then
					install+="$1 "
					pdebug "Will install $1"
					#else skip it because it's already in the install list
				else 
					pdebug "Skip $1 because it's already in the install list. Install: $install"
				fi
			else
				errcho "Err: Program '$1' not recognized. Skipping."
			fi		    
			shift
		done
	fi
	pdebug "Done parsing commands"
	pdebug "Deploying: $install"
	deployall
fi

quit
