#First make sure the directories exist and pathogen is downloaded
if [ ! -f "$HOME/.vim/autoload/pathogen.vim" ]; then
	mkdir -p "$HOME/.vim/autoload" && \
		wget https://tpo.pe/pathogen.vim -P "$HOME/.vim/autoload/pathogen.vim" 
fi
[ ! -d $HOME/.vim/bundle ] && mkdir $HOME/.vim/bundle

#Now download all the repos
pushd . >/dev/null
cd "$HOME/.vim/bundle"


[ ! -d syntastic ]        && git clone --depth=1 https://github.com/vim-syntastic/syntastic.git
[ ! -d ctrlp.vim ]        && git clone https://github.com/ctrlpvim/ctrlp.vim.git
[ ! -d vim-surround ]     && git clone git://github.com/tpope/vim-surround.git
[ ! -d vim-colorschemes ] && git clone https://github.com/flazz/vim-colorschemes.git
[ ! -d vim-closetag ]     && git clone https://github.com/alvan/vim-closetag.git 

popd >/dev/null
