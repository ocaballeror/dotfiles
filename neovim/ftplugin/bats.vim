if isdirectory(stdpath("config")."/snippets")
	if filereadable(stdpath("config")."/snippets/snippet.bats")
		nnoremap <leader>sn :execute("-1read ".stdpath("config")."/snippets/snippet.bats")<CR> 10jWa
	else
		echo "Snippet not available"
	endif
else
	echo "Snippets directory not available"
endif
