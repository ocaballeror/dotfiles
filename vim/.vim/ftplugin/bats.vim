if isdirectory(g:vim_home."/snippets")
	if filereadable(g:vim_home."/snippets/snippet.bats")
		nnoremap <leader>sn :execute("-1read ".g:vim_home."/snippets/snippet.bats")<CR> 10jWa
	else
		echo "Snippet not available"
	endif
else
	echo "Snippets directory not available"
endif
