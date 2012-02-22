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
" map <C-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
set tags+=/usr/include/tags
" se autoindent
se undofile
se undodir=~/.vimundo
se term=linux
"map <ESC>OP <F1>
" necessary for using libclang
let g:clang_library_path='/usr/lib/llvm'
" auto-closes preview window after you select what to auto-complete with
"autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
"autocmd InsertLeave * if pumvisible() == 0|pclose|endif
" maps NERDTree to Ctrl-Y
nmap <silent> <F10> :NERDTreeToggle<CR>
" tells NERDTree to use ASCII chars
let g:NERDTreeDirArrows=0
if has("wildmenu")
    " Better TAB completion for files (like the shell)
    set wildmenu
    set wildmode=longest,list
    " Ignore stuff from autocompletion
    set wildignore+=*.a,*.o
    set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png
    set wildignore+=.DS_Store,.git,.hg,.svn
    set wildignore+=*~,*.swp,*.tmp
endif
" obsolete, replaced by flake8
" PEP8
"let g:pep8_map='<leader>8'

" ignore 'too long lines'
let g:flake8_ignore="E501,E225"
" My attempt at easy navigation amongst windows
if !has("gui_running")
    nmap <silent> [1;5B <C-W>j
    nmap <silent> [1;5A <C-W>k
    nmap <silent> [1;5D <C-W>h
    nmap <silent> [1;5C <C-W>l
    nmap <silent> [1;5F :bd!<CR>
else
    nnoremap <silent> <C-Down> <C-W>j
    nnoremap <silent> <C-Up> <C-W>k
    nnoremap <silent> <C-Left> <C-W>h
    nnoremap <silent> <C-Right> <C-W>l
    nnoremap <silent> <C-End> :bd!<CR>
endif
" incremental search
se incsearch
se hlsearch
" part of the incremental search: make Ctrl-L clear searches
nnoremap <C-l> :nohlsearch<CR><C-l>
" Smart manpages
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
map K :call ReadMan()<CR>
" Toggle TagList window with F8
nnoremap <silent> <F8> :TlistToggle<CR>
