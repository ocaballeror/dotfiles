if isdirectory(g:vim_home."/snippets")
	if filereadable(g:vim_home."/snippets/snippet.html")
		if &filetype != "php"
			nnoremap <leader>sn :execute("-1read ".g:vim_home."/snippets/snippet.html")<CR> 3jeela
		endif
	else
		echo "Snippet not available"
	endif
endif
