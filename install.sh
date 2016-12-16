#!/bin/bash

#Check package managers and install program $1 if it's not installed. The rest of the 
#arguments are other possible names for this program

thisfile="$(basename $0)"
thisdir="$(dirname $(readlink -f $thisfile))"
updated=false
assumeyes=false
rootaccess=true
internet=true
gitversion=false

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
	
	sudo pip install --upgrade pip
	sudo pip2 install powerline-status powerline-mem-segment

	[ -f /etc/debian_version ] && { install -y python-dev; install -y python3-dev; }
	install -y psutils
	[ ! -d $HOME/.config ] && mkdir -p $HOME/.config
	cp -r "$thisdir"/powerline "$HOME"/.config/

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

deployall(){
	deploybash
	deployvim
	deploypowerline
	deploytmux
	deployzsh
	deploynano
	deployranger
}

#Copies every dotfile (no folders) from $1 to $HOME
dumptohome(){
	for file in "$thisdir"/"$1"/.[!.]*; do
		[ -f "$file" ] && cp "$file" "$HOME"
	done
}



help(){
	echo "Install the specified dotfiles for the necessary programs. These will be installed
	automatically when trying to deploy their corresponding dotfiles.
	Usage: $thisfile [bash|vim|powerline|tmux|zsh|nano|all|<arg>]
	
	Run this script  with no commands to install all dotfiles.
	Supported args:	
		-h: Show this help message
		-y: Assume yes to all questions
		-n: Ignore commands that require root access 
		-o: Ignore commands that require internet access
		-g: Prefer git versions if available
		-r: Install dotfiles to /root as well"
}

#Deploy and reload everything
if [ $# = 0 ]; then
	deployall
else
	for arg in "$@"; do
		case $arg in
			"bash") 	deploybash;;
			"vim")		deployvim;;
			"powerline")	deploypowerline;;
			"tmux") 	deploytmux;;
			"zsh")		deployzsh;;
			"nano") 	deploynano;;
			"ranger") 	deployranger;;
			"all")		deployall;;
			"-h") help;;
			"-y") assumeyes=true;;
			"-n") rootaccess=false;;
			"-o") internet=false;;
			"-g") gitversion=true;;
			"-r"|"--root")
				for file in .bashrc .bash_aliases .bash_functions .tmux.conf .vimrc .nanorc .zshrc; do
					[ -f "/root/$file" ] && sudo rm "/root/$file"
					sudo ln -s "$HOME/$file" .
				done;;
			*) echo "Argument $arg not recognized";;
		esac
	done
fi

source "$HOME/.bashrc"
