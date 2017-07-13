if isdirectory($HOME."/.vim/snippets")
	if filereadable($HOME."/.vim/snippets/snippet.bats")
		nnoremap <leader>sn :-1read $HOME/.vim/snippets/snippet.bats<CR> 11jWa
	else
		echo "Snippet not available"
	endif
endif
