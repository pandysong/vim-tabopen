" File: ~/.vim/plugin/tabopen.vim
" Description: Open file under cursor in right window with Tab key
" Author: Pandy Song
" Version: 1.0

if exists('g:loaded_tabopen')
    finish
endif
let g:loaded_tabopen = 1

nnoremap <Tab> :call OpenFileLineInRightWindow()<CR>

function! OpenFileLineInRightWindow()
    let l:file_line = expand("<cWORD>")
    
    " Extract filename, line number, and column number
    let l:match = matchlist(l:file_line, '\(.\{-}\):\(\d\+\):\(\d\+\)')
    
    if !empty(l:match)
        let l:filename = l:match[1]
        let l:line_num = l:match[2]
        let l:col_num = l:match[3]
    else
        let l:match = matchlist(l:file_line, '\(.\{-}\):\(\d\+\)')
        if !empty(l:match)
            let l:filename = l:match[1]
            let l:line_num = l:match[2]
            let l:col_num = 1
        else
            let l:filename = l:file_line
            let l:line_num = 1
            let l:col_num = 1
        endif
    endif
    
    let l:filename = substitute(l:filename, '[.,;!?]*$', '', '')
    
    if filereadable(l:filename) || isdirectory(l:filename)
        " Save current window number
        let l:current_winnr = winnr()
        
        " Check if we're in the rightmost window
        if winnr() == winnr('$')
            " We're at the right edge, need to create new window
            execute "vertical rightbelow split"
        else
            " Move to the right window
            wincmd l
        endif
        
        " Open the file
        execute "edit " . fnameescape(l:filename)
        execute l:line_num
        execute "normal! " . l:col_num . "|"
        
        " Highlight the target line
        call HighlightTargetLine(l:line_num)
        
    else
        echo "File not found: " . l:filename
    endif
endfunction

function! HighlightTargetLine(line_num)
    call clearmatches()
    set cursorline
    execute "normal! zz"
    augroup ClearCursorLine
        autocmd!
        autocmd BufLeave <buffer> set nocursorline
    augroup END
endfunction
