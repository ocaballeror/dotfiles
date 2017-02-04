#!/bin/bash

#BUG pathogen.vim is cloned inside a folder. Get it out of there and make the pathogen.vim file be in the root .vim/autoload directory

#First make sure the directories exist and pathogen is downloaded
if [ ! -f "$HOME/.vim/autoload/pathogen.vim" ]; then
	mkdir -p "$HOME/.vim/autoload" && \
		wget https://tpo.pe/pathogen.vim -P "$HOME/.vim/autoload/pathogen.vim" 
fi
[ ! -d "$HOME/.vim/bundle" ] && mkdir "$HOME/.vim/bundle"

plugin (){
	if ! [ -d "$1" ]; then
	    local repo=""
	    local opts=""
	    for i in "${@:2}"; do
		if [ -n "$1" ] && [ "$1" != " " ] && [ ${i:0:1} == "-" ]; then
		    opts+="$i"
		else
		    repo+="$i"
		fi
	    done
	    if [ -n "$opts" ] && [ "$opts" != " " ]; then
		git clone "$opts" "$repo"
	    else
		git clone "$repo"
	    fi
	else
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
plugin vim-closetag 		https://github.com/alvan/vim-closetag.git 
plugin vim-quicktask 		https://github.com/aaronbieber/vim-quicktask.git
plugin vim-surround 		git://github.com/tpope/vim-surround.git
plugin matchit              https://github.com/tmhedberg/matchit.git
plugin tabular              https://github.com/godlygeek/tabular.git
plugin vim-table-mode 		https://github.com/dhruvasagar/vim-table-mode.git
plugin vim-easy-motion      https://github.com/easymotion/vim-easymotion.git

[ ! -d ../plugin ] &&  mkdir ../plugin
[ ! -d ../doc ]    &&  mkdir ../doc
for file in "matchit/plugin/.[!.]*"; do
	[ ! -e "../plugin/$file" ] &&  ln -s "$(readlink -f matchit/plugin/$file)" ../plugin/
done
for file in "matchit/doc/.[!.]*"; do
	[ ! -e "../doc/$file" ] && ln -s "$(readlink -f matchit/doc/$file)"  ../doc/
done
popd >/dev/null
