"""""""""""""""" VUNDLE OPTIONS """""""""""

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"Plugins
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:airline_theme='luna'

call vundle#end()

""""""""""""""""""""""""""""""""""

let mapleader = "\<Space>"
filetype plugin indent on
syntax on
set encoding=utf-8



"Custom commands
command! Reload so $MYVIMRC

"Move lines up and down with Ctrl-j and Ctrl-k
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

"Use system clipboard as default buffer (requires gvim)
set clipboard=unnamedplus

"Use powerline
python from powerline.vim import setup as powerline_setup
python powerline_setup()
set rtp+=/usr/lib/python3.5/site-packages/powerline/bindings/vim
let g:Powerline_symbols = 'fancy'
set laststatus=2
set t_Co=256

"Display line numbers
set number
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE
