#First make sure the directories exist and pathogen is downloaded
if [ ! -d $HOME/.vim ] || [ ! -d $HOME/.vim/autoload ]; then
	mkdir -p ~/.vim/autoload ~/.vim/bundle && \
		curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
fi
[ ! -d $HOME/.vim/bundle ] && mkdir $HOME/.vim/bundle

#Now download all the repos
oldwd=$(pwd) #I never trust 'cd -' in this things
cd $HOME/.vim/bundle


git clone --depth=1 https://github.com/vim-syntastic/syntastic.git
git clone git://github.com/tpope/vim-surround.git
git clone https://github.com/ctrlpvim/ctrlp.vim.git
git clone https://github.com/flazz/vim-colorschemes.git
git clone https://github.com/alvan/vim-closetag.git 
