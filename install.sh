#!/bin/bash

if [ "$0" != "bash" ] && [ "$0" != "-bash" ]; then
    echo " This script was wrote using bash with portability in mind. However, compatibility with other shells hasn't been tested yet. Bear
    that in mind and run it at your own risk.
    read -n1"
fi

thisfile="$(basename $0)"
thisdir="$(dirname $(readlink -f $thisfile))"
updated=false
assumeyes=false
rootaccess=true
internet=true
gitversion=false

# A poor emulation of arrays for pure compatibility with other shells
dotfiles="bash vim powerline tmux zsh nano ranger ctags cmus"

#Exclusions from deployall specifiable with --exclude
#This loop sets to false n variables named xbash xvim xtmux etc
for dotfile in $dotfiles; do
    eval x$dotfile=false
    eval echo \$x$dotfile
done

#TODO Add support for other programming languages and compiling paradigms
#Return codes
# 0 - Successful installation
# 1 - $gitversion is not even true
# 2 - Build error
# 3 - Git repo not found
gitinstall(){
    $gitversion || return 1
    local first="$1"
    local repotemplate="https://github.com/"
    local repo=$repotemplate
    while [ $# -gt 0 ]; do
	case $1 in
	    "tmux") repo+=tmux/tmux.git;;
	    "vim") repo+=vim/vim.git;;
	    "*") repo+=$1/$1.git
		git ls-remote $repo 2>/dev/null
		if [ $? != 0 ] ; then 
		    if [ $# = 1 ]; then
			echo "Could not find git repository for $first"
			return 3
		    else
			shift
		    fi
		#else do nothing and exit the case block
		fi ;;
	esac
	git clone $repo
	pushd . >/dev/null
	cd $1
	[ -f autogen.sh ] && install -y automake
	if [ $? -gt 0 ]; then 
	    echo "Err: Could not install package automake necessary for compilation"
	    popd >/dev/null
	    rm -rf "$1"
	    return 2
	fi

	[ -f configure ] && chmod +x configure && ./configure
	make
	if [ $? != 0 ]; then
	    echo "Err: There were build errors"
	    return 2
	fi
	sudo make install
	popd >/dev/null
	rm -rf "$1"
    done
    return 0
}

#Check package managers and install program $1 if it's not installed. The rest of the 
#arguments are other possible names for this program
#
#Return codes
# -1 - Program is already installed 
# 0 - Installation succesful
# 1 - User declined installation
# 2 - Error executing installation
# 3 - Program not installed and there's no root access available
# 4 - Program not installed and there's no internet connection
install() {
    auto=$assumeyes
    [ "$1" = "-y" ] && auto=true
    local install=""
    for name in "$@"; do #Check if the program is installed under any of the names provided
	if hash $name 2>/dev/null; then
	    $internet && return -1 || return 4
	fi
    done

    $rootaccess || return 3

    if ! $auto; then
	echo -n "$1 is not installed. Do you want to try and install it? (Y/n): "
	read -n1 opt
	printf "\n"	
	[ $opt = "n" ] || [ $opt = "N" ] && { unset opt; return 1; }
	unset opt
    fi

    if $gitversion; then
	gitinstall $*
	if [ $? -gt 0 ]; then
	    echo "Git installation failed. Reverting to normal installation"
	else
	    return 0
	fi
    fi

    local first=$1
    #TODO Find a better way to search for packages	
    while [ $# -gt 0 ]; do
	if [ -f /etc/debian_version ]; then
	    if ! $updated; then
		install="sudo apt-get update && "
		updated=true
	    fi
	    install+="sudo apt-get install -y"
	elif [ -f /etc/fedora-release ]; then
	    install="sudo dnf install"
	else
	    os="$(grep DISTRIB_ID | cut -d '=' -f2)"
	    if [ "$os" = Arch ]; then
		if ! $updated; then
		    install="sudo pacman -Syy && "
		    updated=true
		fi
		install="sudo pacman -S"
		#elif [ "$os" = Ubuntu ] || [ "$os" = "elementary OS" ]; then
		#	if ! $updated; then
		#		install="sudo apt-get update && "
		#		updated=true
		#	fi
		#	install+="sudo apt-get install -y"
	    else
		echo "Could not find the right package manager for your distribution. Please install
		$1 manually"
	    fi
	fi

	if ! eval "$install $1"; then
	    if [ $# = 1 ]; then
		echo "Unknown error while installing $first. Please do it manually"
		return 2
	    else
		shift
	    fi
	else
	    return 0
	fi
    done
}


deploybash(){
    dumptohome bash
}

deployvim(){
    install vim
    local ret=$?

    [ $ret = 1 ] || [ $ret = 4 ] && return

    dumptohome vim

    if [ -f "$thisdir/vim/pathogen.sh" ]; then
	source "$thisdir/vim/pathogen.sh"
    else
	echo "W:Could not find vim/pathogen.sh. Vim addons will not be installed"
    fi

}


deploypowerline(){
    install "python-pip" "python2-pip" "pip2" "pip"
    [ $? = 1 ] || [ $? = 4 ] && return
	
    if ! $rootaccess; then
	sudo pip install --upgrade pip
	sudo pip2 install powerline-status powerline-mem-segment
    fi

    [ -f /etc/debian_version ] && { install -y "python-dev"; install -y "python3-dev"; }
    install -y "psutils"
    [ ! -d "$HOME/.config" ] && mkdir -p "$HOME/.config"
    cp -r. "$thisdir/powerline" "$HOME/.config/"

    if [ -f "$HOME/.tmux.conf" ] && [ ! -f "$HOME/.config/tmux" ]; then
	local powerline_root="$(python2 -c 'from powerline.config import POWERLINE_ROOT; print (POWERLINE_ROOT)' 2>/dev/null)"
	if [ -f "$powerline_root/powerline/bindings/tmux/powerline.conf" ]; then
	    mkdir "$HOME/.config/tmux"
	    cp "$powerline_root/powerline/bindings/tmux/powerline.conf" "$HOME/.config/tmux/powerline"
	else
	    echo "W: Could not find powerline configuration file in $powerline_root/powerline/bindings/tmux"
	fi
    fi
}

deploytmux(){
    install "tmux" "tmux-git"
    [ $? = 1 ] && return
    local powerline_root="$(python2 -c 'from powerline.config import POWERLINE_ROOT; print (POWERLINE_ROOT)' 2>/dev/null)"
    if [ -f "$powerline_root/powerline/bindings/tmux/powerline.conf" ]; then
	mkdir "$HOME/.config/tmux"
	cp "$powerline_root/powerline/bindings/tmux/powerline.conf" "$HOME/.config/tmux/powerline"
    else
	echo "W: Could not find powerline configuration file in $powerline_root/powerline/bindings/tmux"
    fi
    dumptohome tmux 
}

deployzsh(){
    install zsh
    [ $? != 1 ] && dumptohome zsh
}

deploynano(){
    dumptohome nano
}

deployranger(){
    cp -r "$thisdir/ranger" "$HOME/.config"
}

deployctags(){
    install ctags
    dumptohome ctags
}

deploycmus(){
    install cmus
    [ ! -d "$HOME/.config/cmus" ] && mkdir -p "$HOME/.config/cmus"
    cp "$thisdir/cmus/*" "$HOME/.config/cmus/"
}

deployall(){
    for dotfile in bash vim powerline tmux zsh nano ranger ctags cmus; do
	var="x$dotfile"
	if ! $(eval echo \$$var); then
	    eval "deploy$dotfile"
	fi
    done
}

#Copies every dotfile (no folders) from $1 to $HOME
dumptohome(){
    for file in "$thisdir"/"$1"/.[!.]*; do
	[ -f "$file" ] && cp "$file" "$HOME"
    done
}



help(){
    echo "Install the necessary dotfiles for the specified programs. These will be installed
    automatically when trying to deploy their corresponding dotfiles.
    Usage: $thisfile [options] [${dotfiles// /|}] 

    Run this script  with no commands to install all dotfiles.
    Use any number of arguments followed by a list of the space-separated programs that you want to install dotfiles for.
    TIP: Run this script again as root to install dotfiles for that user as well

    Supported arguments:	
    -h: Show this help message
    -g: Prefer git versions if available
    -n: Ignore commands that require root access 
    -o: Ignore commands that require internet access
    -p: Don't install vim plugins
    -y: Assume yes to all questions
    --exclude: Specify the programs which configurations will NOT be installed"
}

#Deploy and reload everything
if [ $# = 0 ]; then
    deployall
else
    while [ $# -gt 0 ] &&  [ ${1:0:1} = "-" ]; do 
	case $1 in
	    "-h"|"--help") help;;
	    "-g"|"--git"|"--git-version") gitversion=true;;
	    "-n"|"--no-root") rootaccess=false;;
	    "-o"|"--offline") internet=false;;
	    "-p"|"--no-plugins") novimplugigns=true;;
	    "-y"|"--assume-yes") assumeyes=true;;
	    "-x"|"--exclude")
		while [ $# -gt 0 ] && [ ${1:0:1} != "-" ]; do
		    #Check if the argument is present in the array
		    for dotfile in $dotfiles; do
			if [ $1 = $dotfile ]; then
			    eval x$dotfile=true
			else
			    echo "Program \'$1\' not recognized. Skipping."
			fi
		    done
		    shift
		done;;
	    *) echo   "Argument $1 not recognized"; help;;
	esac
	shift
    done
    while [ $# -gt 0 ]; do 	
	# Check if the argument is in our list. Actually checking if it's a substring in a portable way. Cool huh?
	if [ -z ${dotfiles##*$1*} ]; then
	    "deploy$arg"
	else
	    echo "Program \'$1\' not recognized. Skipping."
	fi		    
	shift
    done	
fi

#TODO Why the fuck is this not working????
source "$HOME/.bashrc"
