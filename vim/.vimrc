"Run pathogen
"call pathogen#runtime_append_all_bundles()
call pathogen#infect()
call pathogen#helptags()

"Some general options
let mapleader = "\<Space>"
filetype plugin indent on
syntax on
set encoding=utf-8

"Display line numbers
set number
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE


"Set tab indendantion size
set shiftwidth=4

"Default color scheme
if isdirectory($HOME."/.vim/bundle/vim-colorschemes")
	colorscheme cobalt2
	"colorscheme molokai
	"colorscheme delek
	"colorscheme seti
	"colorscheme default
	"colorscheme brogrammer
	"colorscheme warm_grey
endif

"Custom commands
command! R so $MYVIMRC
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
"if filereadable("/usr/lib/python2.7/site-packages/powerline/bindings/vim/plugin/powerline.vim")
let powerline_binding=$POWERLINE_ROOT."/bindings/vim/plugin/powerline.vim"
if filereadable(powerline_binding)
	set rtp+=powerline_binding
	python from powerline.vim import setup as powerline_setup
	python powerline_setup()
	let g:Powerline_symbols = 'fancy'
"	let g:Powerline_symbols='unicode'
	set laststatus=2
	set t_Co=256
endif


"Some syntastic options
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_loc_list_height = 5
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1

let g:syntastic_error_symbol = '❌'
let g:syntastic_style_error_symbol = '⁉️'
let g:syntastic_warning_symbol = '⚠️'

let g:sytastic_c_compiler = 'gcc'
let g:sytastic_c_compiler_options = '-std=c99 -Wall -Wextra'
let g:sytastic_c_no_default_include_dirs = 1
let g:sytastic_c_auto_refresh_includes = 1

let g:sytastic_cpp_compiler = 'g++'
let g:sytastic_cpp_compiler_options = '-std=c++14 -Wall -Wextra'
let g:sytastic_cpp_no_default_include_dirs = 1
let g:sytastic_cpp_auto_refresh_includes = 1

highlight link SyntasticErrorSign SignColumn
highlight link SyntasticWarningSign SignColumn
highlight link SyntasticStyleErrorSign SignColumn
highlight link SyntasticStyleWarningSign SignColumn


"Stop j and k from skipping wrapped lines
nmap j gj
nmap k gk

"Highlight results as you type and match only uppercase
set incsearch
set ignorecase
set smartcase

"Switch between buffers
nmap <C-b> :b#<CR> 
nmap <C-n> :bnext<CR>
nmap <C-p> :bprev<CR>

"CtrlP bindings and options
set runtimepath^=~/.vim/bundle/ctrlp.vim
nmap <C-o> :CtrlP<CR>
nmap <C-i> :CtrlP ~<CR>
nmap <ñ>   :CtrlPBuffer

let g:ctrlp_working_path_mode = 'car'
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|tar|tgz|zip|ko|gz)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'

"Switch between indent and wrap modes
:nmap \t :set expandtab tabstop=4 shiftwidth=4 softtabstop=4<CR>
:nmap \T :set expandtab tabstop=8 shiftwidth=8 softtabstop=4<CR>
:nmap \M :set noexpandtab tabstop=8 softtabstop=4 shiftwidth=4<CR>
:nmap \m :set expandtab tabstop=2 shiftwidth=2 softtabstop=2<CR>
:nmap \w :setlocal wrap!<CR>:setlocal wrap?<CR>


