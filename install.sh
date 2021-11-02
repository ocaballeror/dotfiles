#!/bin/bash

# TEST i3, lemonbar and X working together on all distros (Only Arch tested for now)
# TEST This script at least on Debian, Ubuntu, Fedora and Arch

# ADD An option to skip installing fonts
# ADD Minimize output. Add option for full output of external commands
# ADD Make ncmpcc check for mpd and install that first (I know it works as it is right now, since
#       the installation list is alphabetically sorted and ncmpcpp is always placed after mpd, but that's
#       a shitty way to do things. Make sure you properly check for this dependency)
# ADD an option to copy all the files without trying to install anything
# ADD Bundles(groups) of programs to the main script arguments to avoid having to type every name when you're
# deploying a commonly-used-together set of programs, say i3, urxvt and lemonbar

## To extend this script and add new programs:
# 1. Create a dir with the name of the program in the dotfiles directory
# 2. Add the name of the program to the dotfiles array a few lines below this comment
# 3. Create a function called "deploy<name-of-the-program>" that copies the required
#    files to their respective directories.
#
#    Tip: Use dumptohome "name-of-the-program" to copy everything in the folder to the home directory
# 4. If you don't want your program to be cloned and built manually with git, use the -ng flag for the install function
# 5. Done!



# VARIABLE INITIALIZATION {{{1
# Environment definition
thisfile="$(basename "$0")"
thisdir="$(dirname "$(readlink -f $0)")"
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
highlight=$(tput setaf 6)    # Set the color for highlighted debug messages
errhighlight=$(tput setaf 1) # Set the color for error debug messages
reset=$(tput sgr0)           # Get the original output color back

if [ -n "$XDG_CONFIG_HOME" ]; then
	config="$XDG_CONFIG_HOME"
else
	config="$HOME/.config"
fi
[ ! -d $config ] && mkdir -p "$config"

# A poor emulation of arrays for pure compatibility with other shells. This will stay constant.
dotfiles="ack bash cmus ctags emacs i3 jupyter git ptpython lemonbar mpd nano ncmpcpp powerline ranger tmux vim neovim X urxvt"
install="" # Dotfiles to install. This will change over the course of the program

# 1}}}

# FUNCTIONS DECLARATION {{{1
# MISC FUNCTIONS {{{2
errcho() {
	>&2 echo "${errhighlight}$*${reset}"
	pdebug "${errhighlight}$*${reset}"
}

pdebug(){
	if $debug; then
		#[ ! -p "$thisdir/output" ] && mkfifo "$thisdir/output"
		echo "$@" >> "$thisdir/output"
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
	if [ -f "$thisdir/output" ]; then
		[ ! -d "$HOME/Stuff/logs" ] && mkdir -p "$HOME/Stuff/logs"
		mv "$thisdir/output" "$HOME/Stuff/logs/$(date '+%d-%m-%y %T')"
	fi
	if [ -d "$tempdir" ]; then
		if ! rm -rf "$tempdir" >/dev/null 2>&1; then
			errcho "W: Temporary directory $tempdir could not be removed automatically. Delete it to free up space"
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
	-p|--no-plugins:  Don't install vim/neovim plugins
	-d|--debug: 	  Print debug information to an external file
	-y|--assume-yes:  Assume yes to all questions
	-x|--exclude:     Specify the programs which configurations will NOT be installed
	--override: 	  Override currently installed version of a program with the git one. (Implies -g).

TIP: Run this script again as root to install dotfiles for that user as well"
}

# Prompts the user a Y/N question specified in $1. Returns 0 on "y" and 1 on "n"
askyn(){
	pdebug "$*"
	$assumeyes && return 0
	local opt="default"
	while [ -n "$opt" ] && [ "$opt" != "y" ] && [ "$opt" != "Y" ] && [ "$opt" != "n" ] && [ "$opt" != "N" ]; do
		read -r -p "$1" -n1 opt
		printf "\\n"
	done

	if [ "$opt" = "n" ] || [ "$opt" = "N" ]; then
		return 1
	else # Will catch empty input too, since Y is the recommended option
		return 0
	fi
}
#2}}}

# INSTALLATION FUNCTIONS {{{2
# Pretty self explainatory. Creates a directory in ~/.fonts/$1 and clones the git repo $2 into it
# If no $2 is passed, it will try to find the font in the .fonts directory of this repo
installfont (){
	local fonts path cwd
	fonts="$HOME/.fonts"
	[ -d "$fonts" ] ||  mkdir "$fonts"
	path="$fonts/$1"
	cwd="$PWD"
	cd "$fonts"

	if [ $# -lt 2 ]; then
		[ -d "$thisdir/.fonts/$1" ] && cp  -r "$thisdir/.fonts/$1" .
	else
		if ! hash git 2>/dev/null || ! $internet; then
			if ! $internet; then
				if fc-list | grep -i "$1" >/dev/null; then
					return 0
				else
					echo "W: Font '$1' could not be installed"
					return 2
				fi
			else
				install -y -ng git
				if ! hash git 2>/dev/null; then
					echo "W: Font '$1' could not be installed"
					return 2;
				fi
			fi
		fi

		shift
		if ! [ -d "$path" ]; then
			git clone "$@"
		else
			if [ ! -d "$path/.git" ]; then
				rm -rf "$path"
				git clone "$@"
			else
				pushd . >/dev/null
				cd "$path"
				git pull
				popd >/dev/null
			fi
		fi

		# If we're not going to install X, at least append this to xprofile
		if [ -n "${install##*X*}" ]; then
			echo "xset fp+ $fonts" >> "$HOME/.xprofile"
		fi
	fi

	cd "$cwd"
}

download(){
	local ret
	if hash curl 2>/dev/null; then
		curl -skL "$1" -o "$2"
		ret=$?
	elif hash wget 2>/dev/null; then
		wget --no-check-certificate -qO "$2" "$1"
		ret=$?
	else
		echo "Err: Please install either curl or wget to continue"
		return 127
	fi
	if [ $ret != 0 ]; then
		errcho "Err: Could not connect to the internet. Make sure you are connected or use -o to run this script offline"
		return 127
	fi

	return 0
}

pacapt(){
	pdebug "Asking pacapt for $*"
	# We'll use the awesome pacapt script from https://github.com/icy/pacapt/tree/ng to install packages on any distro (even OSX!)
	if [ ! -f "$tempdir/pacapt" ]; then
		echo "Detecting distro's package manager..."
		pdebug "Downloading pacapt and stuff"
		download "https://github.com/icy/pacapt/raw/ng/pacapt" "$tempdir/pacapt" || return 127

		chmod +x "$tempdir/pacapt"
	fi

	local usesudo
	[ "$1" = "sudo" ] &&  { usesudo="sudo"; shift; }

	$usesudo "$tempdir/pacapt" "$@"

	return $?
}

# Used when deploying i3status. Compares two version numbers.
# Returns 0 if they are equal, 1 if the first one is bigger, 2 if the second one is bigger
# (Avoid having to call the function twice) Returns 3 if the first is bigger or equal, 4 if second is bigger or equal
# Return codes:
# 0 - Versions are equal
# 1 - $1 is bigger
# 2 - $2 is bigger
compare_versions()  {
	local v1 v2
	v1="$(echo "$1" | awk -F. '{ printf("%03d%03d%03d\n", $1,$2,$3); }')"
	v2="$(echo "$2" | awk -F. '{ printf("%03d%03d%03d\n", $1,$2,$3); }')"

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

# Ok, this is the shittiest code I've ever written, but here is a custom function to install tmux from git.
# It "parses" the github page of tmux to find the version number of the latest release, then injects it into
# the configure script, so when it's installed, tmux -V reports the latest version instead of "tmux master", which
# can be problematic for other programs  (i.e. powerline)
gitinstall_tmux() {
	install -y -ng libevent-dev libevent
	install -y -ng libncurses-dev libncurses.-dev ncurses-devel ncurses-devel.* ncurses
	install -y -ng pkg-config
	install -y -ng automake

	local version
	if hash curl 2>/dev/null; then
		version="$(curl -sL https://github.com/tmux/tmux/releases/latest  | grep -Po '/tmux/tmux/releases/tag/\K[^\"]*' | head -1)"
	elif hash wget 2>/dev/null; then
		version="$(wget -qO- https://github.com/tmux/tmux/releases/latest | grep -Po '/tmux/tmux/releases/tag/\K[^\"]*' | head -1)"
	else
		errcho "Err: Neither curl nor wget are installed. Please install one of them before continuing"
		return 127
	fi
	[ -z "$version" ] && version="2.3"

	cwd="$(pwd)"
	cd "$tempdir"
	if ! git clone https://github.com/tmux/tmux.git; then
		errcho "Err: Couldn't clone git repository for tmux"
		return 4
	fi

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
		if ! ./configure; then
			errcho "Err: Couldn't satisfy dependencies for tmux."
			{ _exitgitinstall && return 2; }
		else
			pdebug "Configure ran ok"
		fi
	fi

	if [ -f Makefile ] || [ -f makefile ]; then
		pdebug "Found makefile"
		if ! make; then
			errcho "Err: Couldn't build sources for tmux"
			{ _exitgitinstall && return 2; }
		else
			pdebug "Make ran ok"
			if ! sudo make "install"; then
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
			pip freeze | grep -q "$1"
			return
		else
			if pip search "$1" 2>/dev/null | grep -q "^$1"; then
				if $search; then
					return 0
				else
					if sudo pip "install" "$1"; then
						return 0
					else
						return 2
					fi
				fi
			else
				pdebug "$1 not found in pip repos"
				shift
			fi
		fi
	done

	errcho "Err: Package $first not found in python-pip's repos"
	return 1
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
	_exitgitinstall() {
		cd "$cwd"
	}

	if [ -n "$1" ] && [ "$1" = "-f" ]; then
		shift
	fi

	if ! hash git 2>/dev/null; then
		if ! install -ng git; then
			_exitgitinstall
			return 3;
		fi
	fi

	local first="$1"
	local repotemplate="https://github.com/"
	local cmakeopts configureopts gitopts makeopts
	makeopts="-j2 "
	while [ $# -gt 0 ]; do
		local repo="$repotemplate"
		pdebug "Gitinstall processing $1"
		case "$1" in
			tmux)
				gitinstall_tmux
				return $?;;
			vim)
				install -y -ng libevent-dev libevent
				install -y -ng libncurses-dev libncurses.-dev ncurses-devel ncurses-devel.* ncurses
				configureopts+="--prefix=/usr --with-features=huge --with-x=no --disable-gui --enable-pythoninterp=dynamic --enable-python3interp=dynamic "
				repo+="vim/vim.git";;
			neovim)
				install -y -ng g++ 'g\+\+' gcc-c++ 'gcc-c\+\+'
				# install -y -ng luarocks
				install -y -ng libtool-bin libtool
				install -y -ng automake
				install -y -ng make
				install -y -ng unzip
				install -y -ng gettext
				install -y -ng pkg-config pkgconfig
				makeopts=" CMAKE_BUILD_TYPE=RelWithDebInfo"
				repo+="neovim/neovim.git";;
			cmus)
				install -y -ng libncurses-dev libncurses.-dev ncurses-devel ncurses-devel.* ncurses
				install -y -ng libpulse-dev pulseaudio-libs-devel
				repo+="cmus/cmus.git";;
			emacs)
				install -y -ng libgtk2.0-dev 'libgtk.*-dev' gtk2-devel
				install -y -ng libxpm-dev libxpm libXpm-devel
				install -y -ng libjpeg-dev libjpeg-turbo-devel libjpeg
				install -y -ng libgif-dev libgif giflib-devel giflib
				install -y -ng libtiff-dev libtiff-devel libtiff
				install -y -ng libgnutls-dev libgnutls28-dev libgnutls.*-dev gnutls-dev gnutls
				install -y -ng libncurses-dev libncurses.-dev ncurses-devel ncurses
				install -y -ng makeinfo texinfo
				gitopts+=" -b master"
				repo="ssh://git.savannah.gnu.org:/srv/git/emacs.git";;
			playerctl)
				install -y -ng gtk-doc gtk-doc-tools gtkdocize
				install -y -ng gobject-introspection
				install -y -ng libgtk2.0-dev 'libgtk.*-dev'
				repo+="acrisci/playerctl.git";;
			lemonbar)
				install -y -ng make
				install -y -ng libxcb1-dev libxcb*-dev libxcb-dev libxcb-devel
				install -y -ng libxcb-randr0-dev libxcb-randr*-dev libxcb-randr-dev
				install -y -ng libxcb-xinerama0-dev libxcb-xinerama*-dev libxcb-xinerama-dev
				hash cc 2>/dev/null || sudo ln -s "$(which gcc)" /usr/bin/cc
				repo+="LemonBoy/bar.git";;
			mpd)
				install -y -ng g++ 'g\+\+' gcc-c++ 'gcc-c\+\+'
				install -y -ng libboost-dev boost-lib boost-libs boost-devel boost
				repo+="MusicPlayerDaemon/MPD.git";;
			ncmpcpp)
				install -y -ng g++ 'g\+\+' gcc-c++ 'gcc-c\+\+'
				install -y -ng libboost-dev boost-lib boost-libs boost-devel boost
				install -y -ng libtool-bin libtool
				repo+="arybczak/ncmpcpp.git";;
			ctags)
				repo+="b4n/ctags.git";;
			# i3)
			# 	Commented because, as of today, Debian 8 doesn't have the required
			#	libraries in its repos. There's no point in keeping this here when the
			# 	distro that would benefit the most from gitinstalling this can't even do it

			# 	install -y -ng libev-dev
			# 	install -y -ng libstartup-notification-dev libstartup-notification.-dev libstartup-notification0-dev
			# 	install -y -ng libxcb1-dev libxcb*-dev libxcb-dev libxcb-devel
			# 	install -y -ng libxcb-randr0-dev libxcb-randr*-dev libxcb-randr-dev
			# 	install -y -ng libxcb-xinerama0-dev libxcb-xinerama*-dev libxcb-xinerama-dev
			# 	install -y -ng libxcb-xkb-dev
			# 	install -y -ng libxcb-keysyms1-dev libxcb-keysyms.-dev
			# 	install -y -ng libxcb-icccm4-dev libxcb-icccm.-dev
			# 	install -y -ng libxcbcommon-dev
			# 	install -y -ng libxkbcommon-x11-dev
			# 	install -y -ng libyajl-dev
			# 	install -y -ng libcairo2-dev
			# 	install -y libxcb-xrm-dev
			# 	configureopts+=" --prefix=/usr --disable-builddir"
			# 	repo+="i3/i3.git";;
			# libxcb-xrm-dev)
			# 	install -y -ng xutils-dev
			# 	gitopts+=" --recursive"
			# 	repo+="Airblader/xcb-util-xrm";;
			conky)
				install -y -ng libiw-dev
				install -y -ng libpulse-dev libpulse
				install -y -ng libncurses-dev libncurses.-dev ncurses-devel ncurses
				install -y -ng wireless_tools wireless-tools
				cmakeopts="-D BUILD_WLAN=ON -D BUILD_PULSEAUDIO=ON -D BUILD_CMUS=ON -D CMAKE_INSTALL_PREFIX=/usr"
				repo+="brndnmtthws/conky.git";;
			fonts-powerline|python-pip|conky)
				_exitgitinstall
				return 4;;
			*)
				repo+="$1/$1.git"
				if ! git ls-remote "$repo" >/dev/null 2>&1; then
					if [ $# = 0 ]; then
						errcho "Err: Could not find git repository for $first"
						{ _exitgitinstall && return 2; }
					else
						shift
						pdebug "$repo doesn't seem to exist. Continuing"
						continue
					fi
				#else do nothing and exit the case block
				fi ;;
		esac
		local cwd
		cwd=$(pwd)
		cd "$tempdir"
		pdebug "Cloning $repo"
		if ! git clone $gitopts $repo; then
			errcho "Err: Error cloning the git repository"
			read -r -n1
			printf '\n'
			{ _exitgitinstall && return 3; }
		fi

		#Get the name of the directory we just cloned
		local cloneddir="${repo##*/}" #Get the substring from the last occurrence of / (the *.git part)
		cloneddir="${cloneddir%%.*}"  #Remove the .git to get only the name
		cd "$cloneddir"

		if [ -f setup.py ]; then
			install -y -ng setuptools python-setuptools python2-setuptools
			if sudo python setup.py "install"; then
				pdebug "Setup.py ran ok"
				{ _exitgitinstall && return 0; }
			else
				errcho "Err: Error building and installing $1"
				{ _exitgitinstall && return 1; }
			fi
		fi
		if [ -f autogen.sh ]; then
			pdebug "Found autogen"
			if install -y -ng automake; then
				pdebug "Running autogen"
				chmod +x autogen.sh
				./autogen.sh
				local ret=$?
				[ $ret != 0 ] && { pdebug "Error running autogen. Returned: $ret"; _exitgitinstall; return 1; }
			else
				errcho "Err: Could not install package automake necessary for compilation"
				{ _exitgitinstall && return 1; }
			fi
		elif [ -f configure.ac ] || [ -f configure.in ]; then
			pdebug "Found configure.ac or configure.in"
			if install -y -ng automake; then
				if autoreconf -fi; then
					pdebug "Autoreconf ran ok"
				else
					{ _exitgitinstall; return 1; }
				fi
			else
				errcho "Err: Could not install package automake necessary for compilation"
				{ _exitgitinstall && return 1; }
			fi
		elif [ -f CMakeLists.txt ] || [ -d cmake ]; then
			if install -y -ng cmake; then
				if [ ! -f Makefile ]; then
					mkdir build
					(
					cd build
					pdebug "Cmaking with opts: $cmakeopts .."
					cmake $cmakeopts .. 2>/dev/null
					)
				fi
			else
				errcho "Err: Could not install package cmake necessary for compilation"
				{ _exitgitinstall && return 1; }
			fi
		fi

		if [ -f configure ]; then
			pdebug "Found configure"
			chmod +x configure
			if ./configure $configureopts; then
				pdebug "Configure ran ok"
			else
				errcho "Err: Couldn't satisfy dependencies for $1."
				{ _exitgitinstall && return 1; }
			fi
		fi
		if [ -f Makefile ] || [ -f makefile ]; then
			pdebug "Found makefile"
			pdebug "Making with options: $makeopts"
			if make $makeopts; then
				pdebug "Make ran ok"
				if sudo make "install"; then
					pdebug "Make install ran ok. Exiting installation."
					{ _exitgitinstall && return 0; }
				else
					errcho "Err: Couldn't install $1"
					{ _exitgitinstall && return 1; }
				fi
			else
				errcho "Err: Couldn't build sources for $1"
				{ _exitgitinstall && return 1; }
			fi
		else
			errcho "Err: No makefile found. Couldn't build $1"
			{ _exitgitinstall && return 1; }
		fi
		{ _exitgitinstall && return 0; }
	done
	errcho "Err: Could not build this project"
	pdebug "Got to the end and project is not built. Returning 2"
	{ _exitgitinstall; return 2; }
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
	pdebug "Whattup. Installing $*"

	# First the exit conditions
	if $skipinstall; then
		pdebug "Skipinstall is true. Returning 0"
		return 0
	fi

	# Argument parsing
	local auto=$assumeyes
	local ignoregit=false
	local pip=false
	local installed=false
	local query=false
	while [ "${1:0:1}" = "-" ]; do
		if [ "$1" = "-y" ]; then
			auto=true
			shift
		fi
		if [ "$1" = "-ng" ]; then
			ignoregit=true
			shift
		fi
		if [ "$1" = "-pip" ]; then
			pip=true
			shift
		fi
		if [ "$1" = "-q" ]; then
			query=true
			shift
		fi
	done

	# Check if the program is installed already
	for name in "$@"; do #Check all the names provided
		hash "$name" 2>/dev/null
		local ret=$?
		if [ $ret = 0 ]; then
			pdebug "Hash found for $name"
		else
			pdebug "No hashing detected for $name"

			if $pip; then
				pipinstall -q "$name"
				ret=$?
			fi
		fi
		if $query; then
			return $ret
		fi

		if [ $ret = 0 ]; then
			installed=true
			if $gitoverride && ! $ignoregit; then
				pdebug "$name is installed already, but we're overriding it with the git version"
			else
				pdebug "$name is installed already. Exiting installation 0"
				return 0
			fi
		elif [ $ret = 127 ]; then
			# Exit the script completely
			quit 127
		else
			installed=false
			if ! $internet ;then
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
		pipinstall "$@"
		case $? in
			0) pdebug "Pipinstalled correctly. Exiting installation"
				return 0;;
			1) pdebug "Package not found in pip. Exiting 4"
				return 4;;
			2) pdebug "Pip error. Exiting 6"
				return 6;;
			3) pdebug "Can't install pip. Exiting 127"
				return 127;;
		esac
	fi

	#Clone and install using git if we need to
	if $gitversion && ! $ignoregit; then
		pdebug "Git version is true. Gitinstalling..."
		while true; do
			if $installed && $gitoverride; then
				uninstall "$@"
			fi

			gitinstall "$@"
			local ret=$?
			pdebug "Gitinstall $* returned $ret"
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
					pdebug "Installing the standard repository version"
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

	local args
	args=$*
	while [ $# -gt 0 ]; do
		if ! $updated; then
			pacapt sudo -Sy
			local ret=$?
			if [ $ret != 0 ]; then
				return $ret
			fi
			updated=true
		fi

		# if [ -n "$(pacapt -Ss "^$1$")" ]; then #Give it a regex so it only matches packages with exactly that name
		# pdebug "Found it!. It's called $1 here"
		pdebug "Repo installing $1"
		pacapt sudo -S --noconfirm "$1"
		local ret=$?
		pdebug "Pacapt install $1 returned: $ret"
		if [ $ret != 0 ]; then
			pdebug "Some error encountered while installing $1"
			shift
			[ $ret != 127 ] || return $ret
		else
			pdebug "Everything went super hunky dory"
			return 0
		fi
	done

	# Package not found in the repos. Let's see if git has it
	if ! $gitversion && ! $ignoregit; then
		gitinstall "$args" && return 0
	fi

	echo "${errhighlight}Package ${args[0]} couldn't be installed through the repos or git${reset}"
	pdebug "${errhighlight}Package ${args[0]} couldn't be installed through the repos or git${reset}"

	return 4
}

uninstall() {
	for prog in "$@"; do
		pdebug "Uninstalling $prog"
		pacapt sudo -Rn --noconfirm "$prog"
	done
}
# 2}}}

# DEPLOY FUNCTIONS {{{2
deploybash(){
	install -ng bash
	local ret=$?
	[ $ret = 0 ] || return $ret

	dumptohome bash
}

deployvim(){
	install vim
	local ret=$?
	[ $ret = 0 ] || return $ret

	dumptohome vim

	if ! $novimplugins && $internet; then
		if install -y -ng git; then
			if [ -d "$HOME/.vim/bundle/Vundle.vim" ]; then
				rm -rf "$HOME/.vim/bundle/Vundle.vim"
			fi
			git clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
		fi
		# if [ -f "$thisdir/vim/pathogen.sh" ]; then
		# 	if install -ng git; then
		# 		pdebug "Running pathogen script"
		# 		if "$thisdir/vim/pathogen.sh"; then
		# 			pdebug "Pathogen script ran without errors. Finished vim installation"
		# 			return 0
		# 		else
		# 			errcho "W: Ran into an error while installing vim plugins"
		# 			return 1
		# 		fi
		# 	fi
		# else
		# 	errcho "W: Could not find vim/pathogen.sh. Vim plugins will not be installed"
		# fi
	fi
}

deploypowerline(){
	install -pip powerline-status
	local ret=$?
	[ $ret != 0 ] && return $ret

	install -y -ng python-dev
	install -pip powerline-mem-segment
	[ $? != 0 ] && errcho "W: Could not install powerline-mem-segment. Expect an error from tmux"


	if install -y "fonts-powerline" "powerline-fonts"; then
		echo "Powerline installed successfully. You may need to reset your terminal or log out to see the changes"
	else
		errcho "W: Could not install patched fonts for powerline. Prompt may look glitched"
	fi

	cp -r "$thisdir/powerline" "$config"
}

deploytmux(){
	install tmux
	local ret=$?
	[ $ret = 0 ] || return $ret

	mkdir "$HOME/.tmux"
	cp "$thisdir/tmux/.tmux.conf" "$HOME"
	cp -r "$thisdir/tmux/colorschemes" "$HOME/.tmux/"
	if $internet; then
		install -y -ng git
		install -y -ng xsel xclip
		if [ -f "$thisdir/tmux/update_plugins.sh" ]; then
			"$thisdir/tmux/update_plugins.sh"
		fi
	fi
}

deploynano(){
	install -ng nano
	local ret=$?
	[ $ret = 0 ] || return $ret
	dumptohome nano
}

deployranger(){
	install ranger
	local ret=$?

	[ $ret = 0 ] || return $ret

	cp -r "$thisdir/ranger" "$config"
}

deployctags(){
	install ctags
	local ret=$?
	[ $ret = 0 ] || return $ret

	dumptohome ctags

	# Universal ctags uses the .ctags.d folder instead
	mkdir -p "$HOME/.ctags.d"
	ln -sf "$HOME/.ctags" "$HOME/.ctags.d/conf.ctags"
}

deploycmus(){
	install cmus
	local ret=$?
	[ $ret = 0 ] || return $ret

	[ ! -d "$config/cmus" ] && mkdir -p "$config/cmus"
	cp "$thisdir"/cmus/* "$config/cmus/"
}

deployemacs(){
	install emacs
	local ret=$?
	[ $ret = 0 ] || return $ret

	[ ! -d "$HOME/.emacs.d" ] && mkdir -p "$HOME/.emacs.d"
	dumptohome emacs
}

deployX(){
	dumptohome X
	[ ! -f "$HOME/.xinitrc" ] && ln -s "$HOME/.xprofile" "$HOME/.xinitrc"
	if hash xinit 2>/dev/null && [ -f "$HOME/.Xresources" ] && install -q xrdb; then
		xrdb "$HOME/.Xresources"
	fi
}

deployi3(){
	install i3 i3wm i3-wm
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

	[ ! -d "$config/i3" ] && mkdir -p "$config/i3"
	[ ! -d "$config/i3status" ] && mkdir -p "$config/i3status"

	cp "$thisdir/i3/config" "$config/i3"
	cp -R "$thisdir/i3/scripts" "$config/i3"


	local localversion
	if hash i3status 2>/dev/null; then
		localversion="$(i3status --version | awk '{print $2}')"
	else
		localversion="99.99"
	fi
	compare_versions $localversion 2.0
	if [ $? = 2 ]; then
		errcho "W: i3status version too old. Configuration will not be copied"
	else
		local conffile version ret versions
		for conffile in $thisdir/i3/i3status*.conf; do
			conffile="$(basename "$conffile")"
			version=${conffile#i3status}
			version=${version%.conf}
			versions+="$version\n"
		done
		if ! sort --help | grep -q '\-V' ; then
			# This is just for compatibility. It just works for very simple cases (like the ones we have), but
			# ideally, the system will have a proper version of sort with the -V option
			# versions="$(printf "$versions" | sort -r -k1.4)"
			versions="$(echo -e "$versions" | sort -r -k1.4)"
		else
			# versions="$(printf "$versions" | sort -r -V)"
			versions="$(echo -e "$versions" | sort -r -V)"
		fi

		# Copy the newest conf file available
		for version in $versions; do
			compare_versions "$localversion" "$version"
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
	deployurxvt
	ret=$?
	if [ $ret = 0 ]; then
		pdebug "Error installing urxvt. Returned $ret"
		return $ret
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
	# install -y -ng xorg-xlsfonts
	# [ $? != 0 ] && errcho "W: Could not install xorg-xlsfonts. Lemonbar may look glitched"

	installfont terminesspowerline
	installfont misc

	echo "Rebuilding font cache..."
	pdebug "Rebuilding font cache..."
	fc-cache -f

	cp -R "$thisdir/lemonbar" "$config"
}

deployneovim(){
	install neovim nvim
	local ret=$?
	[ $ret = 0 ] || return $ret

	[ ! -d "$config/nvim" ] && mkdir "$config/nvim"

	cp "$thisdir"/neovim/*.vim "$config/nvim"
	cp -r "$thisdir"/neovim/lua "$config/nvim"

	# If we're going to install vim, we'll symlink the config directories. Otherwise, we run the
	# pathogen script and download all the plugins directly into the nvim config directory
	if echo "$install" | grep -qw vim; then
		pdebug "Also installing vim. Symlinking config files"
		for folder in after autoload backup ftplugin snippets swp undo; do
			mkdir -p "$HOME/.vim/$folder"
			if [ ! -d "$config/nvim/$folder" ]; then
				ln -s "$HOME/.vim/$folder" "$config/nvim/"
			fi
		done
	else
		pdebug "Not installing vim. Neovim gets its own config files"

		# Also deploy the .vimrc or neovim won't be able to source it.
		if [ -f "$thisdir/vim/.vimrc" ]; then
			cp "$thisdir/vim/.vimrc" "$HOME"
		fi
		for dir in "$thisdir/vim/.vim/"*; do
			dname="$(basename "$dir")"
			if [ -L "$config/nvim/$dname" ]; then
				mkdir "$tempdir/configs"
				cp -r "$(readlink -f $config/nvim/$dname/*)" "$tempdir/configs"
				rm "$config/nvim/$dname"
				mkdir "$config/nvim/$dname"
				cp -r $tempdir/configs/* "$config/nvim/$dname"
				cp -R "$dir" "$config/nvim/"
			else
				cp -r "$dir" "$config/nvim"
			fi
		done
	fi

	if ! $novimplugins && $internet; then
		if install -y -ng git; then
			if [ -d "$config/nvim/bundle/Vundle.vim" ]; then
				rm -rf "$config/nvim/bundle/Vundle.vim"
			fi
			pdebug "Installing vundle"
			git clone https://github.com/VundleVim/Vundle.vim.git "$config/nvim/bundle/Vundle.vim"
			pdebug "Installing powerline patched fonts"
			git clone https://github.com/powerline/fonts.git "$tempdir/fonts"
			$tempdir/fonts/install.sh
		fi
		# if [ -f "$thisdir/vim/pathogen.sh" ]; then
		# 	if install -ng git; then
		# 		pdebug "Running pathogen script for neovim"
		# 		if ! "$thisdir"/vim/pathogen.sh neovim; then
		# 			errcho "W: Ran into an error while installing neovim plugins"
		# 			return 1
		# 		fi
		# 	fi
		# else
		# 	errcho "W: Could not find vim/pathogen.sh. Neovim plugins won't be installed"
		# fi
	else
		pdebug "Novimplugins option set. The pathogen script will not be run"
	fi
}

deploympd() {
	install mpd
	local ret=$?
	[ $ret = 0 ] || return $ret

	[ ! -d "$config/mpd" ] && mkdir "$config/mpd"
	cp "$thisdir"/mpd/* "$config/mpd"
}

deployncmpcpp() {
	install ncmpcpp
	local ret=$?
	[ $ret = 0 ] || return $ret

	[ -d "$config/ncmpcpp" ] || mkdir -p "$config/ncmpcpp"
	cp "$thisdir"/ncmpcpp/* "$config/ncmpcpp"

}

deployjupyter() {
	install -pip jupyter
	local ret=$?
	[ $ret = 0 ] || return $ret

	target="$HOME/.jupyter/nbconfig"
	[ -d "$target" ] || mkdir -p "$target"
	cp "$thisdir/jupyter/notebook.json"  "$target"
}

deploygit(){
	install -ng git
	local ret=$?
	[ $ret = 0 ] || return $ret

	dumptohome git
}

deployptpython() {
	install -pip ptpython
	local ret=$?
	[ $ret = 0 ] || return $ret

	target="$config/ptpython"
	[ -d "$target" ] || mkdir -p "$target"
	cp "$thisdir/ptpython/config.py" "$target"
}

deployurxvt() {
	pdebug "Installing urxvt"
	install -ng urxvt rxvt-unicode-256 rxvt-unicode-256color rxvt-unicode
	local ret=$?
	[ $ret = 0 ] || return $ret

	cp "$thisdir/X/.Xresources" "$HOME"
	if hash xinit 2>/dev/null; then
		install -q xrdb && xrdb -merge "$HOME/.Xresources"
	fi

	# Install extensions
	mkdir -p "$HOME/.urxvt/ext"
	if ! download "https://raw.githubusercontent.com/majutsushi/urxvt-font-size/master/font-size" "$HOME/.urxvt/ext/font-size"; then
		echo "W: Urxvt extension could not be installed"
	else
		chmod +x "$HOME/.urxvt/ext/font-size"
	fi
}

deployack(){
	install ack
	local ret=$?
	[ $ret = 0 ] || return $ret

	dumptohome ack
}

deployall(){
	pdebug "Deploy all"
	for dotfile in $install; do
		pdebug "${highlight}Installing $dotfile${reset}"
		( deploy$dotfile )
		local ret=$?
		if [ $ret = 0 ];  then
			pdebug "${highlight}Deploy$dotfile returned: $ret${reset}"
		else
			pdebug "${errhighlight}Deploy$dotfile returned: $ret${reset}"
		fi
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
				read -r -n1
				printf '\n';;
			127)
				errcho "Fatal error. Exiting script"
				quit 127;;
		esac
	done
}

epilogue() {
	if echo "$install" | grep -qw vim; then
		if ! $novimplugins && $internet; then
			pdebug "Installing vim plugins"
			vim +PluginInstall +qa!
			pdebug "Res: $?"
		fi
	fi

	if echo "$install" | grep -qw vim; then
		if ! $novimplugins && $internet; then
			pdebug "Installing nvim plugins"
			nvim +PluginInstall +qa!
			pdebug "Res: $?"
		fi
	fi
}

# Copies every file in $1 to the home directory
dumptohome(){
	pdebug "Dumping $1 to home"
	local ignore='.git pathogen.sh update_plugins.sh'
	for file in "$thisdir/$1"/{.[^.],}*; do
		echo "$ignore" | grep -qw "$(basename "$file")" && continue
		if [ -e "$file" ]; then
			cp -R "$file" "$HOME"
		fi
	done
}
# 2}}}

#1}}}

# MAIN LOGIC {{{1

pdebug "HELLO WORLD"
pdebug "Temp dir: $tempdir"

trap "printf '\nAborted\n'; quit 127"  SIGHUP SIGINT SIGTSTP

if [ -z "$BASH_VERSION"  ]; then
	echo "W: This script was written using bash with portability in mind. However, compatibility with other shells hasn't been tested yet. Bear
	that in mind and run it at your own risk.

	Press any key to continue"

	read -r -n1
fi

#Deploy and reload everything
if [ $# = 0 ]; then
	install="$dotfiles"
	deployall
else
	pdebug "Args: [$*]"
	install="$dotfiles"
	while [ $# -gt 0 ] &&  [ "${1:0:1}" = "-" ]; do
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
				echo "Install the necessary dotfiles for the specified programs. These will be installed"
				echo "automatically when trying to deploy their corresponding dotfiles."
				help
				quit;;
			-x|--exclude)
				shift
				pdebug "Exclude got args: $*"
				while [ $# -gt 0 ] && [ "${1:0:1}" != "-" ]; do
					#Check if the argument is present in the array
					found=false
					for dotfile in $dotfiles; do
						if [ "$1" = "$dotfile" ]; then
							install="$(echo "$install" | sed -r "s/ ?$1 ?/ /g")" #Remove the word $1 from $install
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
			cmd="$1"
			# I sometimes autocomplete program names, since there's a local folder, with that name,
			# but the autocomplete system adds a trailing slash to indicate it's a directory
			len="$((${#cmd}-1))"
			if [ "${1:$len:1}" == "/" ]; then
				cmd="${cmd:0:-1}"
			fi

			# I had to make the exception for neovim, since the nvim name is quite common
			if [ "$cmd" = "nvim" ]; then
				cmd=neovim
			fi
			# Check if the argument is in our list
			if echo "$dotfiles" | grep -qw "$cmd"; then
				if ! echo "$install" | grep -qw "$cmd"; then
					install+="$cmd "
					pdebug "Will install $cmd"
					#else skip it because it's already in the install list
				else
					pdebug "Skip $cmd because it's already in the install list. Install: $install"
				fi
			else
				errcho "Err: Program '$cmd' not recognized. Skipping."
			fi
			shift
		done
	fi
	pdebug "Done parsing commands"
	pdebug "Deploying: $install"
	deployall
fi

epilogue

quit
# 1}}}
