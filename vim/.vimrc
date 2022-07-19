set nocompatible

"Install plugins {{{1
if ! exists('g:vim_home')
	let g:vim_home=$HOME."/.vim"
endif

" If there's a customs.vim file in the config directory, load it
if filereadable(g:vim_home."/customs.vim") && ! exists('g:loaded_customs')
	exec 'source '.g:vim_home."/customs.vim"
	let g:loaded_customs=1
endif

" Download vim plug if necessary
let s:data_path = has('nvim') ? stdpath('data') : '~/.vim'
let s:vimplug_dir = has('nvim') ? s:data_path . '/site' : s:data_path
let s:plugins_dir = s:data_path . '/plugged'
let s:plug_install = 0
if empty(glob(s:vimplug_dir . '/autoload/plug.vim')) && executable('curl')
	silent execute '!curl -fLo '.s:vimplug_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	execute ':source '.s:vimplug_dir.'/autoload/plug.vim'
	let s:plug_install = 1
endif

" install new plugins if necessary
" autocmd VimEnter *
" 	\ if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) |
" 	\     PlugInstall --sync | source $MYVIMRC |
" 	\ endif

call plug#begin()
Plug 'alvan/vim-closetag', { 'for': 'html' }
Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'flazz/vim-colorschemes'
Plug 'jiangmiao/auto-pairs'
Plug 'PotatoesMaster/i3-vim-syntax'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'sjl/gundo.vim'
Plug 'tmhedberg/matchit'
Plug 'skywind3000/asyncrun.vim', { 'on': 'AsyncRun' }
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive', { 'on': 'Git' }
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'christoomey/vim-tmux-navigator'
Plug 'puremourning/vimspector', { 'on': 'VimspectorReset' }
Plug 'sagi-z/vimspectorpy', { 'on': 'VimspectorReset' }
Plug 'szw/vim-maximizer', { 'on': 'MaximizerToggle' }

if has('nvim')
	Plug 'nvim-lua/plenary.nvim'
	Plug 'nvim-treesitter/nvim-treesitter'
	Plug 'nvim-telescope/telescope.nvim', { 'on': 'Telescope' }

	Plug 'neovim/nvim-lspconfig'
	Plug 'hrsh7th/nvim-cmp'
	Plug 'hrsh7th/cmp-nvim-lsp'
	Plug 'saadparwaiz1/cmp_luasnip'
	Plug 'L3MON4D3/LuaSnip'
endif

call plug#end()

if s:plug_install
	PlugInstall --sync
	quit
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
set shell=bash            " For external commands run with :!
set showtabline=2 		  " Always display the tabline
set gdefault 			  " Always use /g in substitute commands
set wildmenu 			  " Show file autocomplete list above the status line
set cursorline			  " Highlight the line where the cursor is
set scrolloff=2 		  " Number of lines to show above the cursor when scrolling
set cmdheight=2 		  " Size of the command line
set splitright
set ttyfast
set clipboard=unnamedplus " Use system clipboard as default buffer (requires gvim)
set wildmode=list:longest,list:full

"Disable syntastic (it's builtin to ArchLinux)
let g:loaded_syntastic_plugin = 1
"1}}}

"Formatting {{{1
"Folding stuff {{{2
set foldmethod=syntax
set foldnestmax=1
set foldlevelstart=99
set foldenable

" Toggle folds with <Space>
nnoremap <Space> za
"2}}}

"Searching options {{{2
set nohlsearch
set incsearch
set ignorecase
set smartcase
set infercase
"2}}}

"Display line numbers{{{2
set number
"2}}}

"Set tab indendantion size{{{2
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab
"2}}}

"1}}}

" Temporary files {{{1
"Store temp files in .vim instead of every fucking folder in the system
set undofile
set backup
set swapfile

"Some default directories to avoid cluttering up every folder
if exists('*mkdir')
	function! Mkdir(name)
		let l:path = g:vim_home."/".a:name
		if !isdirectory(resolve(l:path))
			try
				call mkdir(l:path, "p", 0775)
			catch
				let l:path = "/tmp/.vim_".a:name
				if !isdirectory(resolve(l:path))
					call mkdir(l:path, "p", 0775)
				endif
			endtry
		endif
		return l:path
	endfunction

	let &undodir = Mkdir("undo")
	let &backupdir = Mkdir("backup")
	let &directory = Mkdir("swp")
endif

" Don't create backups when editing files in certain directories
set backupskip=/tmp/*
"1}}}

" Plugin options {{{1
" Netrw {{{2
let g:netrw_browse_split=3 	"Open files in a new tab
let g:netrw_altv=1 			"Open vertical splits to the right
let g:netrw_alto=1 			"Open horizontal splits below
"let g:netrw_banner=0 		"Disable annoying banner
let g:netrw_liststyle=3 	"Tree style view
"2}}}

" Easymotion {{{2
" Use uppercase target labels and type as a lower case
let g:EasyMotion_use_upper = 1
"
" type `l` and match `l`&`L`
let g:EasyMotion_smartcase = 1

" Smartsign (type `3` and match `3`&`#`)
let g:EasyMotion_use_smartsign_us = 1

"<Leader>f{char} to move to {char}
" nnoremap  <Leader><Leader>n <Plug>(easymotion-bd-f)

"<Leader>l to move to line
" nnoremap  <Leader><Leader>l <Plug>(easymotion-bd-jk)

"<Leader>w to move to word
" nnoremap  <Leader><Leader>w <Plug>(easymotion-bd-w)

" Override color highlighting
if $LIGHT_THEME != '' && $LIGHT_THEME != 'false'
	highlight EasyMotionTarget cterm=bold ctermbg=none ctermfg=DarkRed
	highlight EasyMotionTarget2First  cterm=bold ctermbg=none ctermfg=DarkGreen
	highlight EasyMotionTarget2Second cterm=bold ctermbg=none ctermfg=DarkGreen
endif
"2}}}

" Telescope {{{2
if exists(':Telescope')
	nnoremap <leader>/ :Telescope live_grep<CR>
	nnoremap <leader>* :Telescope grep_string<CR>
	nnoremap <C-p> :Telescope find_files<CR>
	nnoremap <leader>b :Telescope buffers<CR>
	nnoremap <leader>go :Telescope jumplist<CR>
	nnoremap <leader>t :Telescope tags<CR>
else
	nnoremap <leader>t :tag 
endif
" 2}}}

" NERDTree {{{2
nnoremap <leader>. :NERDTreeToggle<CR>

let NERDTreeShowHidden = 1
let NERDTreeIgnore=['\.swp$', '\.swo$', '\~$', '\.tags$', '^\.git$', '\.pyc$', '__pycache__', '\.o$', '^\.tox$', '^\.pytest_cache$', '^\.vimsession$', '\.mypy_cache$', '\.venv$']
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

" Tmux navigator {{{2
let g:tmux_navigator_save_on_switch = 1
let g:tmux_navigator_disable_when_zoomed = 1
let g:tmux_navigator_no_mappings = 1
"2}}}

"Use easier navigation keybindings if tmux is not active (would interfere with my config there){{{2
if exists(":TmuxNavigateRight") && $TMUX != ""
	" Switch between panes with M+vim keys or M+arrow keys
	if ! has('nvim')
		nnoremap <silent> l  :TmuxNavigateRight<cr>
		nnoremap <silent> j  :TmuxNavigateDown<cr>
		nnoremap <silent> k  :TmuxNavigateUp<cr>
		nnoremap <silent> h  :TmuxNavigateLeft<cr>

		nnoremap <silent> <Left>  :TmuxNavigateLeft<cr>
		nnoremap <silent> <Down>  :TmuxNavigateDown<cr>
		nnoremap <silent> <Up>    :TmuxNavigateUp<cr>
		nnoremap <silent> <Right> :TmuxNavigateRight<cr>
	else
		nnoremap <silent> <A-l>  :TmuxNavigateRight<cr>
		nnoremap <silent> <A-j>  :TmuxNavigateDown<cr>
		nnoremap <silent> <A-k>  :TmuxNavigateUp<cr>
		nnoremap <silent> <A-h>  :TmuxNavigateLeft<cr>

		nnoremap <silent> <A-Left>  :TmuxNavigateLeft<cr>
		nnoremap <silent> <A-Down>  :TmuxNavigateDown<cr>
		nnoremap <silent> <A-Up>    :TmuxNavigateUp<cr>
		nnoremap <silent> <A-Right> :TmuxNavigateRight<cr>
	endif
else
	" Ctrl + Arrow keys to resize windows
	if ! has ('nvim')
		noremap Oa 	:resize +5<CR>
		noremap Ob 	:resize -5<CR>
		noremap Od 	:vertical resize +5<CR>
		noremap Oc 	:vertical resize -5<CR>

		" Shift + Left|Right to switch buffers
		nnoremap [d 	:bprevious<CR>
		nnoremap [c	:bnext<CR>

		" Shift + Up|Down to move lines up and down
		nnoremap [a	:move .+1<CR>==
		nnoremap [b	:move .-2<CR>==
		inoremap [a	<Esc>:move .+1<CR>==gi
		inoremap [b	<Esc>:move .-2<CR>==gi
		vnoremap [a	:move '>+1<CR>gv=gv
		vnoremap [b	:move '<-2<CR>gv=gv

		" Alt + direction to move between panes
		nnoremap <silent> l  <C-w>l
		nnoremap <silent> j  <C-w>j
		nnoremap <silent> k  <C-w>k
		nnoremap <silent> h  <C-w>h

		nnoremap <silent> <Left>  <C-w>h
		nnoremap <silent> <Down>  <C-w>j
		nnoremap <silent> <Up>    <C-w>k
		nnoremap <silent> <Right> <C-w>l
	else
		" Ctrl + Arrow keys to resize windows
		nnoremap <C-Up>	:resize +5<CR>
		nnoremap <C-Down>	:resize -5<CR>
		nnoremap <C-Right>	:vertical resize +5<CR>
		nnoremap <C-Left>	:vertical resize -5<CR>

		" Shift + Left|Right to switch buffers
		nnoremap <S-Left>	:bprevious<CR>
		nnoremap <S-Right>	:bnext<CR>

		" Shift + Up|Down to move lines up and down
		nnoremap <S-Up>		:move .+1<CR>==
		nnoremap <S-Down>	:move .-2<CR>==
		inoremap <S-Up>		<Esc>:move .+1<CR>==gi
		inoremap <S-Down>	<Esc>:move .-2<CR>==gi
		vnoremap <S-Up>		:move '>+1<CR>gv=gv
		vnoremap <S-Down>	:move '<-2<CR>gv=gv

		" Alt + direction to move between panes
		nnoremap <silent> <A-l>  <C-w>l
		nnoremap <silent> <A-j>  <C-w>j
		nnoremap <silent> <A-k>  <C-w>k
		nnoremap <silent> <A-h>  <C-w>h

		nnoremap <silent> <A-Left>  <C-w>h
		nnoremap <silent> <A-Down>  <C-w>j
		nnoremap <silent> <A-Up>    <C-w>k
		nnoremap <silent> <A-Right> <C-w>l
	endif
endif
" 2}}}

" Tmux runner {{{2
let g:VtrAppendNewline = 1

" Use default mappings. More info at :h VtrUseVtrMaps
let g:VtrUseVtrMaps = 1

augroup pythonopts
	autocmd!
	autocmd BufNewFile,BufRead *.py let g:VtrStripLeadingWhitespace = 0
augroup END
" 2}}}

" Gundo {{{2
nnoremap <F5> :GundoToggle<CR>
" 2}}}

" Closetag {{{2
" Also close tags in xml files
let g:closetag_filenames = '*.html,*.xml'
" 2}}}

" Airline {{{2
let g:airline_highlighting_cache = 1
let g:airline_detect_modified = 1
let g:airline_detect_paste = 1
let g:airline_theme = 'tomorrow'
let g:airline_powerline_fonts = 1
"2}}}

"AsyncRun {{{2
" Command to run when the job is finished
let g:asyncrun_exit='echo "Async Run job completed"'

let s:asyncrun_support = 0

" check has advanced mode
if (v:version >= 800 || has('patch-7.4.1829')) && (!has('nvim'))
	if has('job') && has('channel') && has('timers') && has('reltime')
		let s:asyncrun_support = 1
	endif
elseif has('nvim')
	let s:asyncrun_support = 1
endif

if s:asyncrun_support
	" Define command :Make that will asynchronously run make
	command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>

	" Run the current file
	nnoremap <leader>py :execute('AsyncRun python '.shellescape(expand('%')))<CR>
endif
"2}}}
"1}}}

" Colors and stuff {{{1
"Color schemes {{{2
if !exists('*SetColorscheme')
	function! SetColorScheme(themes)
		for theme in a:themes
			try
				execute 'colorscheme '.theme
				break
			catch
			endtry
		endfor
	endfunc
endif

if !exists('*ColorChange')
	function! ColorChange()
		if isdirectory(g:vim_home."/bundle/vim-colorschemes/colors") && &rtp =~ '/vim-colorschemes/'
			let s:light_themes = g:light_themes
			let s:dark_themes  = g:dark_themes
		else
			let s:light_themes = g:light_themes_default
			let s:dark_themes  = g:dark_themes_default
		endif

		let scheme = execute(':colorscheme')
		let scheme = substitute (scheme, '[[:cntrl:]]', '', 'g')

		if index(s:light_themes, scheme) != -1
			let themes = s:dark_themes
			set background=dark
		elseif index(s:dark_themes, scheme) != -1
			let themes = s:light_themes
			set background=light
		else
			return
		endif

		call SetColorScheme(themes)
	endfunc
endif

let g:light_themes = ['PaperColor', 'lucius', 'github']
let g:dark_themes = ['Tomorrow-Night', 'cobalt2', 'hybrid_material', 'molokai', 'delek', 'seti', 'brogrammer', 'warm_grey']
let g:light_themes_default = ['morning', 'default']
let g:dark_themes_default = ['industry', 'koehler', 'desert', 'default']

if isdirectory(s:plugins_dir.'/vim-colorschemes')
	let s:light_themes = g:light_themes
	let s:dark_themes  = g:dark_themes
else
	let s:light_themes = g:light_themes_default
	let s:dark_themes  = g:dark_themes_default
endif

if $LIGHT_THEME != '' && $LIGHT_THEME != 'false'
	let s:themes = s:light_themes
	set background=light
else
	let s:themes = s:dark_themes
	set background=dark
endif

call SetColorScheme(s:themes)
"2}}}
" 1}}}

"Other junk {{{1
" Macros {{{2

" Macros are now stored in the ftplugin folder, since they are only useful for
" particular file types

"Repeat last recorded macro
nnoremap Q @@

"2}}}

"Ctags stuff {{{2
if exists(':AsyncRun') && s:asyncrun_support
	nnoremap <leader>ct :AsyncRun rm -f .tags && ctags -R .
else
	nnoremap <leader>ct :!ctags -R .<CR><CR>:echo "Generated tags"<CR>
	nnoremap <leader>ct! :!ctags -R .<CR>
endif

set tags=.tags,tags;/

" F9 to jump to tag
nnoremap <F9> <C-]>zz
nnoremap gt <C-]>zz
" Shift+F9 to get a list of matching tags
nnoremap [33~] :echo "Hello world"<CR>


"2}}}

"Correct typos {{{2
"Avoid showing the command line prompt when typing q: (which is probably a typo for (:q)
nnoremap q: :q<CR>

"Some command mode aliases to avoid going crazy
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall

"Correct some common typos in insert mode
inoreabbrev lenght length
inoreabbrev reciever receiver
inoreabbrev infomer informer
inoreabbrev osbrian osbrain
inoreabbrev emtpy empty
inoreabbrev acesible accessible
inoreabbrev acessible accessible
inoreabbrev accesible accessible

"Avoid showing help when F1 is pressed (you probably wanted to press Esc).  That menu is still accessible via :help anyway
nnoremap <F1> <Nop>
inoremap <F1> <Nop>
vnoremap <F1> <Nop>
"2}}}
"1}}}

"Custom commands{{{1
if !exists('*WriteReload')
	function! WriteReload()
		write
		source $MYVIMRC
	endfunc
endif

"Custom commands{{{2
command! WR call WriteReload()
command! WReload call WriteReload()
command! ColorChange call ColorChange()
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
nnoremap + :bnext<CR>
nnoremap - :bprev<CR>
function! GoFile()
	try
		" if a file can be found, with optional suffix, open it
		normal! gf
	catch
		" otherwise, create the file pointed to
		execute ':e ' . expand('<cfile>')
	endtry
endfunc
nnoremap gf :call GoFile()<CR>
"2}}}

"Repeat last colon command {{{2
nnoremap ñ @:
vnoremap ñ @:
nnoremap \ @:
"2}}}

" Git commands on the current file {{{2
nnoremap <leader>gco :silent execute "!git checkout ".expand('%t') \| edit! <CR>
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

"Splits {{{2
" Resize splits
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>

" Open horizontal splits below, vertical ones to the right
set splitbelow
set splitright
"2}}}
"
"Edit vimrc {{{2
nnoremap <leader>ev :vsplit ~/.vimrc<CR>
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
augroup fileTypes
	autocmd!
	autocmd BufNewFile,BufRead *.bats set filetype=sh
	autocmd BufNewFile,BufRead *.bash_prompt set filetype=sh
	autocmd BufNewFile,BufRead *.bash_customs set filetype=sh
	autocmd BufNewFile,BufRead *.csv set filetype=csv
	autocmd BufNewFile,BufRead *.ts set filetype=typescript
	autocmd BufNewFile,BufRead *.mqh set filetype=cpp
	autocmd BufNewFile,BufRead *.mq4 set filetype=cpp
	autocmd BufNewFile,BufRead Pipfile set filetype=dosini
	autocmd BufNewFile,BufRead *.toml set filetype=dosini
	autocmd BufNewFile,BufRead *.gitcredentials set filetype=gitconfig
	autocmd BufNewFile,BufRead Jenkinsfile set filetype=groovy
	autocmd BufNewFile,BufRead *.wsgi set filetype=python
augroup END

"1}}}
" vim:tw=0:fdm=marker:noexpandtab
