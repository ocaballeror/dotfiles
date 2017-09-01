inoreab istd #include <iostream><CR>

inoreab fori for<Space>(int<Space>i=0; i<n; i++){<CR><CR>}<Up><Tab>
inoreab forj for<Space>(int<Space>j=0; j<n; j++){<CR><CR>}<Up><Tab>
inoreab fork for<Space>(int<Space>k=0; k<n; k++){<CR><CR>}<Up><Tab>

inoreab ife if<Space>(){<CR><CR>else<CR><CR>}<Up><Tab><Up><Up><Tab><Up><End><Left><Left>
inoreab ifi if<Space>(){<CR><CR>}<Up><Tab><Up><End><Left><Left>
inoreab ife if<Space>(){<CR><CR>else<CR><CR>}<Up><Tab><Up><Up><Tab><Up><End><Left><Left>

if isdirectory($HOME."/.vim/snippets")
	if expand('%:e') == 'h'
		if filereadable($HOME."/.vim/snippets/snippet.h")
			nnoremap <silent> <buffer> <leader>sn :-1read $HOME/.vim/snippets/snippet.h<CR> Wl"=expand('%:t:r')<C-M>pjh"=expand('%:t:r')<C-M>pji
		else
			echo "Snippet not available"
		endif
	elseif expand('%:e') == 'cpp'
		if filereadable($HOME."/.vim/snippets/snippet.cpp")
			nnoremap <silent> <buffer> <leader>sn :-1read $HOME/.vim/snippets/snippet.cpp<CR> jjji<Tab>
		else
			echo "Snippet not available"
		endif
	endif
else
	echo "Snippet directory not found"
endif
