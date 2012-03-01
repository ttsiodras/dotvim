
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function Send_to_Screen(text)
  if !exists("g:screen_sessionname") || !exists("g:screen_windowname")
    call Screen_Vars()
  end
"  echo system("screen -S " . g:screen_sessionname . " -p " . g:screen_windowname . " -X stuff '" . substitute(a:text, "'", "'\\\\''", 'g') . "'")
  let s:foo_text = substitute(a:text, '\n\s*\n\+', '\n', 'g')."\n"
  let s:foo_text = substitute(s:foo_text,  "'", "'\\\\''", 'g') . "\n'"
  echo system("screen -S " . g:screen_sessionname . " -p " . g:screen_windowname . " -X stuff '" . s:foo_text)
endfunction

function Screen_Session_Names(A,L,P)
  return system("screen -ls | awk '/Attached/ {print $1}'")
endfunction

function Screen_Vars()
  if !exists("g:screen_sessionname") || !exists("g:screen_windowname")
    let g:screen_sessionname = ""
    let g:screen_windowname = "python"
  end

  let g:screen_sessionname = input("session name: ", "PythonSlime", "custom,Screen_Session_Names")
  let g:screen_windowname = input("window name: ", g:screen_windowname)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

vmap <C-c><C-c> "ry :call Send_to_Screen(@r)<CR>
nmap <C-c>v vip<C-c><C-c>
