"Run pathogen {{{1
"Disable syntastic (it's builtin to ArchLinux)
let g:loaded_syntastic_plugin = 1

if has('nvim')
	let g:vim_home=$HOME."/.config/nvim"
else
	let g:vim_home=$HOME."/.vim"
endif

set nocompatible

" set the runtime path to include Vundle and initialize
if isdirectory(g:vim_home."/bundle/Vundle.vim")
	filetype off
	let &rtp = &rtp.','.g:vim_home."/bundle/Vundle.vim"
	call vundle#begin(g:vim_home.'/bundle')

	Plugin 'VundleVim/Vundle.vim'
	Plugin 'skywind3000/asyncrun.vim'
	Plugin 'jiangmiao/auto-pairs'
	Plugin 'ctrlpvim/ctrlp.vim'
	Plugin 'sjl/gundo.vim'
	Plugin 'PotatoesMaster/i3-vim-syntax'
	Plugin 'tmhedberg/matchit'
	Plugin 'Neomake/Neomake'
	Plugin 'scrooloose/nerdtree'
	Plugin 'godlygeek/tabular'
	Plugin 'majutsushi/tagbar'
	Plugin 'leafgarland/typescript-vim'
	Plugin 'flazz/vim-colorschemes'
	Plugin 'alvan/vim-closetag'
	Plugin 'tpope/vim-commentary'
	Plugin 'christoomey/vim-conflicted'
	Plugin 'easymotion/vim-easymotion'
	Plugin 'editorconfig/editorconfig-vim'
	Plugin 'tpope/vim-fugitive'
	Plugin 'tpope/vim-repeat'
	Plugin 'tpope/vim-surround'
	Plugin 'kana/vim-textobj-entire'
	Plugin 'kana/vim-textobj-user'
	Plugin 'christoomey/vim-tmux-navigator'
	Plugin 'christoomey/vim-tmux-runner'

	if has('python')
		Plugin 'davidhalter/jedi-vim'
	endif

	if has('nvim')
		Plugin 'zchee/deoplete-jedi'
		let g:jedi#completions_enabled = 0
	endif

	if !has('python') || has('nvim')
		Plugin 'vim-airline/vim-airline'
		Plugin 'vim-airline/vim-airline-themes'
	endif

	filetype plugin indent on
	call vundle#end()
elseif filereadable (g:vim_home."/autoload/pathogen.vim") || filereadable (g:vim_home."/autoload/pathogen/pathogen.vim")
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
set shell=bash            " For external commands run with :!
set showtabline=2 		  " Always display the tabline
set gdefault 			  " Always use /g in substitute commands
set wildmenu 			  " Show file autocomplete list above the status line
set cursorline 			  " Highlight the line where the cursor is
set scrolloff=2 		  " Number of lines to show above the cursor when scrolling
set cmdheight=2 		  " Size of the command line
set splitright
set ttyfast
set clipboard=unnamedplus " Use system clipboard as default buffer (requires gvim)
" set diffopt+=iwhite       " Ignore whitespaces in vimdiff
"}}}

"Formatting {{{1
"Folding stuff {{{2
set foldmethod=syntax
set foldnestmax=1
set foldlevelstart=99
set foldenable

"Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za
"2}}}

"Searching options {{{2
set nohlsearch
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

" Temporary files {{{1
"Some default directories to avoid cluttering up every folder
if !isdirectory(resolve(g:vim_home."/undo"))
	call mkdir(g:vim_home."/undo", "", 0700)
endif

if !isdirectory(resolve(g:vim_home."/backup"))
	call mkdir(g:vim_home."/backup", "", 0700)
endif

if !isdirectory(resolve(g:vim_home."/swp"))
	call mkdir(g:vim_home."/swp", "", 0700)
endif

"Store temp files in .vim instead of every fucking folder in the system
set undofile
set backup
set swapfile


let &undodir=g:vim_home."/undo"
let &backupdir=g:vim_home."/backup"
let &directory=g:vim_home."/swp"

" Don't create backups when editing files in certain directories
set backupskip=/tmp/*
"1}}}

" Plugin options {{{1
if ! exists('*Plugin_exists')
	function! Plugin_exists(name)
		for s:path in split(&runtimepath, ",")
			let s:basename = tolower(split(s:path, '/')[-1])
			let s:find = tolower(a:name)
			if s:basename == s:find || s:basename == 'vim-'.s:find || s:basename == s:find.'.vim'
				return 1
			endif
		endfor
		return 0
	endfunc
endif

" Netrw {{{2
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

" Syntastic is super slow for python. Make it work on-demand
let g:syntastic_mode_map = {
			\ "mode": "active",
			\ "passive_filetypes": ["python"] }

" Ignore stupid warnings from pylint
let g:syntastic_python_pylint_quiet_messages = { "regex": ["missing\-docstring","bad\-whitespace","invalid\-name","no\-else\-return"] }

" Change the python version used for checking on the fly
if !exists('Py2')
	function! Py2()
		let g:syntastic_python_python_exec = '/usr/local/bin/python2'
	endfunc
endif
if !exists('Py3')
	function! Py3()
		let g:syntastic_python_python_exec = '/usr/local/bin/python3'
	endfunc
endif



highlight link SyntasticErrorSign SignColumn
highlight link SyntasticWarningSign SignColumn
highlight link SyntasticStyleErrorSign SignColumn
highlight link SyntasticStyleWarningSign SignColumn
" 2}}}

" Neomake {{{2
" When reading a buffer (after 1s), and when writing.
if Plugin_exists('Neomake') && ! Plugin_exists('Syntastic')
	call neomake#configure#automake('rw', 1000)
	if executable('pylint')
		let g:neomake_python_pylint_args = neomake#makers#ft#python#pylint()['args'] + ['-j', '4', '-d', 'C0330,R1705,W0703,E128']
	endif
endif

" 2}}}

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

"CtrlP {{{2
let g:ctrlp_working_path_mode = 'wr'
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|tar|tgz|zip|ko|gz)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
"2}}}

" NERDTree {{{2
if Plugin_exists('NERDTree')
	nnoremap <leader>. :NERDTreeToggle<CR>
endif

let NERDTreeShowHidden = 1
let NERDTreeIgnore=['\.swp$', '\.swo$', '\~$', '\.tags$', '^\.git$', '^\.gitignore$', '\.pyc$', '__pycache__','\.o$']
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

"Use easier navigation keybindings if tmux is not active (would interfere with my config there){{{2
if $TMUX==""
	if ! has ('nvim')
		" Ctrl + Arrow keys to resize windows
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
	else
		" Ctrl + Arrow keys to resize windows
		noremap <C-Up>		:resize +5<CR>
		noremap <C-Down>	:resize -5<CR>
		noremap <C-Right>	:vertical resize +5<CR>
		noremap <C-Left>	:vertical resize -5<CR>

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
	endif
else
	if Plugin_exists('Tmux-navigator')
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
			nnoremap <silent> <M-l>  :TmuxNavigateLeft<cr>
			nnoremap <silent> <M-j>  :TmuxNavigateDown<cr>
			nnoremap <silent> <M-k>  :TmuxNavigateUp<cr>
			nnoremap <silent> <M-h>  :TmuxNavigateRight<cr>

			nnoremap <silent> <M-Left>  :TmuxNavigateLeft<cr>
			nnoremap <silent> <M-Down>  :TmuxNavigateDown<cr>
			nnoremap <silent> <M-Up>    :TmuxNavigateUp<cr>
			nnoremap <silent> <M-Right> :TmuxNavigateRight<cr>
		endif
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
if Plugin_exists('gundo')
	nnoremap <F5> :GundoToggle<CR>
endif
" 2}}}

" Tagbar {{{2
if Plugin_exists('tagbar')
	nnoremap <F8> :TagbarToggle<CR>
endif

let g:tagbar_autofocus=1
let g:tagbar_autoshowtag=1
" }}}

" Over {{{2
" Substitute vim's %s with vim-over command line
if Plugin_exists('over')
	cabbrev %s OverCommandLine<CR>%s
	cabbrev '<,'>s OverCommandLine<CR>'<,'>s
endif
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


" Define command :Make that will asynchronously run make
if Plugin_exists('Asyncrun') && s:asyncrun_support
	command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>
endif
"2}}}
"1}}}

" Colors and stuff {{{1

"Color schemes{{{2
if !exists('*SetColorscheme')
	function! SetColorScheme(themes)
		for theme in a:themes
			let available=0
			if filereadable(g:vim_home."/bundle/vim-colorschemes/colors/".theme.'.vim')
				let available=1
			else
				for path in split(&runtimepath, ",")
					if filereadable(path."/colors/".theme.'.vim')
						let available=1
						break
					endif
				endfor
			endif

			if available
				execute (':colorscheme '.theme)
				break
			endif
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
let g:dark_themes = [ 'Tomorrow-Night', 'cobalt2', 'hybrid_material', 'molokai', 'delek', 'seti', 'brogrammer', 'warm_grey' ]
let g:light_themes_default = ['morning', 'default']
let g:dark_themes_default = ['industry', 'koehler', 'desert', 'default']

if isdirectory(g:vim_home."/bundle/vim-colorschemes/colors")
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

"Change the colour of the cursor{{{2
" if &term =~ 'xterm\\|rxvt\\|gnome-terminal'
" 	" use an orange cursor in insert mode
" 	let &t_SI = '\<Esc>]12;orange\x7'
" 	" use a red cursor otherwise
" 	let &t_EI = '\<Esc>]12;red\x7'
" 	silent !echo -ne '\033]12;red\007'

" 	" reset cursor when vim exits (assuming it was black or white before)
" 	augroup exit_stuff
" 		au!
" 		au VimLeave * call ResetCursor()
" 	augroup END
" endif
"2}}}

"Use powerline {{{2
if has('python') && !has('nvim')
	let g:powerline_no_python_error = 1
	if $POWERLINE_DISABLE == ''
		let s:powerline_binding=$POWERLINE_ROOT."/bindings/vim/plugin/powerline.vim"
		if filereadable(s:powerline_binding)
			let &rtp = &rtp.','.s:powerline_binding
			python <<EOF
try:
	from powerline.vim import setup as powerline_setup
	powerline_setup()
except ImportError:
	pass
EOF
			let g:Powerline_symbols = 'fancy'
			let g:Powerline_symbols='unicode'
			set laststatus=2
			set t_Co=256
			set noshowmode "Hide the default mode text below the statusline
		endif
	endif
else
	if Plugin_exists('airline')
		let g:airline_highlighting_cache = 1
		let g:airline_detect_modified = 1
		let g:airline_detect_paste = 1
		let g:airline_theme = 'tomorrow'
		let g:airline_powerline_fonts = 1
	endif
endif
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
nnoremap <leader>t :tag 

if Plugin_exists('AsyncRun') && s:asyncrun_support
	nnoremap <leader>ct :AsyncRun ctags -R .<CR>
else
	nnoremap <leader>ct :!ctags -R .<CR><CR>:echo "Generated tags"<CR>
	nnoremap <leader>ct! :!ctags -R .<CR>
endif

set tags=.tags,tags;/

" F9 to jump to tag
nnoremap <F9> <C-]>zz
" Shift+F9 to get a list of matching tags
nnoremap [33~] :echo "Hello world"<CR>


"2}}}

"Correct typos {{{2
"Avoid showing the command line prompt when typing q: (which is probably a typo for (:q)
nnoremap q: :q<CR>

"Avoid showing help when F1 is pressed (you probably wanted to press Esc).  That menu is still accessible via :help anyway
nnoremap <F1> <Nop>
inoremap <F1> <Nop>
vnoremap <F1> <Nop>
"2}}}

" Reload firefox {{{2
if !exists('*Refresh_firefox')
	" Mozrepl needs to be running inside firefox (Tools>MozRepl>Start)
	function! Refresh_firefox()
		if &modified
			write
		endif

		silent !echo 'BrowserReload(); repl.quit();' | nc -w 1 localhost 4242 2>&1 > /dev/null
		redraw!
	endfunction
endif

"Reload firefox with <leader>r
map <leader>r :call Refresh_firefox()<CR><CR>

"Auto reload firefox when editing html, css or js files
let g:auto_refresh_firefox = 0
if g:auto_refresh_firefox == 1
	augroup Refresh_firefox
		autocmd!
		autocmd BufWriteCmd *.html,*.css,*.js :call Refresh_firefox()
	augroup END
endif
"2}}}
"1}}}

"Custom commands{{{1
"Custom commands{{{2
command! R source $MYVIMRC
command! Reload source $MYVIMRC
command! Relativenumbers call Relativenumbers()
command! Wr call WriteReload()
command! WR call WriteReload()
command! WReload call WriteReload()
command! Foldmode call FoldMethod()
command! Vimrc :vsplit $MYVIMRC
"2}}}

"And some keybindings for those commands {{{2
nnoremap <leader>wr :call WriteReload()<CR>
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
nnoremap + :bnext<CR>
nnoremap - :bprev<CR>
"2}}}

"Repeat last colon command
nnoremap ñ @:
vnoremap ñ @:

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
	autocmd BufNewFile,BufRead *.bash_prompt set filetype=sh
	autocmd BufNewFile,BufRead *.bash_customs set filetype=sh
	autocmd BufNewFile,BufRead *.csv set filetype=csv
	autocmd BufNewFile,BufRead *.ts set filetype=typescript
	autocmd BufNewFile,BufRead *.mqh set filetype=cpp
	autocmd BufNewFile,BufRead *.mq4 set filetype=cpp
	autocmd BufNewFile,BufRead Pipfile set filetype=dosini
augroup END

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

if !exists('*Relativenumbers')
	function! Relativenumbers()
		if(&relativenumber == 1)
			set nornu
			set number
		else
			set relativenumber
		endif
	endfunc
endif

if !exists('*WriteReload')
	function! WriteReload()
		write
		source $MYVIMRC
	endfunc
endif

if !exists('*ResetCursor')
	function! ResetCursor()
		let temp=system('mktemp')
		if $LIGHT_THEME == ''
			execute "!echo -ne '\033]12;white\007' >".temp
		else
			execute "!echo -ne '\033]12;black\007' >".temp
		endif
		execute "!cat ".temp
		execute "!rm ".temp
	endfunc
endif

if !exists('*FoldMethod')
	function! FoldMethod()
		if (&foldmethod == "syntax")
			set foldmethod=indent
		elseif (&foldmethod == "indent")
			set foldmethod=syntax
		endif

		echo "Foldmethod set to ".&foldmethod
	endfunc
endif
"2}}}

" vim:tw=0:fdm=marker:
