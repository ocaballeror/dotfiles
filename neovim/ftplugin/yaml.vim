set tabstop=2
set softtabstop=2
set shiftwidth=2

nnoremap <leader>" Bi"{{ <Esc>lEa }}"<Esc>

if isdirectory(stdpath("config")."/snippets")
	if filereadable(stdpath("config")."/snippets/snippet.yaml")
		nnoremap <leader>sn :execute("-1read ".stdpath("config")."/snippets/snippet.yaml")<CR>GddA
	else
		echo "Snippet not available"
	endif
else
	echo "Snippet not available"
endif
