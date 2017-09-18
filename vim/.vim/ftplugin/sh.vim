"" A few insane macros that turn [ condition ] && { cmd1; cmd2; } into proper ifs
" For [ condition ] && { cmd1; cmd2; }
let @e='Iif $dT]d$A; then/}sfiv%='
" For [ condition ] && { cmd; }
let @r='Iif f{hhhdwhs; thenlllds{ofik$x'
let @r='Iif f]ldf{v$:s/;/\r/gsfiv%=f]a; then'
" For [ condition ] && cmd
let @t='Iif l%a; thenldwdwiofi'
" For [ condition ] && cmd || cmd2
let @p='Iif f&xxhs; then==f|xselse$ofi'
"Turns 'if condition; then' into 'condition \n ret=$? \n if [ $ret = ]; then
let @u='^wvt;dOp==olocal ret=$?j^wi[ $ret =  ]hi' 

" Puts { command; command2; ... commandn; } into separate lines
let @o='lF{xvt}:s/;/\r/gddk=='

"Autocomplete with done and fi
iab fori for;<Space>do<CR><CR>done<Up><Tab><Up><End><Left><Left><Left><Left>
iab ifi if;<Space>then<CR><CR>fi<Up><Tab><Up><End><Left><Left><Left><Left><Left><Left>
iab ifb if<Space>[<Space>];<Space>then<CR><CR>fi<Up><Tab><Up><End><Left><Left><Left><Left><Left><Left><Left><Left>
iab ife if;<Space>then<CR><CR>else<CR><CR>fi<Up><Tab><Up><Up><Tab><Up><End><Left><Left><Left><Left><Left><Left>
iab ifbe if<Space>[<Space>];<Space>then<CR><CR>else<CR><CR>fi<Up><Tab><Up><Up><Tab><Up><End><Left><Left><Left><Left><Left><Left><Left><Left>
iab dnull >/dev/null<Space>2>&1
iab errecho >&2<Space>echo<Space>"Err:"<Left>

"Wrap a variable in quotes
nnoremap <leader>" lF$i"<Esc>Ea"<Esc>

"Enable syntax folding
let g:sh_fold_enabled=1
let g:is_bash=1

"Snippet
if expand('%:e') == 'bats'
	if isdirectory($HOME."/.vim/snippets")
		if filereadable($HOME."/.vim/snippets/snippet.bats")
			nnoremap <leader>n :-1read $HOME/.vim/snippets/snippet.bats<CR> 10jWa
		else
			echo "Snippet not available"
		endif
	endif
endif
