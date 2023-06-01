" If there's a customs.vim file in the config directory, load it
if filereadable(stdpath("config")."/customs.vim") && ! exists('g:loaded_customs')
	exec 'source '.stdpath("config")."/customs.vim"
	let g:loaded_customs=1
endif

"Some general options {{{1
let mapleader = ','
filetype plugin indent on
syntax on

set autowrite
set autoindent
set smartindent
set clipboard=unnamedplus " Use system clipboard as default buffer (requires gvim)
"set cursorline			  " Highlight the line where the cursor is
set gdefault 			  " Always use /g in substitute commands
set mouse=                " Disable mouse
set scrolloff=2 		  " Number of lines to show above the cursor when scrolling
set shell=bash            " For external commands run with :!
set showtabline=2 		  " Always display the tabline
set splitright
set splitbelow
set wildmode=list:longest,list:full

if &modifiable
	set fileencoding=utf-8
endif

if has('termguicolors') && stridx($TERM, 'rxvt-unicode') == -1
	set termguicolors
endif
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

" Remove the annoying current line number highlight from the colorscheme
highlight clear CursorLineNr

" Disable line numbers in terminal
augroup Terminal
    autocmd!
    autocmd TermOpen * setlocal norelativenumber
    autocmd TermOpen * setlocal nonumber
augroup END

"2}}}

"Set tab indendantion size{{{2
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab
"2}}}
"1}}}

" Temporary files {{{1
set undofile
set backup
set swapfile

let &backupdir=stdpath('state').'/backup'

" Don't create backups when editing files in certain directories
set backupskip=/tmp/*
"1}}}

" Plugin options {{{1
" Syntastic {{{2
" Disable syntastic (it's builtin to ArchLinux)
let g:loaded_syntastic_plugin = 1
" 2}}}

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

" Override color highlighting
if $LIGHT_THEME != '' && $LIGHT_THEME != 'false'
	highlight EasyMotionTarget cterm=bold ctermbg=none ctermfg=DarkRed
	highlight EasyMotionTarget2First  cterm=bold ctermbg=none ctermfg=DarkGreen
	highlight EasyMotionTarget2Second cterm=bold ctermbg=none ctermfg=DarkGreen
endif
"2}}}

" NERDTree {{{2
" nnoremap <leader>. :NERDTreeToggle<CR>

let NERDTreeShowHidden = 1
let NERDTreeIgnore=['\.swp$', '\.swo$', '\~$', '\.tags$', '^\.git$', '\.pyc$', '__pycache__', '\.o$', '^\.tox$', '^\.pytest_cache$', '^\.vimsession$', '\.mypy_cache$', '\.venv$']

" Close nerdtree when closing vim
autocmd BufEnter *
			\ if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) |
			\ 	quit |
			\ endif

" Do not allow other buffers to replace nerdtree
autocmd BufEnter *
			\ if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
				\ let buf=bufnr() |
				\ buffer# |
				\ execute 'normal! \<C-W>w' |
				\ execute 'buffer'.buf |
			\ endif
"2}}}

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

" AsyncRun {{{2
" Command to run when the job is finished
let g:asyncrun_exit='echo "Async Run job completed"'
"2}}}

" Vimspector {{{2
let g:vimspector_enable_mappings = "HUMAN"
" 2}}}

" Maximizer {{{2
let g:maximizer_default_mapping_key = '<leader>fu'
let g:maximizer_set_mapping_with_bang = 1
" 2}}}

" Repl {{{2
nnoremap <leader>rt :silent ReplOpen<CR>
nnoremap <leader>rc :ReplRunCell<CR>
nmap <leader>rr <Plug>ReplSendLine
vmap <leader>rr <Plug>ReplSendVisual

let g:repl_split = 'right'
let g:repl_filetype_commands = {
  \ 'python': ['ptpython', '--history-file', '/dev/null'],
  \ }

augroup repl
	autocmd!
	autocmd BufEnter *py
				\ if &columns < 200 |
					\ let g:repl_split = 'bottom' |
				\ else |
					\	let g:repl_split = 'right' |
				\ endif

	" Exit terminal if it's the only buffer remaining
	autocmd BufEnter *
				\ if winnr("$") == 1 && &buftype == 'terminal' |
				\ 	quit |
				\ endif

	" Do not allow terminals to be replaced with other buffers
	autocmd BufEnter *
				\ if &buftype == 'terminal' && winnr('$') > 1 |
					\ let buf=bufnr() |
					\ buffer# |
					\ execute 'normal! \<C-W>w' |
					\ execute 'buffer'.buf |
				\ endif
augroup END

" 2}}}
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

call SetColorScheme(['Tomorrow-Night', 'default'])
"2}}}
" 1}}}

" Other junk {{{1

"Ctags stuff {{{2
nnoremap <leader>ct :AsyncRun rm -f .tags && ctags -R .
set tags=.tags,tags;/
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
inoreabbrev recieve receive
inoreabbrev reciever receiver
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

" Paste into selection without losing the copied content {{{2
nnoremap gp "_dP
vnoremap gp "_dP
"2}}}

"Make scrolling a little bit faster {{{2
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>
"2}}}

"Edit vimrc {{{2
if exists('g:independent_nvim') && g:independent_nvim
	nnoremap <leader>ev :silent execute "vsplit ".stdpath("config")."/customs.vim"<CR>
else
	nnoremap <leader>ev :vsplit ~/.vimrc<CR>
endif
"2}}}

"Repeat last recorded macro {{{2
nnoremap Q @@
"2}}}

" Window navigation {{{2
" Resize panes with <leader> +/-
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>

" Leader maps to switch between panes
nnoremap <leader>f  <C-w>j
nnoremap <leader>d  <C-w>k
nnoremap <leader>g  <C-w>l
nnoremap <leader>s  <C-w>h

" Ctrl + Arrow keys to resize windows
nnoremap <C-Up>	:resize +5<CR>
nnoremap <C-Down>	:resize -5<CR>
nnoremap <C-Right>	:vertical resize +5<CR>
nnoremap <C-Left>	:vertical resize -5<CR>

" Shift + Left|Right to switch buffers
nnoremap <S-Left>	:bprevious<CR>
nnoremap <S-Right>	:bnext<CR>
" 2}}}

" Terminal mode remappings
tnoremap <Esc> <C-\><C-n>
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l

" Open a terminal in a new vertical split
command! Vterm vsplit | terminal
command! Sterm split | terminal
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

" Automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

" Detect weird file types
augroup fileTypes
	autocmd!
	autocmd BufNewFile,BufRead *.bats set filetype=sh
	autocmd BufNewFile,BufRead *.bash_prompt set filetype=sh
	autocmd BufNewFile,BufRead *.bash_customs set filetype=sh
	autocmd BufNewFile,BufRead Pipfile set filetype=dosini
	autocmd BufNewFile,BufRead *.gitcredentials set filetype=gitconfig
	autocmd BufNewFile,BufRead Jenkinsfile set filetype=groovy
	autocmd BufNewFile,BufRead *.wsgi set filetype=python
augroup END

" Highlight text on yank
autocmd TextYankPost * silent! lua vim.highlight.on_yank()
"1}}}

" Load lua configuration
for file in glob(stdpath("config")."/lua/*lua", v:false, v:true)
    exec 'luafile '.file
endfor

" vim:tw=0:fdm=marker:noexpandtab
