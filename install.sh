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
thisfile="$(basename $0)"
thisdir="$(dirname $(readlink -f $0))"
tempdir="$(mktemp -d)"

updated=false
assumeyes=false
rootaccess=true
internet=true
gitversion=false
novimplugins=false
skipinstall=false
gitoverride=false
debug=false

if [ -n "$XDG_CONFIG_HOME" ]; then 
	config="$XDG_CONFIG_HOME"
else
	config="$HOME/.config"
fi
[ ! -d $config ] && mkdir -p "$config"

# A poor emulation of arrays for pure compatibility with other shells
dotfiles="bash cmus ctags emacs i3 nano powerline ranger tmux vim X"
install="" #Dotfiles to install. This will change over the course of the program

####### VARIABLE INITIALIZATION ##############

####### MISC FUNCTIONS DECLARATION ###########
errcho() {
	>&2 echo "$*"
	pdebug "$*"
}

pdebug(){
	if $debug; then
		#[ ! -p "$thisdir/output" ] && mkfifo "$thisdir/output"
		echo "$*" >> "$thisdir/output"
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
	[ -d "$tempdir" ] && rm -rf "$tempdir"

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
installfont (){
	local fonts="$HOME/.fonts"
	[ -d $fonts ] ||  mkdir "$fonts"
	local path="$fonts/$1"
	local cwd="$(pwd)"
	cd "$fonts"

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
}

pacapt(){
	# We'll use the awesome pacapt script from https://github.com/icy/pacapt/tree/ng to install packages on any distro (even OSX!)
	if [ ! -f "$tempdir/pacapt" ]; then
		echo "Detecting distro's package manager..."
		pdebug "Downloading pacapt and stuff"

		local ret
		if hash curl 2>/dev/null; then
			curl -sL https://github.com/icy/pacapt/raw/ng/pacapt -o "$tempdir/pacapt"
			ret=$?
		elif hash wget 2>/dev/null; then
			wget -qO "$tempdir/pacapt" https://github.com/icy/pacapt/raw/ng/pacapt 
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

	local version="$(curl -sL https://github.com/tmux/tmux/releases/latest  | grep -Po '/tmux/tmux/releases/tag/\K[^\"]*')"

	git clone https://github.com/tmux/tmux.git
	sed -ir "s/VERSION='.*'/VERSION='$version'/g" configure
	./configure
	make
	sudo make install	
}

# Pretty self explainatory. Clones the git repo, and then builds and installs the program.
# Accepts -f as an argument to ignore $gitversion global option and install the program anyway
#
# This function is called automatically by the install function when needed. It is not intended to be called directly
#
#Return codes
# 0 - Successful installation
# 1 - $gitversion is not even true
# 2 - Build error
# 3 - Git repo not found
# 4 - Git error
# 5 - Don't ask questions and fall back to the repo version
# 6 - Skip installation of this program completely
gitinstall(){
	_exitgitinstall(){
		cd "$cwd"
	}

	if [ -n "$1" ] && [ "$1" = "-f" ]; then
		shift
	else
		$gitversion || { _exitgitinstall && return 1; }
	fi

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
			tmux)
				gitinstall_tmux
				return $?;;
			vim)
				repo+=vim/vim.git
				install -y -ng libevent-dev libevent
				install -y -ng libncurses-dev libncurses.-dev ncurses-devel ncurses-devel.*;;
			cmus)
				repo+=cmus/cmus.git
				install -y -ng libncurses-dev libncurses.-dev ncurses-devel ncurses-devel.*;;
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
				repo="https://github.com/acrisci/playerctl.git";;
			ctags|psutils|fonts-powerline|\
				python-pip)
				{ _exitgitinstall && return 5; };;
			*)
				repo+="$1/$1.git"
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
		cd "$tempdir" 
		pdebug "Cloning $repo"
		if ! git clone $repo; then
			errcho "Err: Error cloning the git repository"
			read -n1
			printf '\n'
			{ _exitgitinstall && return 4; }
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
				{ _exitgitinstall && return 2; }
			fi
		fi
		if [ -f autogen.sh ]; then 
			pdebug "Found autogen"
			install -y -ng automake
			if [ $? -gt 0 ]; then 
				errcho "Err: Could not install package automake necessary for compilation"
				{ _exitgitinstall && return 2; }
			else
				pdebug "Running autogen"
				chmod +x autogen.sh
				./autogen.sh
				local ret=$?
				[ $ret != 0 ] && { pdebug "Error running autogen. Returned: $ret"; _exitgitinstall; return 2; }
			fi
		elif [ -f configure.ac ] || [ -f configure.in ]; then
			pdebug "Found configure.ac or configure.in"
			install -y -ng automake
			if [ $? -gt 0 ]; then 
				errcho "Err: Could not install package automake necessary for compilation"
				{ _exitgitinstall && return 2; }
			else
				autoreconf -fi
				[ $? != 0 ] && { _exitgitinstall; return 2; }
			fi
		fi

		if [ -f configure ]; then
			pdebug "Found configure"
			chmod +x configure
			./configure
			if [ $? != 0 ]; then
				errcho "Err: Couldn't satisfy dependencies for $1."
				{ _exitgitinstall && return 2; }
			else
				pdebug "Configure ran ok"
			fi
		fi
		if [ -f Makefile ] || [ -f makefile ]; then
			pdebug "Found makefile"
			make
			if [ $? != 0 ]; then
				errcho "Err: Couldn't build sources for $1"
				{ _exitgitinstall && return 2; }
			else
				pdebug "Make ran ok"
				sudo make install
				if [ $? != 0 ]; then
					errcho "Err: Couldn't install $1"
					{ _exitgitinstall && return 2; }
				else
					pdebug "Make install ran ok. Exiting installation."
					{ _exitgitinstall && return 0; }
				fi
			fi
		else
			errcho "Err: No makefile found. Couldn't build $1"
			{ _exitgitinstall && return 2; }
		fi
		{ _exitgitinstall && return 0; }
	done
	errcho "Err: Could not build this project"
	pdebug "Got to the end and project is not built. Returning 3"
	{ _exitgitinstall && return 3; }
}

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
	local auto=$assumeyes
	local ignoregit=false
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
	done

	local installcmd=""
	for name in "$@"; do #Check if the program is installed under any of the names provided
		pacapt -Qs "^$name$" >/dev/null
		local ret=$?
		if [ $ret = 0 ]; then
			if $gitversion && ! $ignoregit && $gitoverride; then
				pacapt sudo -Rn --noconfirm $name
			else
				pdebug "This is installed already"
				return 0
			fi
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

	#Clone and install using git if we need to
	if $gitversion && ! $ignoregit && ! $(echo "$1" | grep -w "git" >/dev/null); then
		pdebug "Git version is true. Gitinstalling..."
		while true; do
			gitinstall $*
			local ret=$?
			if [ $ret = 6 ]; then #Return code 6 means we should skip this package completely
				return 1
			elif [ $ret = 5 ]; then #Return code 5 means fall back to the repo version
				break
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
		gitinstall $* && return 0
	fi

	echo "Package $* not found"
	pdebug "Package $* not found"

	return 4
}


deploybash(){
	dumptohome bash
}

deployvim(){
	if ! $skipinstall; then
		install vim
		local ret=$?
		if [ $ret != 0 ]; then
			[ $ret -le 3 ] && return 1
			[ $ret -gt 3 ] && return 2
		fi
	fi

	dumptohome vim

	if ! $novimplugins; then
		if [ -f "$thisdir/vim/pathogen.sh" ]; then
			if install -ng git && install -y -ng wget; then
				pdebug "Running pathogen script"
				source "$thisdir/vim/pathogen.sh"
			fi
		else
			errcho "W:Could not find vim/pathogen.sh. Vim addons will not be installed"
		fi
	fi
}

deploypowerline(){
	if ! hash powerline 2>/dev/null && ! $skipinstall; then
		if ! $rootaccess || ! $internet; then
			return 1
		fi

		#Necessary for the mem-segment plugin expected in the configuration files
		if ! hash pip 2>/dev/null; then
			install -y -ng pip2 pip python2-pip python-pip
			local ret=$?
			if [ $ret != 0 ]; then
				[ $ret -le 3 ] && return 1
				[ $ret -gt 3 ] && return 2
			fi
		fi

		#Pip2 is preferred, this configuration has only been tested on python2.
		local pip="pip2"

		if ! hash pip2 2>/dev/null; then 
			pip="pip"
		fi

		sudo $pip install powerline-status
		local ret=$?
		if [ $ret != 0 ]; then
			[ $ret -le 3 ] && return 1
			[ $ret -gt 3 ] && return 2
		fi
	fi

	if ! $skipinstall && ! $pip freeze | grep powerline-mem-segment >/dev/null; then
		if $rootaccess && $internet && ! $skipinstall; then
			install -y -ng python-dev
			sudo $pip install powerline-mem-segment
			[ $? != 0 ] && errcho "W: Could not install powerline-mem-segment. Expect an error from tmux"
		fi
	fi
	

	if ! $skipinstall; then
		install -y "fonts-powerline" "powerline-fonts"
		if [ $? != 0 ]; then
			errcho "W: Could not install patched fonts for powerline. Prompt may look glitched"
		else
			echo "Powerline installed successfully. You may need to reset your terminal or log out to see the changes"
		fi
	fi

	cp -r "$thisdir/powerline" $config
}

deploytmux(){
	if ! $skipinstall; then
		install "tmux" 
		local ret=$?
		if [ $ret != 0 ]; then
			[ $ret -le 3 ] && return 1
			[ $ret -gt 3 ] && return 2
		fi
	fi

	dumptohome tmux 
}

deploynano(){
	dumptohome nano
}

deployranger(){
	if ! $skipinstall; then
		install ranger
		local ret=$?

		if [ $ret != 0 ]; then
			[ $ret -le 3 ] && return 1
			[ $ret -gt 3 ] && return 2
		fi
	fi

	cp -r "$thisdir/ranger" "$config"
}

deployctags(){
	if ! $skipinstall; then
		install ctags
		local ret=$?
		if [ $ret != 0 ]; then
			[ $ret -le 3 ] && return 1
			[ $ret -gt 3 ] && return 2
		fi
	fi

	dumptohome ctags
}

deploycmus(){
	if ! $skipinstall; then
		install cmus
		local ret=$?
		if [ $ret != 0 ]; then
			[ $ret -le 3 ] && return 1
			[ $ret -gt 3 ] && return 2
		fi
	fi

	[ ! -d "$config/cmus" ] && mkdir -p "$config/cmus"
	cp "$thisdir/cmus/"* "$config/cmus/"
}

deployemacs(){
	if ! $skipinstall; then
		install emacs 
		local ret=$?
		if [ $ret != 0 ]; then
			[ $ret -le 3 ] && return 1
			[ $ret -gt 3 ] && return 2
		fi
	fi

	[ ! -d "$HOME/.emacs.d" ] && mkdir -p "$HOME/.emacs.d"
	dumptohome emacs
}

deployX(){
	dumptohome X
	[ -f "$HOME/.Xresources" ] && xrdb "$HOME/.Xresources"
}

deployi3(){
	if ! $skipinstall; then
		install -ng i3 i3wm i3-wm
		local ret=$?
		if [ $ret != 0 ]; then
			[ $ret -le 3 ] && return 1
			[ $ret -gt 3 ] && return 2
		fi 

		install -ng i3status i3-status
		local ret=$?
		if [ $ret != 0 ]; then
			[ $ret -le 3 ] && return 1
			[ $ret -gt 3 ] && return 2
		fi 

		install -y -ng dmenu i3-dmenu i3dmenu dmenu-i3 suckless-tools suckless_tools
		local ret=$?
		if [ $ret != 0 ]; then
			[ $ret -le 3 ] && return 1
			[ $ret -gt 3 ] && return 2
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
				cp "$thisdir/i3/i3status$version.conf" "$HOME/.config/i3status/i3status.conf"
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

	#Lemonbar configuration will go here
}

deployall(){
	pdebug "Deploy all"
	for dotfile in $install; do
		pdebug "Installing \[\033[0;31m\]$dotfile\[\033[0m\]"
		( deploy$dotfile )
		local ret=$?
		pdebug "Deploy$dotfile returned: $ret"
		if [ $ret = 127 ]; then
			quit 127
		elif [ $ret = 2 ]; then
			errcho "Err: There was an error using your package manager. You may want to quit the script now and fix it manually before coming back
			
			Press any key to continue"
			read -n1
			printf '\n'
		elif [ $ret = 1 ]; then
			true #User declined installation, but an error message has been shown already
		elif [ $ret != 0 ]; then
			errcho "Err: There was an error installing $dotfile"
		else
			pdebug "Deploy$dotfile finished with no errors"
		fi

		if $debug; then
			$assumeyes || read -n1 -p "Press any key to continue..."
			printf '\n'
		fi
	done
}

#Copies every dotfile (no folders) from $1 to $HOME
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
			# Check if the argument is in our list. Actually checking if it's a substring in a portable way. Cool huh?
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
