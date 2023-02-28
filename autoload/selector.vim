function! selector#update(height, prompt, items, pattern)
    let pattern = substitute(a:pattern, " \\+", ".*", "g")
    let matches = reverse(filter(copy(a:items), {_, item -> match(item, pattern) != -1}))

    silent! call deletebufline("", 1, "$")
    silent! call setline(1, matches)
    execute "resize " . min([a:height, len(matches)])

    normal! G
    redraw

    echohl Question
    echon a:prompt
    echohl Normal

    echon a:pattern
endfunction

function! selector#run(prompt, items)
    new
    setlocal statusline=%#Search#Selector buftype=nofile cursorline

    let height = winheight(0)
    let pattern = ""
    call selector#update(height, a:prompt, a:items, pattern)

    while v:true
        let char = getchar()
        if char == "€kb"
            let pattern = pattern[:-2]
            call selector#update(height, a:prompt, a:items, pattern)
        elseif char == 13
            let current = getline(".")
            if current != ""
                let pattern = current
            endif

            break
        elseif char == 14
            normal! j
            redraw
        elseif char == 16
            normal! k
            redraw
        elseif char == 27
            let pattern = ""
            break
        else
            let pattern .= nr2char(char)
            call selector#update(height, a:prompt, a:items, pattern)
        endif
    endwhile

    bdelete!
    mode

    return pattern
endfunction

function! selector#files()
    call system("git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null")
    if v:shell_error
        let cmd = "find -type f"
    else
        let cmd = "git ls-files --cached --others --exclude-standard"
    endif

    let file = selector#run("Files: ", systemlist(cmd))
    if file != ""
        execute "edit " . file
    endif
endfunction

function! selector#buffers()
    let buffer = selector#run("Buffers: ", getcompletion("", "buffer"))
    if buffer != ""
        execute "buffer " . buffer
    endif
endfunction

function selector#browse()
    let chosen = getcwd()
    while v:true
        if chosen != "/"
            let chosen .= "/"
        endif

        let item = selector#run("Browse: " . chosen, systemlist("ls -ap " . shellescape(chosen)))
        if item == ""
            return
        endif

        if item == "./"
            break
        endif

        let chosen = substitute(resolve(chosen . item), "^/\\+", "/", "")
        if !isdirectory(chosen)
            break
        endif
    endwhile

    execute "edit " . chosen
endfunction
