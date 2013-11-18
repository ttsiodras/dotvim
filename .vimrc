call pathogen#infect()
call pathogen#helptags()
se nobackup
se directory=~/.vim/swp,.
se shiftwidth=4
se sts=4
se modelines=2
se modeline
se nocp
se mouse=a

if has("autocmd")
    filetype on
    filetype indent on
    filetype plugin on
endif

" se autoindent
se undofile
se undodir=~/.vimundo
"noremap <ESC>OP <F1>

" Turbo-charge EasyMotion
"let mapleader = " "

" ESC is too far away
inoremap jj <esc>

" auto-closes preview window after you select what to auto-complete with
"autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
"autocmd InsertLeave * if pumvisible() == 0|pclose|endif

"
" Stop moving the cursor to the beginning of the line - for many commands
"
se nostartofline

"
" Very efficient moves amongst lines
"
se relativenumber

"
" maps NERDTree to F10
"
noremap <silent> <F10> :NERDTreeToggle<CR>
noremap! <silent> <F10> <ESC>:NERDTreeToggle<CR>


"
" tells NERDTree to use ASCII chars
" and to ignore some files
"
let g:NERDTreeDirArrows=0
let g:NERDTreeIgnore=['\.pyc$', '\.o$']

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
" My attempt at easy navigation/creation of windows:
"   Ctrl-Cursor keys to navigate open windows
"   Ctrl-F12 to close current window
" Also...
"   F4 to navigate to next compile/link/flake8 error
"   F3 to navigate to next Syntastic error (first, invoke :Errors)
"
function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  " if (t:curwin == winnr())
  "   " we havent moved
  "   " Create window in that direction,
  "   if (match(a:key,'[jk]')) "were we going up/down
  "     wincmd v
  "   else
  "     wincmd s
  "   endif
  "   exec "wincmd ".a:key
  " endif
endfunction
function! WinClose()
  if &filetype == "man"
    bd!
  else
    bd
  endif
endfunction
if !has("gui_running")
    " XTerm
    noremap <silent> <Esc>[1;5B :call WinMove('j')<CR>
    noremap <silent> <Esc>[1;5A :call WinMove('k')<CR>
    noremap <silent> <Esc>[1;5D :call WinMove('h')<CR>
    noremap <silent> <Esc>[1;5C :call WinMove('l')<CR>
    noremap <silent> <Esc>[24;5~ :call WinClose()<CR>
    noremap! <silent> <Esc>[1;5B <ESC>:call WinMove('j')<CR>
    noremap! <silent> <Esc>[1;5A <ESC>:call WinMove('k')<CR>
    noremap! <silent> <Esc>[1;5D <ESC>:call WinMove('h')<CR>
    noremap! <silent> <Esc>[1;5C <ESC>:call WinMove('l')<CR>
    noremap! <silent> <Esc>[24;5~ <ESC>:call WinClose()<CR>
    noremap <silent>  <Esc>OS :cn<CR>
    noremap! <silent> <Esc>OS <ESC>:cn<CR>
    noremap <silent> <Esc>OR :lnext<CR>
    noremap! <silent> <Esc>OR <ESC>:lnext<CR>

    " Putty-ing from Windows
    "
    if has("unix")
      let myosuname = system("uname")
      if myosuname =~ "OpenBSD"
	" Putty-ing from Windows into OpenBSD
	noremap <silent> <Esc>[B :call WinMove('j')<CR>
	noremap <silent> <Esc>[A :call WinMove('k')<CR>
	noremap <silent> <Esc>[D :call WinMove('h')<CR>
	noremap <silent> <Esc>[C :call WinMove('l')<CR>
	noremap <silent> <Esc>[24~ :call WinClose()<CR>
	noremap! <silent> <Esc>[B <ESC>:call WinMove('j')<CR>
	noremap! <silent> <Esc>[A <ESC>:call WinMove('k')<CR>
	noremap! <silent> <Esc>[D <ESC>:call WinMove('h')<CR>
	noremap! <silent> <Esc>[C <ESC>:call WinMove('l')<CR>
	noremap! <silent> <Esc>[24~ <ESC>:call WinClose()<CR>
        noremap <silent>  <Esc>[14~ :cn<CR>
        noremap! <silent> <Esc>[14~ <ESC>:cn<CR>
      elseif &term == "xterm-color"
	" Putty-ing from Windows into Linux
	noremap <silent> <Esc>OB :call WinMove('j')<CR>
	noremap <silent> <Esc>OA :call WinMove('k')<CR>
	noremap <silent> <Esc>OD :call WinMove('h')<CR>
	noremap <silent> <Esc>OC :call WinMove('l')<CR>
	noremap <silent> <Esc>[24~ :call WinClose()<CR>
	noremap! <silent> <Esc>OB <ESC>:call WinMove('j')<CR>
	noremap! <silent> <Esc>OA <ESC>:call WinMove('k')<CR>
	noremap! <silent> <Esc>OD <ESC>:call WinMove('h')<CR>
	noremap! <silent> <Esc>OC <ESC>:call WinMove('l')<CR>
	noremap! <silent> <Esc>[24~ <ESC>:call WinClose()<CR>
        noremap <silent> <Esc>[14~ :cn<CR>
        noremap! <silent> <Esc>[14~ <ESC>:cn<CR>
      endif
    endif
else
    " GVim
    noremap <silent> <C-Down>  :call WinMove('j')<CR>
    noremap <silent> <C-Up>    :call WinMove('k')<CR>
    noremap <silent> <C-Left>  :call WinMove('h')<CR>
    noremap <silent> <C-Right> :call WinMove('l')<CR>
    noremap <silent> <C-F12>   :call WinClose()<CR>
    noremap! <silent> <C-Down>  <ESC>:call WinMove('j')<CR>
    noremap! <silent> <C-Up>    <ESC>:call WinMove('k')<CR>
    noremap! <silent> <C-Left>  <ESC>:call WinMove('h')<CR>
    noremap! <silent> <C-Right> <ESC>:call WinMove('l')<CR>
    noremap! <silent> <C-F12>   <ESC>:call WinClose()<CR>
    noremap <silent> <F4> :cn<CR>
    noremap! <silent> <F4> <ESC>:cn<CR>
    noremap <silent> <F3> :ln<CR>
    noremap! <silent> <F3> <ESC>:ln<CR>
endif

"
" In cmd mode, + and - vertically enlarge/shrink a split
"
noremap  <silent> = :call WinMove('+')<CR>
noremap  <silent> - :call WinMove('-')<CR>
noremap  <silent> + :call WinMove('>')<CR>
noremap  <silent> _ :call WinMove('<')<CR>


"
" incremental search that highlights results
"
se incsearch
se hlsearch
" Ctrl-L clears the highlight from the last search
noremap <C-l> :nohlsearch<CR><C-l>
noremap! <C-l> <ESC>:nohlsearch<CR><C-l>


"
" Fix insert-mode cursor keys in FreeBSD
"
if has("unix")
  let myosuname = system("uname")
  if myosuname =~ "FreeBSD"
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
"nnoremap <silent> n nzz
"nnoremap <silent> N Nzz
"nnoremap <silent> * *zz
"nnoremap <silent> # #zz


"
" Make Y behave like other capitals
"
"noremap Y y$


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


"
" TAB and Shift-TAB in normal mode cycle buffers
"
noremap <Tab> :bn<CR>
noremap <S-Tab> :bp<CR>


"
" Syntax-coloring of files
"
syntax on
colorscheme elflord

"
" Disable cursors (force myself to learn VI moves)
" Months later: It worked - I now only use the home row.
" Leaving it here for any one else needing it.
"
"map <down> <nop>
"map <left> <nop>
"map <right> <nop>
"map <up> <nop>
"
"imap <down> <nop>
"imap <left> <nop>
"imap <right> <nop>
"imap <up> <nop>

"
" highlight current line
"
set cursorline

"
" always show the status line
"
set laststatus=2
set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
"              | | | | |  |   |      |  |     |    |
"              | | | | |  |   |      |  |     |    + current
"              | | | | |  |   |      |  |     |       column
"              | | | | |  |   |      |  |     +-- current line
"              | | | | |  |   |      |  +-- current % into file
"              | | | | |  |   |      +-- current syntax in
"              | | | | |  |   |          square brackets
"              | | | | |  |   +-- current fileformat
"              | | | | |  +-- number of lines
"              | | | | +-- preview flag in square brackets
"              | | | +-- help flag in square brackets
"              | | +-- readonly flag in square brackets
"              | +-- rodified flag in square brackets
"              +-- full path to file in the buffer

"
" But we must be able to hide them if we want to
"
function! TabsAndColumn80AndNumbers ()
    "
    " tabs must be visible
    "
    set list!
    if (&relativenumber == 1)
        set number!
    else
        set relativenumber!
    endif
    set listchars=tab:>-,trail:-
    if exists('+colorcolumn')
        "
        " Show me column 80
        "
        if &colorcolumn == ""
            set colorcolumn=80
        else
            set colorcolumn=
        endif
    endif
endfunction
nnoremap <Esc>[20~ :call TabsAndColumn80AndNumbers()<CR>
nnoremap <F9> :call TabsAndColumn80AndNumbers()<CR>

"
" Smart backspace
"
set backspace=start,indent,eol

"
" Avoid TABs like the plague
"
set expandtab

" SVN/GIT vimdiff hack:
"
" For SVN ...
"
" in ~/.subversion/config:
"
"    diff-cmd = /usr/local/bin/svndiff
"
" and this helper cmd is simply...
"
"    $ cat /usr/local/bin/svndiff
"    #!/bin/bash
"    vimdiff "$6" "$7"
"    exit 0
"
"
" For GIT ...
"
" in ~/.gitconfig:
"
"    ....
"    [diff]
"        external = git_diff_wrapper
"
"    [pager]
"        diff =
"
" and this wrapper is simply...
"
"    $ cat /usr/local/bin/git_diff_wrapper
"    #!/bin/sh
"    vimdiff "$2" "$5"
"    exit 0

" When in vimdiff, enable wrap (visible diffs past 80 columns)
" au FilterWritePre * if &diff | set wrap | endif

" Set vimdiff to ignore whitespace
set diffopt+=iwhite
set diffexpr=

"
" Much improved auto completion menus
"
set completeopt=menuone,longest,preview

"
" Use C-space for omni completion in insert mode.
" Disabled currently, because I am testing the
" 'YouCompleteMe' plugin...
"
"inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
"            \ "\<lt>C-n>" :
"            \ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
"            \ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
"            \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
"imap <C-@> <C-Space>

"
" Stop warning me about leaving a modified buffer
"
set hidden

"
" Show command as I type it
"
set showcmd

"
" Now that I use vim-paren-crosshairs, I need 256 colors in my console VIM
"
set t_Co=256

"
" After 'f' in normal mode, I always mistype 'search next' - use space for ;
"
noremap <space> ;

"
" Manpage for word under cursor via 'K' in command mode
"
runtime ftplugin/man.vim
noremap <buffer> <silent> K :exe "Man" expand('<cword>') <CR>

"
" Map SyntasticCheck to F6
"
noremap <silent> <F6> :SyntasticCheck<CR>
noremap! <silent> <F6> <ESC>:SyntasticCheck<CR>

let g:syntastic_mode_map = {
    \ 'mode': 'active',
    \ 'active_filetypes': [],
    \ 'passive_filetypes': ['python', 'cpp', 'c', 'typescript'] }

"
" Now that I use the CtrlP plugin, a very useful shortcut is to open
" an XTerm in the folder of the currently opened file:
"
noremap <silent> <F2> :!xterm -e "cd %:p:h ; bash" &<CR><CR>
noremap <silent> <Esc>OQ :!xterm -e "cd %:p:h ; bash" &<CR><CR>
let g:ctrlp_working_path_mode = 0

" Unfortunately, reusing the cache caused more harm than good
" let g:ctrlp_clear_cache_on_exit = 1

"
" Powerline settings
"
let g:Powerline_stl_path_style = 'short'

"
" For GVIM only
"
if has("gui_running")
    " Horizontal scrollbar
    set guioptions+=b
    set nowrap
    set guifont=Lucida\ Console\ Semi-Condensed\ 11
    colorscheme evening
endif

"
" Sacrilege: Make Ctrl-c act as 'Clipboard-copy' in visual select mode
"
vmap <C-c> "+y

"
" Language-specific section
"

"
" For C and C++
"
    
" libclang use is mandatory now
"
let g:clang_use_library = 1

" Cover CUDA .cu, too)
au BufNewFile,BufRead *.c,*.cc,*.cpp,*.h,*.cu call SetupCandCPPenviron()
function! SetupCandCPPenviron()
    "
    " Search path for 'gf' command (e.g. open #include-d files)
    "
    "set path+=/usr/include/c++/**

    "
    " Tags
    "
    " If I ever need to generate tags on the fly, I uncomment this:
    " noremap <C-F11> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
    set tags+=/usr/include/tags

    "
    " Toggle TagList window with F8
    "
    noremap <buffer> <silent> <F8> :TlistToggle<CR>
    noremap! <buffer> <silent> <F8> <ESC>:TlistToggle<CR>
    let g:Tlist_Use_Right_Window = 1

    "
    " Especially for C and C++, use section 3 of the manpages
    "
    noremap <buffer> <silent> K :exe "Man" 3 expand('<cword>') <CR>

    "
    " Remap F7 to make
    "
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>
endfunction

"
" For Python
"
au BufNewFile,BufRead *.py call SetupPythonEnviron()
function! SetupPythonEnviron()
    "
    " flake8: ignore 'too long lines'
    "
    "let g:flake8_ignore="E501,E225"

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
    noremap <buffer> <silent> <C-c><C-c> :call SelectClassOrFunction()<CR><CR>

    "
    " Flake8 is always at F7 - but syntastic must use pylint
    "
    let g:syntastic_python_checker = 'pylint'
endfunction

"
" OCaml
"
au BufNewFile,BufRead *.ml call SetupOCamlEnviron()
function! SetupOCamlEnviron()
    "
    " Remap F7 to make if the file is an .ml one
    "
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>
endfunction

"
" Javascript
"
au BufNewFile,BufRead *.js call SetupJSEnviron()
function! SetupJSEnviron()
    "
    " Remap F7 to JSHint if the file is a .js one
    "
    noremap <buffer> <special> <F7> :JSHint<CR>
    noremap! <buffer> <special> <F7> <ESC>:JSHint<CR>
    let g:syntastic_javascript_syntax_checker="jshint"
endfunction

au BufNewFile,BufRead *.md call SetupMDEnviron()
function! SetupMDEnviron()
    "
    " Remap F7 to make
    "
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>
endfunction

au BufNewFile,BufRead *.tex call SetupTexEnviron()
function! SetupTexEnviron()
    "
    " Remap F7 to make
    "
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>
endfunction

au BufNewFile,BufRead *.htm,*.html call SetupHTMLenviron()
function! SetupHTMLenviron()
    "
    " I use custom Makefiles that do many things
    " (tidy checks, etc)
    "
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>
endfunction

"
" XML (Read the related blog post at http://ttsiodras.github.io/regexp.html)
"
" Use SAXCount to validate XMLs based on their .xsds ; provided that is,
" that they have header lines on their top - indicating what .xsd they use.
" e.g. files looking like this:
"
"     <?xml version="1.0" encoding="utf-8" ?>
"     <WhateverElement ... 
"             xsi:noNamespaceSchemaLocation="something.xsd"
"             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
"         <AnotherElement>
"             ...
"         </AnotherElement>
"     </WhateverElement>
"
" The .xsd file must be at the same place as the .xml - or a "search"
" functionality must be added to SAXCount - some sort of XSDPATH.
"
" Now for the ":make" (mapped to F7) and error parsing functionality:
"
" No need to explain this part:
"
"     se makeprg=SAXCount\ -n\ -s\ -f\ %
"
" But this needs explaining:
"
"     se errorformat=%E,%C%.%#Error\ at\ file\ %f%.\ line\ %l%.\ char\ %c,%C\ \ Message:\ %m,%Z,%-G%f:\ %*[0-9]\ ms\ %.%#
"
" It is supposed to catch error messages like these:
"
"     $ SAXCount -n -s -f a.xml
"
"     Error at file /var/tmp/a.xml, line 4, char 23
"       Message: empty content is not valid for content model '(transferBatch|notification)'
"
" ... or Fatal errors, that similarly begin with "Fatal Error" instead of "Error":
"
"     Fatal Error at file ...
"
" It must also ignore lines like these:
"
"     a.xml: 11 ms (64 elems, 207 attrs, 1133 spaces, 0 chars)
"
" So, breaking it down, I have two errorformat "rules":
"
"     se errorformat=
"         (Error report span in multiple lines, begins with %E, ends with %Z)
"         %E,%C%.%#Error\ at\ file\ %f%.\ line\ %l%.\ char\ %c,%C\ \ Message:\ %m,%Z,
"         (Information emitted by SAXCount about execution time)
"         %-G%f:\ %*[0-9]\ ms\ %.%#
"
" The first rule:
"
"     %E (begin multiline match of an error report)
"     , (end of first line, which is always empty)
"     %C (continuation - next line)
"     %.%#Error...
"     (which means match '.*Error...' - so it also catches "Fatal Error...")
"     %f%.
"     (filename, followed by any char - in this case, the comma,
"      for some reason I could not use '\,' so I just used a '%.')
"     %l and %c (similarly, line and column number)
"     %C (continuation - next line)
"     Message: %m
"     (matches the actual message for the copen list)
"     %Z (end multiline match)
"
" The second rule: ignore (hence the minus in %-G) this kind of informational lines:
"     "a.xml: 11 ms (64 elems, 207 attrs, 1133 spaces, 0 chars)"
"
"     %-G%f:\ %*[0-9]\ ms\ %.%#
"     (basically: filename, colon, space, numbers, space, "ms", and ".*")
"
" Now all I have to do to validate my .xml files is hit F7, and navigate from
" each error to the next with F4 (just as I do for my Python work, via pyflakes).
"

au BufNewFile,BufRead *.xml call SetupXMLEnviron()
function! SetupXMLEnviron()
    se errorformat=%E,%C%.%#Error\ at\ file\ %f%.\ line\ %l%.\ char\ %c,%C\ \ Message:\ %m,%Z,%-G%f:\ %*[0-9]\ ms\ %.%#
    se makeprg=SAXCount\ -n\ -s\ -f\ %
    noremap <buffer> <F7> :make<CR>
    noremap! <buffer> <F7> :make<CR>

    " In visual mode (with multiple lines selected) use Leader followed by '=' 
    " to align attribute assignments so that they line up horizontally
    " vmap <buffer> <Leader>= :s,\v\s*(\w+)\s*\=\s*,@\1=,g<CR>gv:!column -t -s @<CR>
    vmap <buffer> <Leader>= :Tabularize/\v\zs\w+\ze\=["']/l1l0<CR>

    " 
    " We sometimes need XSD-based autocompletion for .xml files
    " Step 1: Spawn eclimd in some screen
    " Step 2: Open your file, make sure filetype is xml (:se filetype)
    " Step 3: Unfortunately, eclim/eclipse sometimes get confused with BOM and DOS
    "         newlines... Hit F12 for instant dos2unix
    "
    noremap <buffer> <F12> :!dos2unix %:p<CR>
    noremap! <buffer> <F12> :!dos2unix %:p<CR>
    "
    " Step 4: Make the file known to Eclipse, by hiting F8 (with your .xml file open)
    "
    noremap <buffer> <F8> :ProjectCreate %:p:h -n none<CR>
    noremap! <buffer> <F8> :ProjectCreate %:p:h -n none<CR>
    "
    " Step 5: Ctrl-x Ctrl-u is too difficult - for XML insert mode, map to TAB
    "
    inoremap <buffer> <Tab> <C-x><C-u>
    "
    " Step 6: Auto-close preview window when insertion cursor moves (usually,
    "         by just hitting space) or escaping into normal mode.
    "
    autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
    autocmd InsertLeave * if pumvisible() == 0|pclose|endif
endfunction

au BufNewFile,BufRead *.nrl call SetupXMLEnviron()
