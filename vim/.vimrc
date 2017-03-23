"Run pathogen {{{1
if filereadable ($HOME."/.vim/autoload/pathogen.vim")
	call pathogen#infect()
	call pathogen#helptags()
endif
"}}}

"Some general options {{{1
let mapleader = ','
filetype plugin indent on
syntax on
set encoding=utf-8
set fileencoding=utf-8
set t_Co=256

set laststatus=2          " Always display the status line
set autowrite
set autoread 			  " Auto reload files when changed outside of vim
set diffopt+=iwhite       " Ignore whitespaces in vimdiff
set shell=bash            " For external commands run with :!
set showtabline=2 		  " Always display the tabline
set gdefault 			  " Always use /g in substitute commands
set wildmenu 			  " Show file autocomplete list above the status line
set cursorline 			  " Highlight the line where the cursor is 
set scrolloff=2 		  " Number of lines to show above the cursor when scrolling
set cmdheight=2 		  " Size of the command line
set splitright
set ttyfast
set nocompatible
set clipboard=unnamedplus " Use system clipboard as default buffer (requires gvim)
"}}}

"Formatting {{{1
"Folding stuff {{{2
set foldmethod=syntax
set foldnestmax=1
set foldlevelstart=99
set foldenable
au BufRead .vimrc set foldmethod=marker 

"Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za
"2}}}

"Searching options {{{2
"set hlsearch
set incsearch
set ignorecase
set smartcase
set infercase
"2}}}

"Display line numbers{{{2
set relativenumber
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE
"2}}}

"Set tab indendantion size{{{2
set shiftwidth=4
set tabstop=4
"2}}}

"1}}}

" Colors and stuff {{{1

"Color schemes{{{2
if isdirectory($HOME."/.vim/bundle/vim-colorschemes/colors")
	if filereadable($HOME."/.vim/bundle/vim-colorschemes/colors/Tomorrow-Night.vim")
		colorscheme Tomorrow-Night
	elseif filereadable($HOME."/.vim/bundle/vim-colorschemes/colors/cobalt2.vim")
		colorscheme cobalt2
	elseif filereadable($HOME."/.vim/bundle/vim-colorschemes/colors/hybrid_material.vim")
		colorscheme hybrid_material
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
"2}}}

"Change the colour of the cursor{{{2
if &term =~ "xterm\\|rxvt\\|gnome-terminal"
	" use an orange cursor in insert mode
	let &t_SI = "\<Esc>]12;orange\x7"
	" use a red cursor otherwise
	let &t_EI = "\<Esc>]12;red\x7"
	silent !echo -ne "\033]12;red\007"
	" reset cursor when vim exits (assuming it was white before)
	autocmd VimLeave * silent !echo -ne '\033]12;white\007' 
endif
"2}}}

"Use powerline {{{2
if has('python')
	let g:powerline_no_python_error = 1
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
endif
"2}}}

" 1}}}

" Temporary files {{{1
"Some default directories to avoid cluttering up every folder
if !isdirectory($HOME."/.vim/undo")
	call mkdir($HOME."/.vim/undo", "", 0700)
endif
if !isdirectory($HOME."/.vim/backup")
	call mkdir($HOME."/.vim/backup", "", 0700)
endif
if !isdirectory($HOME."/.vim/swp")
	call mkdir($HOME."/.vim/swp", "", 0700)
endif

"Store temp files in .vim instead of every fucking folder in the system
set undofile
set backup
set swapfile

set undodir=~/.vim/undo
set backupdir=~/.vim/backup
set directory=~/.vim/swp
"1}}}

"Other junk {{{1
" Macros {{{2

" Macros are now saved in the ftplugin folder, since they are only useful for
" particular file types

"Repeat last recorded macro
nnoremap Q @@

"2}}}

"Ctags stuff {{{2
nnoremap <leader>t  :tag 
set tags=.tags,tags;/
"2}}}

"Correct typos {{{2
"Avoid showing the command line prompt when typing q: (which is probably a typo for (:q)
nnoremap q: :q<CR>

"Avoid showing help when F1 is pressed (you probably wanted to press Esc).  That menu is still accessible with :help anyway
noremap <F1> <Nop>
"2}}}

"1}}}

"Custom commands{{{1
"Custom commands{{{2
command! R so $MYVIMRC
command! Reload so $MYVIMRC
command! Relativenumbers call Relativenumbers()
command! Wr call WriteReload()
command! WR call WriteReload()
command! WReload call WriteReload()
command! Foldmode call FoldMethod()
command! Vimrc :vsplit $MYVIMRC
"2}}}

"And some keybindings for those commands {{{2
nnoremap <leader>wr :call WriteReload()<CR>
nnoremap <leader>ct :!ctags -R .<CR><CR>:echo "Generated tags"<CR>
nnoremap <leader>ct! :!ctags -R .<CR>
nnoremap <leader>a @a
nnoremap <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <leader>es :split $MYVIMRC<CR>
nnoremap <leader>eb :e $MYVIMRC<CR>
"2}}}

"1}}}

" Some remappings that have no other good place {{{1
"Stop j and k from skipping wrapped lines{{{2
nmap j gj
nmap k gk
vmap j gj
vmap k gk
"2}}}

"Switch between buffers{{{2
nnoremap <C-b> :b#<CR> 
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprev<CR>
"2}}}

"Move lines up and down with Ctrl-j and Ctrl-k {{{2
nnoremap <C-j> :move .+1<CR>==
nnoremap <C-k> :move .-2<CR>==
inoremap <C-j> <Esc>:move .+1<CR>==gi
inoremap <C-k> <Esc>:move .-2<CR>==gi
vnoremap <C-j> :move '>+1<CR>gv=gv
vnoremap <C-k> :move '<-2<CR>gv=gv
"2}}}

"Quicker window movement {{{2
nnoremap <leader>f  <C-w>j
nnoremap <leader>d  <C-w>k
nnoremap <leader>g  <C-w>l
nnoremap <leader>s  <C-w>h
"2}}}

"Make scrolling a little bit faster {{{2
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>
"2}}}

"Resizing splits {{{2
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>
"2}}}

"Use easier navigation keybindings if tmux is not active (would interfere with my config there){{{2
let tmux_active=$TMUX
if tmux_active==""
	" Alt + Arrow keys for window movement
	noremap <Down>  <C-w>j
	noremap <Up>    <C-w>k
	noremap <Left>  <C-w>h
	noremap <Right> <C-w>l

	" Ctrl + Arrow keys to resize windows
	noremap Oa 	  :resize +5<CR>
	noremap Ob 	  :resize -5<CR>
	noremap Od 	  :vertical resize +5<CR>
	noremap Oc 	  :vertical resize -5<CR>

	" Shift + Left|Right to switch buffers
	nnoremap [d  :bprevious<CR>
	nnoremap [c  :bnext<CR>

	" Shift + Up|Down to move lines up and down
	nnoremap [a :move .+1<CR>==
	nnoremap [b :move .-2<CR>==
	inoremap [a <Esc>:move .+1<CR>==gi
	inoremap [b <Esc>:move .-2<CR>==gi
	vnoremap [a :move '>+1<CR>gv=gv
	vnoremap [b :move '<-2<CR>gv=gv
endif
"2}}}
"1}}}

" Autocommands that have no other good place {{{1
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

" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

" Detect weird file types
au BufNewFile,BufRead *.bash_prompt set filetype=sh

" Enable bash folding
au FileType sh let g:sh_fold_enabled=1
au FileType sh let g:is_bash=1
syntax enable

"1}}}

" Plugin options {{{1
"" Netrw {{{2
let g:netrw_browse_split=3 	"Open files in a new tab
let g:netrw_altv=1 			"Open vertical splits to the right
let g:netrw_alto=1 			"Open horizontal splits below
"let g:netrw_banner=0 		"Disable annoying banner
let g:netrw_liststyle=3 	"Tree style view
"2}}}

" Syntastic {{{2

" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

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
" 2}}}

" Easymotion {{{2

"<Leader>f{char} to move to {char}
noremap  <Leader>n <Plug>(easymotion-bd-f)
nnoremap <Leader>n <Plug>(easymotion-overwin-f)

"<Leader>l to move to line
noremap  <Leader>l <Plug>(easymotion-bd-jk)
nnoremap <Leader>l <Plug>(easymotion-overwin-line)

"<Leader>w to move to word 
noremap  <Leader>w <Plug>(easymotion-bd-w)
nnoremap <Leader>w <Plug>(easymotion-overwin-w)
"2}}}

"CtrlP 2{{{
set runtimepath^=~/.vim/bundle/ctrlp.vim
nnoremap <F8> :CtrlPTag <CR>
nnoremap <F9> <C-]>

let g:ctrlp_working_path_mode = 'car'
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|tar|tgz|zip|ko|gz)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
"2}}}

" NERDTree {{{2
let NERDTreeShowHidden = 1
let NERDTreeIgnore=['\.swp$', '\.swo$', '\~$', '\.tags$', '^\.git$', '^\.gitignore$', '\.pyc$']
nnoremap <leader>. :NERDTreeToggle<CR>
" Open nerdtree on startup
"autocmd VimEnter *
"			\ NERDTree |
"			\ if argc() >= 1 |
"			\ 	wincmd p |
"			\ endif
" Close nerdtree when closing vim
autocmd BufEnter *
			\ if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) |
			\ 	quit |
			\ endif
"2}}}

"1}}}

"Functions {{{1
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

if !exists('*WriteReload')
	function! WriteReload() 
		write
		so $MYVIMRC 
	endfunc
endif

function! FoldMethod()
	if (&foldmethod == "syntax")
		set foldmethod=indent
	elseif (&foldmethod == "indent")
		set foldmethod=syntax
	endif

	echo "Foldmethod set to ".&foldmethod
endfunc
"2}}}
