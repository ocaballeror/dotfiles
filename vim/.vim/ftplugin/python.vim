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

" Mark unnecessary whitespace as an error
highlight BadWhitespace ctermbg=darkgreen guibg=lightgreen
match BadWhitespace /\s\+$/
match BadWhitespace /^\t+/

" Clean badly formatted files. Put this into a function if you have time.
if ! exists('*Cleanup')
	function! Cleanup()
		let l:save = winsaveview()
        let l:gdefault = &gdefault
        set gdefault

		" Kwargs with no whitespace around '='
		silent! %s/([^)]*\zs = \ze.*/=/

		" Remove space around = in function definitions (apply multiple times).
        silent! %s/def.*(.*\zs \+= \+\ze/=/
        silent! %s/def.*(.*\zs \+= \+\ze/=/

		" var == None should be var is None
		silent! %s/\zs== *\ze\(None\|True\|False\)/ is /
		silent! %s/\zs!= *\ze\(None\|True\|False\)/ is not /

        " do not use bare except
        silent! %s/except:/except Exception:/

		" Remove all trailing whitespace
		silent! %s/  *$//

        " Remove double spaces inside lines
		silent! %s/[^ ]\zs   *\ze/ /

        " Add separation after commas
        silent! %s/,\ze[^ )]/, /

        " Add separation around arithmetic operators
        silent! %s/ \zs\([\+\-<>*/]\|==\)\ze[^ ]/& /
        silent! %s/[^ ]\zs\([\+\-<>*/]\|==\)\ze / &/
        silent! %s/[^ ]\zs\([\+\-<>*/]\|==\)\ze[^ ]/ & /

        " Remove empty lines at the end of the file
        silent! %s/[    \n]*\%$//

        let &gdefault = l:gdefault
		call winrestview(l:save)
	endfunc
endif

" Options for Jedi {{{
let g:jedi#completions_enabled = 1
"}}}
