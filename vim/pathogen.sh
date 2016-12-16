#First make sure the directories exist and pathogen is downloaded
if [ ! -f "$HOME/.vim/autoload/pathogen.vim" ]; then
	mkdir -p "$HOME/.vim/autoload" && \
		wget https://tpo.pe/pathogen.vim -P "$HOME/.vim/autoload/pathogen.vim" 
fi
[ ! -d "$HOME/.vim/bundle" ] && mkdir "$HOME/.vim/bundle"

plugin (){
	if ! [ -d "$1" ]; then
	    git clone "$*"
	else
	    pushd . >/dev/null
	    cd "$1"
	    git pull origin master
	    popd >/dev/null
	fi
}


#Now download all the repos
pushd . >/dev/null
cd "$HOME/.vim/bundle"

plugin syntastic 		--depth=1 https://github.com/vim-syntastic/syntastic.git
plugin ctrlp.vim 		https://github.com/ctrlpvim/ctrlp.vim.git
plugin vim-colorschemes 	https://github.com/flazz/vim-colorschemes.git
plugin vim-closetag 		https://github.com/alvan/vim-closetag.git 
plugin vim-quicktask 		https://github.com/aaronbieber/vim-quicktask.git
plugin vim-surround 		git://github.com/tpope/vim-surround.git
plugin matchit                  https://github.com/tmhedberg/matchit.git

[ ! -d ../plugin ] &&  mkdir ../plugin
[ ! -d ../doc ]    &&  mkdir ../doc
ln -s matchit/plugin/* ../plugin/
ln -s matchit/doc/*    ../doc/

popd >/dev/null
