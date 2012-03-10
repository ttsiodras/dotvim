call pathogen#infect()
call pathogen#helptags()
se nobackup
se directory=~/.vim/swp,.
se shiftwidth=4
se sts=4
se modelines=2
se modeline
se nocp
colorscheme evening
if has("autocmd")
    filetype on
    filetype indent on
    filetype plugin on
endif
syntax on


"
" Search path for 'gf' command (e.g. open #include-d files)
"
set path+=/usr/include/c++/**


"
" Tags
"
" If I ever need to generate tags on the fly, I uncomment this:
" noremap <C-F11> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
set tags+=/usr/include/tags


" se autoindent
se undofile
se undodir=~/.vimundo
se term=linux
"noremap <ESC>OP <F1>


"
" necessary for using libclang
"
let g:clang_library_path='/usr/lib/llvm'


" auto-closes preview window after you select what to auto-complete with
"autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
"autocmd InsertLeave * if pumvisible() == 0|pclose|endif


"
" maps NERDTree to F10
"
noremap <silent> <F10> :NERDTreeToggle<CR>
noremap! <silent> <F10> <ESC>:NERDTreeToggle<CR>


"
" tells NERDTree to use ASCII chars
"
let g:NERDTreeDirArrows=0


"
" Better TAB completion for files (like the shell)
"
if has("wildmenu")
    set wildmenu
    set wildmode=longest,list
    " Ignore stuff (for TAB autocompletion)
    set wildignore+=*.a,*.o
    set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png
    set wildignore+=.DS_Store,.git,.hg,.svn
    set wildignore+=*~,*.swp,*.tmp
endif


"
" Python stuff
"
" obsolete, replaced by flake8
" PEP8
"let g:pep8_map='<leader>8'


" flake8: ignore 'too long lines'
let g:flake8_ignore="E501,E225"


"
" My attempt at easy navigation amongst windows:
"   Ctrl-Cursor keys to navigate open windows
"   Ctrl-F12 to close current window
"
if !has("gui_running")
    " XTerm
    noremap <silent> [1;5B <C-W>j
    noremap <silent> [1;5A <C-W>k
    noremap <silent> [1;5D <C-W>h
    noremap <silent> [1;5C <C-W>l
    noremap <silent> [24;5~ :bd!<CR>
    noremap! <silent> [1;5B <ESC><C-W>j
    noremap! <silent> [1;5A <ESC><C-W>k
    noremap! <silent> [1;5D <ESC><C-W>h
    noremap! <silent> [1;5C <ESC><C-W>l
    noremap! <silent> [24;5~ <ESC>:bd!<CR>

    " Putty
    noremap <silent> OB <C-W>j
    noremap <silent> OA <C-W>k
    noremap <silent> OD <C-W>h
    noremap <silent> OC <C-W>l
    noremap <silent> [24~ :bd!<CR>
    noremap! <silent> OB <ESC><C-W>j
    noremap! <silent> OA <ESC><C-W>k
    noremap! <silent> OD <ESC><C-W>h
    noremap! <silent> OC <ESC><C-W>l
    noremap! <silent> [24~ <ESC>:bd!<CR>

else
    " GVim
    noremap <silent> <C-Down> <C-W>j
    noremap <silent> <C-Up> <C-W>k
    noremap <silent> <C-Left> <C-W>h
    noremap <silent> <C-Right> <C-W>l
    noremap <silent> <C-F12> :bd!<CR>
    noremap! <silent> <C-Down> <ESC><C-W>j
    noremap! <silent> <C-Up> <ESC><C-W>k
    noremap! <silent> <C-Left> <ESC><C-W>h
    noremap! <silent> <C-Right> <ESC><C-W>l
    noremap! <silent> <C-F12> <ESC>:bd!<CR>
endif


"
" incremental search that highlights results
"
se incsearch
se hlsearch
" Ctrl-L clears the highlight from the last search
noremap <C-l> :nohlsearch<CR><C-l>
noremap! <C-l> <ESC>:nohlsearch<CR><C-l>


"
" Smart in-line manpages with 'K' in command mode
"
fun! ReadMan()
  " Assign current word under cursor to a script variable:
  let s:man_word = expand('<cword>')
  " Open a new window:
  :exe ":wincmd n"
  " Read in the manpage for man_word (col -b is for formatting):
  :exe ":r!man " . s:man_word . " | col -b"
  " Goto first line...
  :exe ":goto"
  " and delete it:
  :exe ":delete"
  " finally set file type to 'man':
  :exe ":set filetype=man"
  " lines set to 20
  :resize 20
endfun
" Map the K key to the ReadMan function:
noremap K :call ReadMan()<CR>


"
" Toggle TagList window with F8
"
noremap <silent> <F8> :TlistToggle<CR>
noremap! <silent> <F8> <ESC>:TlistToggle<CR>


"
" Fix insert-mode cursor keys in FreeBSD
"
if has("unix")
  let myosuname = system("uname")
  if myosuname == "FreeBSD"
    set term=cons25
  endif
endif


"
" Reselect visual block after indenting
"
vnoremap < <gv
vnoremap > >gv


"
" Keep search pattern at the center of the screen
"
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz


"
" Function that sends individual Python classes or Python functions 
" to active screen (SLIME emulation)
" 
function! SelectClassOrFunction ()

    let s:currLine = getline(line('.'))
    if s:currLine =~ '^def\|^class' 
	" If the cursor line is a function/class start line, 
	" save its number
	let s:beginLineNumber = line('.')
    elseif s:currLine =~ '^[a-zA-Z]'
	" If the cursor line begins with something else, 
	" we must be on something like a global assignment
	let s:beginLineNumber = line('.')
	let s:endLineNumber = line('.')
	:exe ":" . s:beginLineNumber . "," . s:endLineNumber . "y r"
	:call Send_to_Screen(@r)
	return
    else
	" we are inside something, so search backwards 
	" for function/class beginning, and save its number
	let s:beginLineNumber = search('^def\|^class', 'bnW')
	if !s:beginLineNumber 
	    let s:beginLineNumber = 1
	endif
    endif

    " Now search for the first line that starts with something
    " (function, class, global, etc) and save it
    let s:endLineNumber = search('^[a-zA-Z@]', 'nW')
    if !s:endLineNumber
	let s:endLineNumber = line('$')
    else
	let s:endLineNumber = s:endLineNumber-1
    endif

    " Finally pass the range to the screen session running a REPL
    :exe ":" . s:beginLineNumber . "," . s:endLineNumber . "y r"
    :call Send_to_Screen(@r)
endfunction
nmap <silent> <C-c><C-c> :call SelectClassOrFunction()<CR><CR>


"
" Make Y behave like other capitals
"
noremap Y y$


"
" Force Saving Files that Require Root Permission
"
cmap w!! %!sudo tee > /dev/null %


"
" Syntastic - Ignore 'too long lines' from flake8 report
"
"let g:syntastic_python_checker_args = "--ignore=E501,E225"


"
"when the vim window is resized resize the vsplit panes as well
"
au VimResized * exe "normal! \<c-w>="
