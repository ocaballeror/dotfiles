#!/bin/bash

## This script will clone all my git plugins into their respective folders. 
# I prefer this over submodules because it's easier to control and to add and remove plugins from the list

# To add a new plugin just insert it below the column of plugins that are already there. Call the function plugin
# with the name and the URL of its git repository


## First make sure the directories exist and pathogen is downloaded
[ ! -d "$HOME/.vim" ] && mkdir "$HOME/.vim"
if [ ! -e "$HOME/.vim/autoload/pathogen.vim" ]; then
	mkdir -p "$HOME/.vim/autoload" && \
		wget -q https://tpo.pe/pathogen.vim -P "$HOME/.vim/autoload" 
fi
[ ! -d "$HOME/.vim/bundle" ] && mkdir "$HOME/.vim/bundle"

plugin (){
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
			echo "Err: Directory for $1 already exists and it's not a git repository" 2>&1
			return 1
		fi
		pushd . >/dev/null
		cd "$1"
		git pull origin master
		popd >/dev/null
	fi
}


#Now download all the plugins 
pushd . >/dev/null
cd "$HOME/.vim/bundle"

plugin syntastic 		    --depth=1 https://github.com/vim-syntastic/syntastic.git
plugin ctrlp.vim 		    https://github.com/ctrlpvim/ctrlp.vim.git
plugin vim-colorschemes 	https://github.com/flazz/vim-colorschemes.git
plugin vim-quicktask 		https://github.com/aaronbieber/vim-quicktask.git
plugin vim-surround 		git://github.com/tpope/vim-surround.git
plugin matchit              https://github.com/tmhedberg/matchit.git
plugin tabular              https://github.com/godlygeek/tabular.git
plugin vim-table-mode 		https://github.com/dhruvasagar/vim-table-mode.git
plugin easy-motion      	https://github.com/easymotion/vim-easymotion.git
plugin nerdtree             https://github.com/scrooloose/nerdtree.git
plugin vim-repeat           git://github.com/tpope/vim-repeat.git
plugin vim-javacomplete2	https://github.com/artur-shaik/vim-javacomplete2.git

[ ! -d ../plugin ] &&  mkdir ../plugin
[ ! -d ../doc ]    &&  mkdir ../doc
for file in "matchit/plugin/.[!.]*"; do
	[ ! -e "../plugin/$file" ] &&  ln -s "$(readlink -f matchit/plugin/$file)" ../plugin/ >/dev/null 2>&1
done
for file in "matchit/doc/.[!.]*"; do
	[ ! -e "../doc/$file" ] && ln -s "$(readlink -f matchit/doc/$file)"  ../doc/ >/dev/null 2>&1
done
popd >/dev/null
