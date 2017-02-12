"Run pathogen
"call pathogen#runtime_append_all_bundles()
call pathogen#infect()
call pathogen#helptags()

"Some general options
"let mapleader = '\<Space>'
let mapleader = ','
filetype plugin indent on
syntax on
set encoding=utf-8
set laststatus=2          " Always display the status line
set autowrite
set nu                    " Set relative number
set diffopt+=iwhite       " Ignore whitespaces in vimdiff
set shell=bash            " For external commands run with :!
set showtabline=2 		  " Always display the tabline

"Folding stuff
set foldmethod=syntax
set foldnestmax=1
set foldlevelstart=99

"Space to toggle folds.
nnoremap <Space> zA
vnoremap <Space> zA

"Highlight results as you type and match only uppercase
set incsearch
set ignorecase
set smartcase

"Display line numbers
"set relativenumber
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

"Set tab indendantion size
set shiftwidth=4
set tabstop=4

"Stop j and k from skipping wrapped lines
nmap j gj
nmap k gk


"Switch between buffers
nmap <C-b> :b#<CR> 
nmap <C-n> :bnext<CR>
nmap <C-p> :bprev<CR>


"Default color scheme
if isdirectory($HOME."/.vim/bundle/vim-colorschemes")
	if filereadable($HOME."/.vim/bundle/vim-colorschemes/colors/cobalt2.vim")
		colorscheme cobalt2
	elseif filereadable($HOME."/.vim/bundle/vim-colorschemes/colors/molokai.vim")
		colorscheme molokai
	elseif filereadable($HOME."/.vim/bundle/vim-colorschemes/colors/delek.vim")
		colorscheme delek
	elseif filereadable($HOME."/.vim/bundle/vim-colorschemes/colors/seti.vim")
		colorscheme seti
	elseif filereadable($HOME."/.vim/bundle/vim-colorschemes/colors/brogrammer.vim")
		colorscheme brogrammer
	elseif filereadable($HOME."/.vim/bundle/vim-colorschemes/colors/warm_grey.vim")
		colorscheme warm_grey
	endif
endif



"Custom commands
command! R so $MYVIMRC
command! Reload so $MYVIMRC
command! Relativenumbers call Relativenumbers()
command! Wr call WriteReload()
command! WR call WriteReload()
command! WReload call WriteReload()
command! Foldmode call FoldMethod()
command! Vimrc :vsplit $MYVIMRC

"And some keybindings for those commands
nnoremap <leader>wr :call WriteReload()<CR>
nnoremap <leader>ct :!ctags -R .<CR><CR>:echo "Generated tags"<CR>
nnoremap <leader>ct! :!ctags -R .<CR>
nnoremap <leader>a @a
nnoremap <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <leader>es :split $MYVIMRC<CR>
nnoremap <leader>eb :e $MYVIMRC<CR>

"" Some macros worth saving 
"Indent the current block of {}
let @y='/}v%0='


"Event handlers ¿? (sort of)
au FocusLost * set number
au FocusGained * set relativenumber

"Set absolute numbers when on insert mode
autocmd InsertEnter * set number
autocmd InsertLeave * set relativenumber

"Force filetype detection

"Avoid showing the command line prompt when typing q: (which is probably a
"typo for (:q)
nnoremap q: :q<CR>

" When editing a file, always jump to the last known cursor position.
" Don't do it for commit messages, when the position is invalid, or when
" inside an event handler (happens when dropping a file on gvim).
augroup vimrcEx
	autocmd!
	autocmd BufReadPost *
				\ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
				\   exe "normal g`\"" |
				\ endif

augroup END

"Move lines up and down with Ctrl-j and Ctrl-k
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

"Use system clipboard as default buffer (requires gvim)
set clipboard=unnamedplus

"Quicker window movement
nnoremap <leader>f  <C-w>j
nnoremap <leader>d  <C-w>k
nnoremap <leader>g  <C-w>l
nnoremap <leader>s  <C-w>h

"Resizing splits
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>

"Ctags stuff
nnoremap <leader>t  :tag 
set tags=.tags,tags;/

"Use powerline
"if filereadable("/usr/lib/python2.7/site-packages/powerline/bindings/vim/plugin/powerline.vim")
let powerline_binding=$POWERLINE_ROOT."/bindings/vim/plugin/powerline.vim"
if filereadable(powerline_binding)
	set rtp+=powerline_binding
	python from powerline.vim import setup as powerline_setup
	python powerline_setup()
	let g:Powerline_symbols = 'fancy'
	let g:Powerline_symbols='unicode'
	set laststatus=2
	set t_Co=256
	set noshowmode "Hide the default mode text below the statusline
endif


"" Some syntastic options

"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_loc_list_height = 5
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1


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


""A few options for easymotion

"<Leader>f{char} to move to {char}
noremap  <Leader>n <Plug>(easymotion-bd-f)
nnoremap <Leader>n <Plug>(easymotion-overwin-f)

"<Leader>l to move to line
noremap  <Leader>l <Plug>(easymotion-bd-jk)
nnoremap <Leader>l <Plug>(easymotion-overwin-line)

"<Leader>w to move to word 
noremap  <Leader>w <Plug>(easymotion-bd-w)
nnoremap <Leader>w <Plug>(easymotion-overwin-w)


"CtrlP bindings and options
set runtimepath^=~/.vim/bundle/ctrlp.vim
nnoremap <F8> :CtrlPTag <CR>sdfasdfasdfasdfasdf
nnoremap <F9> <C-]>

let g:ctrlp_working_path_mode = 'car'
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|tar|tgz|zip|ko|gz)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'


"NERDTree options
let NERDTreeShowHidden = 1
autocmd VimEnter * NERDTree 

"Switch between indent and wrap modes
nmap \t :set expandtab tabstop=4 shiftwidth=4 softtabstop=4<CR>
nmap \T :set expandtab tabstop=8 shiftwidth=8 softtabstop=4<CR>
nmap \M :set noexpandtab tabstop=8 softtabstop=4 shiftwidth=4<CR>
nmap \m :set expandtab tabstop=2 shiftwidth=2 softtabstop=2<CR>
nmap \w :setlocal wrap!<CR>:setlocal wrap?<CR>


" Tab completion from https://github.com/thoughtbot/dotfiles/blob/master/vimrc
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
function! InsertTabWrapper()
	let col = col('.') - 1
	if !col || getline('.')[col - 1] !~ '\k'
		return "\<tab>"
	else
		return "\<c-p>"
	endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>

function! Relativenumbers()
	if(&relativenumber == 1)
		set nornu
		set number
	else
		set relativenumber
	endif
endfunc

if exists('*WriteReload')
	finish
endif
function! WriteReload() 
	write
	so $MYVIMRC 
endfunc

function! FoldMethod()
	if (&foldmethod == "syntax")
		set foldmethod=indent
	elseif (&foldmethod == "indent")
		set foldmethod=syntax
	endif

	echo "Foldmethod set to ".&foldmethod
endfunc
