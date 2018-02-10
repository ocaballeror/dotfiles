if ! exists('g:vim_home')
	if $XDG_CONFIG_HOME != '' && isdirectory($XDG_CONFIG_HOME)
		let g:config_home=$XDG_CONFIG_HOME
	else
		let g:config_home=$HOME."/.config"
	endif
	let g:vim_home=g:config_home."/nvim"
endif

" If there's a customs.vim file in the config directory, load it
if filereadable(g:vim_home."/customs.vim")
	exec 'source '.g:vim_home."/customs.vim"
endif

" Terminal mode remappings suggested by the help file
tnoremap <Esc> <C-\><C-n>
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
