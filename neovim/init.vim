if ! exists('g:vim_home')
	if $XDG_CONFIG_HOME != '' && isdirectory($XDG_CONFIG_HOME)
		let g:config_home=$XDG_CONFIG_HOME
	else
		let g:config_home=$HOME."/.config"
	endif
	let g:vim_home=g:config_home."/nvim"
endif

if has('termguicolors') && stridx($TERM, 'rxvt-unicode') == -1
	set termguicolors
endif

" If there's a customs.vim file in the config directory, load it
if filereadable(g:vim_home."/customs.vim") && ! exists('g:loaded_customs')
	exec 'source '.g:vim_home."/customs.vim"
	let g:loaded_customs=1
endif

" Don't load ~/.vimrc if g:independent_nvim is set
if ! exists('g:independent_nvim') || ! g:independent_nvim
	if filereadable($HOME."/.vimrc")
		source $HOME/.vimrc
	endif
endif

" Terminal mode remappings suggested by the help file
tnoremap <Esc> <C-\><C-n>
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l

" Open a terminal in a new vertical split
command! Vterm vsplit | terminal
command! Sterm split | terminal
