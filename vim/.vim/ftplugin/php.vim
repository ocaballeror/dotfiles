" Enable SQL syntax highlighting inside strings
" let php_sql_query=1

" Enable HTML syntax highlighting inside strings
" let php_htmlInStrings=1

" Highlighting parent error ] or )
" let php_parent_error_close=1
"
" Fold classes and functions. (Set to 2 to fold all { } regions)
let php_folding=1

if isdirectory(g:vim_home."/snippets")
	if filereadable(g:vim_home."/snippets/snippet.php")
		nnoremap <leader>sn :execute("-1read ".g:vim_home."/snippets/snippet.php")<CR> ji<Tab>
	else
		echo "Snippet not available"
	endif
endif
