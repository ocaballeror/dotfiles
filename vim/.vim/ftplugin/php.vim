if isdirectory($HOME."/.vim/snippets")
	if filereadable($HOME."/.vim/snippets/snippet.php")
		nnoremap <leader>sn :-1read $HOME/.vim/snippets/snippet.php<CR> ji<Tab>
	else
		echo "Snippet not available"
	endif
endif
