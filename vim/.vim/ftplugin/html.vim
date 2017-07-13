if isdirectory($HOME."/.vim/snippets")
	if filereadable($HOME."/.vim/snippets/snippet.html")
		nnoremap <leader>sn :-1read $HOME/.vim/snippets/snippet.html<CR> 3jeela
	else
		echo "Snippet not available"
	endif
endif
