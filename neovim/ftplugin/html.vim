if isdirectory(stdpath("config")."/snippets")
	if filereadable(stdpath("config")."/snippets/snippet.html")
		if &filetype != "php"
			nnoremap <leader>sn :execute("-1read ".stdpath("config")."/snippets/snippet.html")<CR> 3jeela
		endif
	else
		echo "Snippet not available"
	endif
endif
