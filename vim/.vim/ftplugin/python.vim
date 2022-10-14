" Follow PEP8 standards for python
set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=79
set expandtab
set autoindent
set fileformat=unix

" Mappings that are only valid for python
nnoremap <leader>bl :execute '!black --line-length 79 --skip-string-normalization '.expand('%t')<CR><CR>
nnoremap <leader>au :execute '!autoimport '.expand('%t')<CR><CR>

" Mark unnecessary whitespace as an error
highlight BadWhitespace ctermbg=darkgreen guibg=lightgreen
match BadWhitespace /\s\+$/
match BadWhitespace /^\t+/

" Options for Jedi {{{
let g:jedi#completions_enabled = 1
"}}}
