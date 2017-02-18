#!/bin/bash

#TODO Minimize output. Add option for full output of external commands
#TODO Separate lists for install and git install. -g Must be specified for every program in the list
#TODO Keep all special git repos in a separate list and remove them from the big case statement. That's just ugly as fuck

#BUG '-x vim -g' doesn't really work

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
dotfiles="bash vim powerline tmux nano ranger ctags cmus emacs X i3"
install="" #Dotfiles to install. This will change over the course of the program

#Exclusions from deployall specifiable with --exclude
#This loop sets to false n variables named xbash xvim xtmux etc
for dotfile in $dotfiles; do
	eval x$dotfile=false # Yes, I know eval is evil but I couldn't find any other way to do this and it seems to work fine
done

####### VARIABLE INITIALIZATION ##############

####### MISC FUNCTIONS DECLARATION ###########
errcho() {
	>&2 echo "$*"
	pdebug "$*"
}

pdebug(){
	if $debug; then
		[ ! -p "$thisdir/output" ] && mkfifo "$thisdir/output"
		echo "$*" >> "$thisdir/output"
	fi
}

quit(){
	if [ -n "$1" ]; then
		pdebug "Quitting with return code $1"
	else
		pdebug "Quitting with return code 0"
	fi

	[ -p "$thisdir/output" ] && rm "$thisdir/output"
	rm -rf "$tempdir" 2>/dev/null

	unset thisfile thisdir tempdir 
	unset updated assumeyes rootaccess internet gitversion novimplugins skipinstall debug

	[ -n "$1" ] && exit $1
	exit 0
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
	-i|--no-install:  Skip all installations. Only copy files
	-n|--no-root:     Ignore commands that require root access
	-o|--offline:     Ignore commands that require internet access
	-p|--no-plugins:  Don't install vim plugins
	-d|--debug: 	  Print debug information to an external pipe
	-y|--assume-yes:  Assume yes to all questions
	-x|--exclude:     Specify the programs which configurations will NOT be installed
	
	--override: 	  Override currently installed version with the git one. (Implies -g)."
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
				repo+=tmux/tmux.git
				install -ng -y libevent-dev
				install -ng -y libncurses-dev libncurses.-dev
				install -ng -y pkg-config;;
			vim)
				repo+=vim/vim.git
				install -ng -y libevent-dev
				install -ng -y libncurses-dev libncurses.-dev;;
			emacs)
				install -y -ng libgtk2.0-dev 'libgtk.*-dev'
				install -y -ng libxpm-dev libxpm
				install -y -ng libjpeg-dev libjpeg
				install -y -ng libgif-dev libgif
				install -y -ng libtiff-dev libtiff
				install -y -ng libgnutls-dev libgnutls28-dev libgnutls.*-dev
				install -ng -y libncurses-dev libncurses.-dev
				repo="-b master git://git.sv.gnu.org/emacs.git";;
			playerctl)
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

uninstall() {
	# We'll use the awesome pacapt script from https://github.com/icy/pacapt/tree/ng to install packages on any distro (even OSX!)
	local cwd="$(pwd)"
	cd $tempdir
	
	if [ ! -f pacapt ]; then
		echo "Detecting distro's package manager..."
		pdebug "Downloading pacapt and stuff"
		wget -qO pacapt https://github.com/icy/pacapt/raw/ng/pacapt 
	fi
	chmod +x pacapt

	sudo ./pacapt -Rn $1

	cd "$cwd"
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
	auto=$assumeyes
	ignoregit=false
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
		if hash $name 2>/dev/null; then
			if $gitversion && $gitoverride; then
				uninstall $name
			else
				pdebug "This is installed already"
				return 0
			fi
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
		else
			prompt="$1 is already installed. Do you want to install the git version instead? (Y/n): "
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


	# We'll use the awesome pacapt script from https://github.com/icy/pacapt/tree/ng to install packages on any distro (even OSX!)
	local cwd="$(pwd)"
	cd $tempdir
	
	if [ ! -f pacapt ]; then
		echo "Detecting distro's package manager..."
		pdebug "Downloading pacapt and stuff"
		wget -qO pacapt https://github.com/icy/pacapt/raw/ng/pacapt 
	fi
	chmod +x pacapt

	while [ $# -gt 0 ]; do
		if ! $updated; then
			sudo ./pacapt -Sy
			updated=true
		fi
		if [ "$(./pacapt -Ss "^$1$")" ]; then #Give it a regex so it only matches packages with exactly that name
			pdebug "Found it!"
			sudo ./pacapt -S --noconfirm $1
			local ret=$?
			if [ $ret != 0 ]; then
				pdebug "Some error encountered while installing $1"

				cd "$cwd"
				return $ret
			else
				pdebug "Everything went super hunky dory"

				cd "$cwd"
				return 0
			fi	
		else
			pdebug "Nope. Not in the repos"
			shift
		fi
	done
	echo "Package $* not found"
	pdebug "Package $* not found"

	cd "$cwd"
}


deploybash(){
	pdebug "Installing bash"
	install -ng bash && dumptohome bash
}

deployvim(){
	pdebug "Installing vim"
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
			if install -ng git && install -ng -y wget; then
				pdebug "Running pathogen script"
				source "$thisdir/vim/pathogen.sh"
			fi
		else
			errcho "W:Could not find vim/pathogen.sh. Vim addons will not be installed"
		fi
	fi
}


deploypowerline(){
	pdebug "Installing powerline"

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
			echo "Powerline installed successfully. Restart your terminal to see the changes"
		fi
	fi

	cp -r "$thisdir/powerline" $config
}

deploytmux(){
	pdebug "Installing tmux"
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
	pdebug "Installing nano"
	dumptohome nano
}

deployranger(){
	pdebug "Installing ranger"
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
	pdebug "Installing ctags"
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
	pdebug "Installing cmus"
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
	pdebug "Installing emacs"
	if ! $skipinstall; then
		install emacs gnu-emacs
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

		install -y -ng dmenu i3-dmenu i3dmenu dmenu-i3
		local ret=$?
		if [ $ret != 0 ]; then
			[ $ret -le 3 ] && return 1
			[ $ret -gt 3 ] && return 2
		fi 
	fi

	[ ! -d "$config/i3" ] && mkdir -p "$config/i3"
	[ ! -d "$config/i3status" ] && mkdir -p "$config/i3status"

	cp "$thisdir/i3/config" "$config/i3"
	cp "$thisdir/i3/i3status.conf" "$config/i3status"

	## That's it for the config files, here's where the fun begins
	# Needed for playback controls
	$skipinstall || install -y playerctl

	# Fonts
	if ! $internet || ! $rootaccess; then
		[ ! -d /usr/share/fonts/opentype/scp ] && errcho "W: Could not install source code pro font"
		[ ! -f /usr/share/fonts/TTF/FontAwesome.ttf ] && errcho "W: Could not install font awesome. i3 bar will be glitched"
	else
		local installed=false
		local fonts=/usr/share/fonts/opentype/scp
		[ ! -d $fonts ] && sudo mkdir $fonts

		if [ -d $fonts ]; then
			if [ -d $fonts/.git ]; then
				pushd . >/dev/null
				cd $fonts && git pull origin release
				popd >/dev/null
			elif [ "$(ls $fonts | wc -l)" -gt 0 ]; then
				sudo rm -rf $fonts/*
				sudo git clone --depth 1 --branch release https://github.com/adobe-fonts/source-code-pro.git $fonts
				[ $? = 0 ] && installed=true
			else
				sudo git clone --depth 1 --branch release https://github.com/adobe-fonts/source-code-pro.git $fonts
				[ $? = 0 ] && installed=true
			fi
		else
			sudo git clone --depth 1 --branch release https://github.com/adobe-fonts/source-code-pro.git $fonts
			[ $? = 0 ] && installed=true
		fi
		if $installed; then
			sudo mkfontscale $fonts
			sudo mkfontdir $fonts
		fi

		fonts=/usr/share/fonts/TTF
		if [ ! -f $fonts/FontAwesome.ttf ]; then
			if $rootaccess && $internet; then
				[ ! -d $fonts ] && sudo mkdir $fonts
				sudo wget -q https://github.com/FortAwesome/Font-Awesome/tree/master/fonts/FontAwesome.ttf -O $fonts/FontAwesome.ttf
				[ $? = 0 ] && installed=true
			fi
		fi
		if $installed; then
			sudo fc-cache -fs 2>/dev/null
			sudo fc-cache-32 -fs 2>/dev/null
			sudo mkfontscale $fonts
			sudo mkfontdir $fonts
		fi

	fi

	# We'll want to use urxvt
	if ! $skipinstall; then
		if install urxvt rxvt-unicode; then
			cp "$thisdir/X/.Xresources" "$HOME"
			xrdb -merge "$HOME/.Xresources"
		fi
	fi

	#Lemonbar configuration will go here
}

deployall(){
	pdebug "Deploy all"
	for dotfile in $install; do
		( deploy$dotfile )
		local ret=$?
		pdebug "Deploy$dotfile returned: $ret"
		if [ $ret = 5 ]; then
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
	while [ $# -gt 0 ] &&  [ ${1:0:1} = "-" ]; do 
		pdebug "Parsing arg $1"
		case $1 in
			-h|--help)               help;;
			-g|--git|--git-version)  gitversion=true;;
			-i|--no-install) 		 skipinstall=true;;
			-n|--no-root)            rootaccess=false;;
			-o|--offline)            internet=false;;
			--override) 			 gitoverride=true; gitversion=true;;
			-p|--no-plugins)         novimplugins=true;;
			-y|--assume-yes)         assumeyes=true;;
			-d|--debug) 			 debug=true;;
			-x|--exclude)
				shift
				pdebug "Exclude got args: $*"
				install="$dotfiles"
				while [ $# -gt 0 ] && [ ${1:0:1} != "-" ]; do
					#Check if the argument is present in the array
					found=false
					for dotfile in $dotfiles; do
						if [ "$1" = "$dotfile" ]; then
							install=$(echo $install | sed -r "s/ ?$1 ?/ /g") #Remove the word $1 from $install
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
		install="$dotfiles"
	else # A list of programs has been specified. Will install only those, so we'll first clear the installation list
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
