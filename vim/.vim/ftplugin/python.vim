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

        let &gdefault = l:gdefault
		call winrestview(l:save)
	endfunc
endif

" Options for Jedi {{{
if has('python') && ! exists('g:jedi#disable')
    " Basically copied the initialization process from the plugin's source code,
    " minus the part where it overrides keybindings. My leader key is very precious
    " to me, jedi, don't you dare override it
    let g:jedi#auto_initialization = 0

    if g:jedi#show_call_signatures > 0 && has('conceal')
        call jedi#configure_call_signatures()
    endif

    if g:jedi#completions_enabled == 1
        inoremap <silent> <buffer> . .<C-R>=jedi#complete_string(1)<CR>
    endif

    if g:jedi#smart_auto_mappings == 1
        inoremap <silent> <buffer> <space> <C-R>=jedi#smart_auto_mappings()<CR>
    end

    if g:jedi#auto_close_doc
        " close preview if its still open after insert
        autocmd InsertLeave <buffer> if pumvisible() == 0|pclose|endif
    endif
endif
"}}}
