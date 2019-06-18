inoreab istd #include <stdio.h><CR>

inoreab fori for<Space>(int<Space>i=0; i<n; i++){<CR><CR>}<Up><Tab>
inoreab forj for<Space>(int<Space>j=0; j<n; j++){<CR><CR>}<Up><Tab>
inoreab fork for<Space>(int<Space>k=0; k<n; k++){<CR><CR>}<Up><Tab>

inoreab ife if<Space>(){<CR><CR>else<CR><CR>}<Up><Tab><Up><Up><Tab><Up><End><Left><Left>
inoreab ifi if<Space>(){<CR><CR>}<Up><Tab><Up><End><Left><Left>
inoreab ife if<Space>(){<CR><CR>else<CR><CR>}<Up><Tab><Up><Up><Tab><Up><End><Left><Left>

if isdirectory(g:vim_home."/snippets")
	if filereadable(g:vim_home."/snippets/snippet.c")
		nnoremap <leader>sn :execute("-1read ".g:vim_home."/snippets/snippet.c")<CR>Gjjji<Tab>
	else
		echo "Snippet not available"
	endif
endif
