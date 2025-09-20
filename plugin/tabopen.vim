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
        let l:current_winid = win_getid()
        let l:current_winnr = winnr()

        " Find if there's a window directly to the right
        let l:right_winid = FindRightWindow(l:current_winnr)

        if l:right_winid != -1
            " Reuse existing right window
            call win_gotoid(l:right_winid)
        else
            " Create new window on the right
            execute "vertical rightbelow split"
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

function! FindRightWindow(current_winnr)
    let l:current_pos = win_screenpos(a:current_winnr)
    let l:current_row = l:current_pos[0]
    let l:current_col = l:current_pos[1]
    let l:current_width = winwidth(a:current_winnr)

    " Check all windows to find one that's directly to the right
    for l:winnr in range(1, winnr('$'))
        if l:winnr != a:current_winnr
            let l:win_pos = win_screenpos(l:winnr)
            let l:win_row = l:win_pos[0]
            let l:win_col = l:win_pos[1]

            " Check if window is on the same row and starts right after current window ends
            if l:win_row == l:current_row && l:win_col >= l:current_col + l:current_width
                " Found a window to the right - return the first one we find
                return win_getid(l:winnr)
            endif
        endif
    endfor

    return -1 " No window found to the right
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
