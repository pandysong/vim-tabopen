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
    " Get the entire word under cursor (including line and column numbers)
    let l:file_line = expand("<cWORD>")
    
    " Extract filename, line number, and column number using proper pattern matching
    let l:match = matchlist(l:file_line, '\(.\{-}\):\(\d\+\):\(\d\+\)')
    
    if !empty(l:match)
        " Format: filename:line:column
        let l:filename = l:match[1]
        let l:line_num = l:match[2]
        let l:col_num = l:match[3]
    else
        " Try format without column: filename:line
        let l:match = matchlist(l:file_line, '\(.\{-}\):\(\d\+\)')
        if !empty(l:match)
            let l:filename = l:match[1]
            let l:line_num = l:match[2]
            let l:col_num = 1
        else
            " Just filename without line number
            let l:filename = l:file_line
            let l:line_num = 1
            let l:col_num = 1
        endif
    endif
    
    " Clean up filename (remove trailing punctuation if any)
    let l:filename = substitute(l:filename, '[.,;!?]*$', '', '')
    
    if filereadable(l:filename) || isdirectory(l:filename)
        " Save current window ID
        let l:current_win = win_getid()
        
        " Check if there's a window to the right
        let l:right_win = -1
        wincmd l
        if win_getid() != l:current_win
            " There is a window to the right, use it
            let l:right_win = win_getid()
        else
            " No window to the right, create one
            wincmd p  " Go back to original window
            vertical rightbelow split
            let l:right_win = win_getid()
        endif
        
        " Go to the right window and open the file
        call win_gotoid(l:right_win)
        execute "edit " . fnameescape(l:filename)
        execute l:line_num
        execute "normal! " . l:col_num . "|"
        
        " Highlight the target line
        call HighlightTargetLine(l:line_num)
        
        " Return to original window
        " call win_gotoid(l:current_win)
    else
        echo "File not found: " . l:filename
    endif
endfunction

function! HighlightTargetLine(line_num)
    " Clear previous highlights
    call clearmatches()
    
    " Define a highlight group for the target line
    highlight TargetLine guibg=#2c2c2c ctermbg=236 gui=none cterm=none
    
    " Highlight the entire line
    let l:match_id = matchadd('TargetLine', '\%' . a:line_num . 'l.*')
    
    " Optional: center the screen on the target line
    execute "normal! zz"
    
    " Optional: set a temporary autocmd to clear highlight when leaving the buffer
    augroup ClearTargetHighlight
        autocmd!
        autocmd BufLeave <buffer> call clearmatches()
    augroup END
endfunction
