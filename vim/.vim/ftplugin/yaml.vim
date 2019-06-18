nnoremap <leader>" Bi"{{ <Esc>lEa }}"<Esc>

if isdirectory(g:vim_home."/snippets")
	if filereadable(g:vim_home."/snippets/snippet.yaml")
		nnoremap <leader>sn :execute("-1read ".g:vim_home."/snippets/snippet.yaml")<CR>GddA
	else
		echo "Snippet not available"
	endif
else
	echo "Snippet not available"
endif
