" From https://vi.stackexchange.com/a/12733/18187
" Don't highlight python2 keywords
syn keyword pythonTwoBuiltin basestring cmp execfile file long
syn keyword pythonTwoBuiltin raw_input reduce reload unichr unicode
syn keyword pythonTwoBuiltin xrange apply buffer coerce intern
syn keyword pythonStatement async await

" python 3.10 builtins
syn keyword pythonBuiltin aiter anext

" operators
syntax match pyOperator "<=" conceal cchar=≤
syntax match pyOperator ">=" conceal cchar=≥
syntax match pyOperator "!=" conceal cchar=≢
syntax match pyOperator "->" conceal cchar=→

" keywords
" syntax keyword pyOperator product conceal cchar=∏
" syntax keyword pyOperator sum conceal cchar=∑
" syntax keyword pyStatement lambda conceal cchar=λ

hi link pyOperator Operator
hi link pyStatement Statement
hi link pyKeyword Keyword
hi! link Conceal Operator

setlocal conceallevel=1
