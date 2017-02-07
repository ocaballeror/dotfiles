"" A few insane macros that turn [ condition ] && { cmd1; cmd2; } into proper ifs
" For [ condition ] && { cmd1; cmd2; }
let @e='Iif $dT]d$A; then/}sfiv%='
" For [ condition ] && { cmd; }
let @r='Iif f]ldf{v$:s/;/\r/gsfiv%=f]a; then'
" For [ condition ] && cmd
let @t='Iif l%a; thenldwdwiofi'

"Turns 'if condition; then' into 'condition \n ret=$? \n if [ $ret = ]; then
let @u='^wvt;dOp==olocal ret=$?j^wi[ $ret =  ]hi' 

"Autocomplete with done and fi
iab for for<Space>;do<CR><CR>done<Up><Tab><Up><End><Left><Left><Left><Left>
iab if if<Space>;then<CR><CR>fi<Up><Tab><Up><End><Left><Left><Left><Left><Left><Left>
iab null >/dev/null<Space>2>&1
iab errecho >&2<Space>echo<Space>"Err:"<Left>
