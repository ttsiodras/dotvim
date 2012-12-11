if has("python")
  " let python figure out the path to pydoc
  python << EOF
import sys
import vim
vim.command("let s:pydoc_path=\'" + sys.prefix + "/lib/pydoc.py\'")
EOF
else
  " manually set the path to pydoc
  let s:pydoc_path = "/path/to/python/lib/pydoc.py"
endif
let s:pydoc_path = "/usr/bin/pydoc"

map <buffer> K :let save_isk = &iskeyword \|
    \ set iskeyword+=. \|
    \ execute "Pyhelp " . expand("<cword>") \|
    \ let &iskeyword = save_isk<CR>
command! -nargs=1 Pyhelp :call ShowPydoc(<f-args>)
function! ShowPydoc(what)
  " compose a tempfile path using the argument to the function
  let path = '/tmp/' . a:what . '.pydoc'
  " run pydoc on the argument, and redirect the output to the tempfile
  call system(s:pydoc_path . " " . a:what . " > " . path)
  " open the tempfile in the preview window
  execute "pedit " . path
endfunction
