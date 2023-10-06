" Follow PEP8 standards for python
set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=99
set expandtab

if &modifiable
    set fileformat=unix
endif

" Mappings that are only valid for python
nnoremap <silent> <leader>bl :execute '!black --line-length '.&tw.' '.expand('%t')<CR><CR>
nnoremap <silent> <leader>au :execute '!autoimport '.expand('%t')<CR><CR>

" Mark unnecessary whitespace as an error
highlight BadWhitespace ctermbg=darkgreen guibg=lightgreen
match BadWhitespace /\s\+$/
match BadWhitespace /^\t+/

" Options for Jedi {{{
let g:jedi#completions_enabled = 1
"}}}

" Matchit support
if exists('loaded_matchit') && !exists('b:match_words')
  let b:match_words = '\<if\>:\<elif\>:\<else\>'
  let b:match_skip = 'R:^\s*'
endif
