if isdirectory($HOME."/.vim/snippets")
	if filereadable($HOME."/.vim/snippets/snippet.html")
		if ! &filetype == "php"
			nnoremap <leader>sn :-1read $HOME/.vim/snippets/snippet.html<CR> 3jeela
		endif
	else
		echo "Snippet not available"
	endif
endif
