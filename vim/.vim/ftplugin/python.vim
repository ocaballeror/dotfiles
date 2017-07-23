" Follow PEP8 standards for python
set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=79
set expandtab
set autoindent
set fileformat=unix

" Mark unnecessary whitespace as an error
highlight BadWhitespace ctermbg=darkgreen guibg=lightgreen
match BadWhitespace /\s\+$/
match BadWhitespace /^\t+/

" For highlighted trailing whitespace and mix of spaces and tabs
let python_space_error_highlight = 1
