#!/bin/bash

## This script will clone all my git plugins into their respective folders. 
# I prefer this over submodules because it's easier to control and to add and remove plugins from the list

# To add a new plugin just insert it below the column of plugins that are already there. Call the function plugin
# with the name and the URL of its git repository


errcho () {
	echo "$*" >&2
}

quit(){
	cd "$cwd"
	exit $1
}

setup() {
	cwd="$(pwd)"

	## First make sure the directories exist and pathogen is downloaded
	[ ! -d "$vimdir" ] && mkdir "$vimdir"
	if [ ! -e "$vimdir/autoload/pathogen.vim" ]; then
		mkdir -p "$vimdir/autoload"
		if hash wget 2>/dev/null; then
			wget -q https://tpo.pe/pathogen.vim -P "$vimdir/autoload" 
			[ $? = 0 ] || { errcho "Err: Could not download pathogen. Are you connected to the internet?"; exit 3; }
		elif hash curl 2>/dev/null; then
			curl -sL https://tpo.pe/pathogen.vim -o "$vimdir/autoload" 
			[ $? = 0 ] || { errcho "Err: Could not download pathogen. Are you connected to the internet?"; exit 3; }
		else
			errcho "Err: Could not pathogen. Either wget or curl need to be installed"
		fi
	fi
	[ ! -d "$vimdir/bundle" ] && mkdir "$vimdir/bundle"
}

plugin (){
	trap "printf '\rAborted\n'; quit" SIGINT SIGTERM
	if ! [ -d "$1" ]; then
		local repo=""
		local opts=""

		# Get the repo URL, which should be the last argument received
		for repo; do true; done

		if ! git ls-remote "$repo" >/dev/null 2>&1; then
			echo "W: Repository $repo not found" 2>&1
			return 1
		fi

		shift
		git clone $*
	else
		if ! [ -d "$1/.git" ]; then
			errcho "Err: Directory for $1 already exists and it's not a git repository" 2>&1
			return 1
		fi

		pushd . >/dev/null
		cd "$1"
		git pull origin master
		popd >/dev/null
	fi
}

if [ $# -gt 0 ]; then
	case "$1" in
		vim) vimdir="$HOME/.vim";;
		nvim)
			if [ -n "$XDG_CONFIG_HOME" ]; then
				vimdir="$XDG_CONFIG_HOME/nvim"
			else
				vimdir="$HOME/.config/nvim"
			fi;;
		--help)
			echo "Download or update all my vim plugins."
			echo "Usage: $(basename $0) [vim|neovim]"
			echo "(Defaults to vim directory $HOME/.vim)"
			exit 0
		*)
			vimdir="$1"
	esac
else
	vimdir="$HOME/.vim"
fi
setup
		

#Now download all the plugins 
pushd . >/dev/null
cd "$vimdir/bundle"

plugin auto-pairs 			https://github.com/jiangmiao/auto-pairs.git
plugin ctrlp.vim 		    https://github.com/ctrlpvim/ctrlp.vim.git
plugin matchit              https://github.com/tmhedberg/matchit.git
plugin nerdtree             https://github.com/scrooloose/nerdtree.git
plugin syntastic 		    --depth=1 https://github.com/vim-syntastic/syntastic.git
plugin tabular              https://github.com/godlygeek/tabular.git
plugin vim-colorschemes 	https://github.com/flazz/vim-colorschemes.git
plugin vim-commentary 		https://github.com/tpope/vim-commentary.git
plugin vim-easymotion       https://github.com/easymotion/vim-easymotion.git
plugin vim-javacomplete2	https://github.com/artur-shaik/vim-javacomplete2.git
plugin vim-repeat           git://github.com/tpope/vim-repeat.git
plugin vim-surround 		git://github.com/tpope/vim-surround.git
plugin vim-table-mode 		https://github.com/dhruvasagar/vim-table-mode.git
plugin vim-textobj-function https://github.com/kana/vim-textobj-function.git
plugin vim-textobj-entire   https://github.com/kana/vim-textobj-entire.git
plugin vim-textobj-line 	https://github.com/kana/vim-textobj-line.git
plugin vim-textobj-user 	https://github.com/kana/vim-textobj-user.git


## Post actions. Some plugins have a very weird installation process
# Matchit
[ ! -d ../plugin ] &&  mkdir ../plugin
[ ! -d ../doc ]    &&  mkdir ../doc
for file in "matchit/plugin/.[!.]*"; do
	[ ! -e "../plugin/$file" ] &&  ln -s "$(readlink -f matchit/plugin/$file)" ../plugin/ >/dev/null 2>&1
done
for file in "matchit/doc/.[!.]*"; do
	[ ! -e "../doc/$file" ] && ln -s "$(readlink -f matchit/doc/$file)"  ../doc/ >/dev/null 2>&1
done


# Cleanup some files we don't need
find . -name "*.png" -exec rm -f {} \;

popd >/dev/null
