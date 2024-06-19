" These may be necessary to work inside the ipython-slime mode
"
"  set runtimepath+=/home/ttsiod/.vim
"  runtime autoload/pathogen.vim

call pathogen#infect()
call pathogen#helptags()

"""""""""
" VimPlug
"""""""""
call plug#begin('~/.vim/plugged')
" Plug 'neoclide/coc.nvim', {'for':['zig','cmake','rust',
"      \'java','json', 'haskell', 'ts','sh', 'cs',
"      \'yaml', 'c', 'cpp', 'd', 'go',
"      \'python', 'dart', 'javascript', 'vim'], 'branch': 'release'}
Plug 'neoclide/coc.nvim', { 'branch': 'release'}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

"""""""""""""""""""""""""""""
" Generic, all buffer stuff
"""""""""""""""""""""""""""""

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

" ESC is too far away - and Steve Losh is right, this is better than jj
inoremap jk <esc>

" auto-closes preview window after you select what to auto-complete with
"autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
"autocmd InsertLeave * if pumvisible() == 0|pclose|endif

"
" Stop moving the cursor to the beginning of the line (in many move commands)
"
se nostartofline

"
" Very efficient moves amongst local lines, shows relative jump distances
"
se relativenumber

if v:version >= 704
    "
    " ...but also show the absolute number of the current line.
    " Best of both worlds! (only for vim>=7.4)
    "
    set number
endif

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

""""""""""""""""""""
" NERDTree section "
""""""""""""""""""""

" maps NERDTree to F10
" (normal, visual and operator-pending modes)
noremap <silent> <F10> :NERDTreeToggle<CR>
" (also in insert and command-line modes)
noremap! <silent> <F10> <ESC>:NERDTreeToggle<CR>

" tell NERDTree to use ASCII chars
" and to ignore some files
let g:NERDTreeDirArrows=0
let g:NERDTreeIgnore=['\.pyc$', '\.o$']


""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" My attempt at easy navigation/creation of windows:   "
"   Ctrl-Cursor keys to navigate open windows          "
"   Ctrl-F12 to close current window                   "
" Also...                                              "
"   F4 to navigate to next error in the error window   "
"     (e.g. after :make)                               "
"   F3 to navigate to next place in location list      "
"     (e.g. SyntasticLint - but first invoke :Errors)  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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

" Unfortunately, normal key mappings don't work under Win/PuTTY,
" so I have to create these messy Ctrl-v based mappings...

if !has("gui_running")
    " XTerm
    noremap <silent> <Esc>[1;5B :call WinMove('j')<CR>
    noremap <silent> <Esc>[1;5A :call WinMove('k')<CR>
    noremap <silent> <Esc>[1;5D :call WinMove('h')<CR>
    noremap <silent> <Esc>[1;5C :call WinMove('l')<CR>
    noremap <silent> <Esc>[24~ :call WinClose()<CR>
    noremap! <silent> <Esc>[1;5B <ESC>:call WinMove('j')<CR>
    noremap! <silent> <Esc>[1;5A <ESC>:call WinMove('k')<CR>
    noremap! <silent> <Esc>[1;5D <ESC>:call WinMove('h')<CR>
    noremap! <silent> <Esc>[1;5C <ESC>:call WinMove('l')<CR>
    noremap! <silent> <Esc>[24~ <ESC>:call WinClose()<CR>
    noremap <silent>  <Esc>OS :cn<CR>
    noremap! <silent> <Esc>OS <ESC>:cn<CR>
    noremap <silent> <Esc>OR :lnext<CR>
    noremap! <silent> <Esc>OR <ESC>:lnext<CR>
    noremap <silent> <Esc>[1;5S :bd<CR>
    noremap! <silent> <Esc>[1;5S <ESC>:bd<CR>

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
    noremap <silent> <F12>   :call WinClose()<CR>
    noremap! <silent> <C-Down>  <ESC>:call WinMove('j')<CR>
    noremap! <silent> <C-Up>    <ESC>:call WinMove('k')<CR>
    noremap! <silent> <C-Left>  <ESC>:call WinMove('h')<CR>
    noremap! <silent> <C-Right> <ESC>:call WinMove('l')<CR>
    noremap! <silent> <F12>   <ESC>:call WinClose()<CR>
    noremap <silent> <F4> :cn<CR>
    noremap! <silent> <F4> <ESC>:cn<CR>
    noremap <silent> <F3> :ln<CR>
    noremap! <silent> <F3> <ESC>:ln<CR>
    noremap <silent> <C-F4> :bd<CR>
    noremap! <silent> <C-F4> <ESC>:bd<CR>
endif

"
" In normal mode, + and - vertically enlarge/shrink a split
" Their shifted versions (= and _) do it horizontally.
"
" Note: this means that the usual gg=G will no longer indent;
" use visual selection: ggVG= (or just map it to your own macro)
"
nnoremap  <silent> = :call WinMove('+')<CR>
nnoremap  <silent> - :call WinMove('-')<CR>
nnoremap  <silent> + :call WinMove('>')<CR>
nnoremap  <silent> _ :call WinMove('<')<CR>

"
"when the vim window is resized resize the vsplit panes as well
"
au VimResized * exe "normal! \<c-w>="


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

" Horizontally center cursor position.
" Does not move the cursor itself (except for 'sidescrolloff' at the window
" border).
nnoremap <leader>z :<C-u>normal! zszH<CR>

"
" Make Y behave like other capitals
"
"noremap Y y$


"
" Force Saving Files that Require Root Permission
"
cnoremap w!! %!sudo tee > /dev/null %


"
" TAB and Shift-TAB in normal mode cycle buffers
"
noremap <Tab> :bn<CR>
noremap <S-Tab> :bp<CR>


"
" Syntax-coloring of files
"
syntax on
" colorscheme default
" colorscheme elflord
" colorscheme desert
" colorscheme catppuccin-mocha
colorscheme evening

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
" We must be able to show the 80 column limit with F9...
" While we're at it, we'll also show TABs and trailing WS.
" Hitting F9 again will toggle back to normal.
"
" Default: no column
set colorcolumn=

function! TabsAndColumn80AndNumbers ()
    set listchars=tab:>-,trail:-
    set list!
    if exists('+colorcolumn')
        " Show column 80
        if &colorcolumn == ""
            set colorcolumn=80
            set norelativenumber!
            set number!
        else
            set colorcolumn=
        endif
    endif
endfunction

noremap  <silent> <Esc>[20~ :call TabsAndColumn80AndNumbers()<CR>
noremap! <silent> <Esc>[20~ <ESC>:call TabsAndColumn80AndNumbers()<CR>
noremap  <silent> <F9> :call TabsAndColumn80AndNumbers()<CR>
noremap! <silent> <F9> <ESC> :call TabsAndColumn80AndNumbers()<CR>

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
" For SVN:
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
" (s/vimdiff/meld/ or whatever else you fancy...)
"
" For GIT:
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

" (s/vimdiff/meld/ or whatever else you fancy...)
"
" Inside vimdiff, enable wrap (visible diffs past 80 columns)
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
"
" inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
"             \ "\<lt>C-n>" :
"             \ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
"             \ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
"             \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
" imap <C-@> <C-Space>


" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>



"
" Stop warning me about leaving a modified buffer
"
set hidden

"
" Show keystrokes as I type (command mode)
"
set showcmd

"
" Now that I use vim-paren-crosshairs, I need 256 colors in my console VIM
"
set t_Co=256

"
" After 'f' in normal mode, I always mistype 'search next' - use space for ';'
"
noremap <space> ;

"
" Manpage for word under cursor via 'K' in command mode
"
runtime ftplugin/man.vim
noremap <buffer> <silent> K :exe "Man" expand('<cword>') <CR>

"
" Now that I use the CtrlP plugin, a very useful shortcut is to open
" an XTerm in the folder of the currently opened file:
"
" noremap <silent> <F5> :!gnome-terminal -e "$SHELL --login -c 'cd %:p:h ; $SHELL'" &<CR><CR>
" noremap <silent> <Esc>OQ :!gnome-terminal -e "$SHELL --login -c 'cd %:p:h ; $SHELL'" &<CR><CR>
noremap <silent> <F5> :!xterm -e "cd %:p:h ; bash" &<CR><CR>
"noremap <silent> <Esc>OQ :!xterm -e "cd %:p:h ; bash" &<CR><CR>

let g:ctrlp_working_path_mode = 0
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=100
let g:ctrlp_custom_ignore='.git$|obj/|tmp$|preproce.*$'

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

" Toggle wrap/nowrap
nnoremap <silent> <leader>w :windo set wrap!<cr>
"
" Sacrilege: Make Ctrl-c act as 'Clipboard-copy' in visual select mode
"
vnoremap <C-c> "+y

"
" Default to very magic (I prefer normal Perl-y regexps)
"
nnoremap / /\v
vnoremap / /\v

"
" cd to the currently opened file's folder
"
command! Cdd cd %:p:h

"
" Greek-locale normal maps
"
noremap α a
noremap β b
noremap ψ c
noremap δ d
noremap ε e
noremap φ f
noremap γ g
noremap η h
noremap ι i
noremap ξ j
noremap κ k
noremap λ l
noremap μ m
noremap ν n
noremap ο o
noremap π p
noremap ρ r
noremap σ s
noremap τ t
noremap θ u
noremap ω v
noremap ς w
noremap χ x
noremap υ y
noremap ζ z

noremap Α A
noremap Β B
noremap Ψ C
noremap Δ D
noremap Ε E
noremap Φ F
noremap Γ G
noremap Η H
noremap Ι I
noremap Ξ J
noremap Κ K
noremap Λ L
noremap Μ M
noremap Ν N
noremap Ο O
noremap Π P
noremap Ρ R
noremap Σ S
noremap Τ T
noremap Θ U
noremap Ω V
noremap Σ W
noremap Χ X
noremap Υ Y
noremap Ζ Z

"
" Use EasyMotion to go anywhere in the screen in normal mode, with just '!'
"
nmap ! H\\w

"
" Somehow, in my latest update, a big foldcolumn appeared. Nip it in the bud!
"
se foldcolumn=0

"
" Reroute the :Ack to use the silver searcher - warp speed!
"
let g:ackprg = 'ag --nogroup --nocolor --column'

"
" VIMDIFF is far more useful when ignoring whitespace
"
set diffopt+=iwhite
set diffexpr=DiffW()
function DiffW()
  let opt = ""
   if &diffopt =~ "icase"
     let opt = opt . "-i "
   endif
   if &diffopt =~ "iwhite"
     let opt = opt . "-w " " swapped vim's -b with -w
   endif
   silent execute "!diff -a --binary " . opt .
     \ v:fname_in . " " . v:fname_new .  " > " . v:fname_out
endfunction

"
" Gitgutter use popup windows
"
let g:gitgutter_preview_win_floating = 1

"
" Gitgutter easier diff/stage/unstage
"
nnoremap <silent> <leader>d :GitGutterPreviewHunk<CR>
nnoremap <silent> <leader>s :GitGutterStageHunk<CR>
nnoremap <silent> <leader>u :GitGutterUndoHunk<CR>
nnoremap <silent> <F1> :GitGutterNextHunk<CR>

"""""""""""""""""""""""""""""""""""""""""""""
"
"       Language-specific section
"
"""""""""""""""""""""""""""""""""""""""""""""

" OBSOLETE - Disabled.
"
" First, use session management
" (From http://pm.veritablesoftware.com/slides/vim_for_perl_development/session_code.vimrc.html)
"
"
" Autoload and autosave sessions.                                                                                                     
autocmd VimEnter * call AutoLoadSession()
autocmd VimLeave * call AutoSaveSession()

function! AutoLoadSession()
    if argc() == 0
        perl << EOD
        use Digest::MD5 qw(md5_hex);
        use Cwd;
        my $session_md5_hash = md5_hex(cwd());
        my $session_path = "$ENV{HOME}/.vim/sessions/$session_md5_hash.session";
        if (-e $session_path) {
            VIM::DoCommand("silent source $session_path");
        }
EOD
    endif
endfunction

function! AutoSaveSession()
    if argc() == 0
        perl << EOD
        use Digest::MD5 qw(md5_hex);
        use Cwd;
        my $session_md5_hash = md5_hex(cwd());
        my $session_path = "$ENV{HOME}/.vim/sessions/$session_md5_hash.session";
        VIM::DoCommand("silent mksession! $session_path");
EOD
    endif
endfunction

"
" Tell Syntastic which files should be passive
" (and wait for user to press F7/F6 for validation)
"
let g:syntastic_mode_map = {
    \ 'mode': 'active',
    \ 'active_filetypes': [],
    \ 'passive_filetypes': ['python', 'cpp', 'c', 'typescript', 'java'] }

"
" For C and C++, use libclang, Luke.
"
let g:clang_use_library = 1
let g:clang_library_path = "/lib/x86_64-linux-gnu"
"
" Auto-format on save is sometimes wanted and sometimes not.
"
"
let g:clang_format_on_save = 1

function ToggleFormatOnSave()
    if g:clang_format_on_save == 1
        let g:clang_format_on_save = 0
        echo "Auto-format on save disabled"
    else
        let g:clang_format_on_save = 1
        echo "Auto-format on save ENABLED"
    endif
endfunction

function AutoSaveMaybe()
    if g:clang_format_on_save == 1
        echo "Formating ".line('$')." lines..."
        silent! execute ':ClangFormat'
    endif
endfunction

" (for CUDA .cu, too)
au BufNewFile,BufRead *.c,*.h call SetupCenviron()
au BufNewFile,BufRead *.cc,*.cpp,*.hh,*.cu call SetupCPPenviron()
au BufWritePre *.cpp call AutoSaveMaybe()
au BufWritePre *.cc  call AutoSaveMaybe()
au BufWritePre *.c   call AutoSaveMaybe()
au BufWritePre *.cu  call AutoSaveMaybe()
au BufWritePre *.h   call AutoSaveMaybe()
au BufWritePre *.hpp call AutoSaveMaybe()

fun! ShowFuncName()
  echohl ModeMsg
  echo getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bWn'))
  echohl None
endfun

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

function! SetupCandCPPenviron()
    "
    " Search path for 'gf' command (e.g. open #include-d files)
    "
    "set path+=/usr/include/c++/**

    "
    " For the ':A' (plugin) that swaps between header and impl file (C/C++)
    let g:alternateExtensions_cc = "inc,h,H,HPP,hpp"
    let g:alternateExtensions_CC = "inc,h,H,HPP,hpp"
    let g:alternateExtensions_cpp = "inc,h,H,HPP,hpp"
    let g:alternateExtensions_CPP = "inc,h,H,HPP,hpp"

    "
    " Tags
    "
    " If I ever need to generate tags on the fly, I uncomment this:
    " noremap <C-F11> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
    " set tags+=/usr/include/tags

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
    " F5 to toggle using clang-format to update on save - or not!
    " "
    noremap <silent> <F5> :call ToggleFormatOnSave()<CR>

    "
    " F6 to see the CocDiagnostics output
    "
    noremap <silent> <F6> :CocDiagnostics<CR>

    "
    " Remap F7 to make
    "
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>

    "
    " Remap F3 to show function name
    "
    noremap <buffer> <special> <F3> :CocCommand document.toggleInlayHint<CR>
    noremap <buffer> <Esc>OR :CocCommand document.toggleInlayHint<CR>

    "
    " Use the tags, Luke
    "
    noremap <buffer> <C-]> :tag <C-R>=expand('<cword>')<CR><CR>

    "
    " Use Coc to rename, Luke (with F2)
    "
    noremap <buffer> <silent> <F2> :CocCommand document.renameCurrentWord<CR>
    "
    " Work prefers these settings.
    " After using them for quite a while, I guess I like them too :-)
    "
    se shiftwidth=2
    se sts=2

    "
    " coc.nvim and LSP stuff. Mostly copied from here:
    "    https://github.com/neoclide/coc.nvim#example-vim-configuration
    "

    " Show me what you know about the symbol under the cursor
    nnoremap <silent> <leader>h :call CocActionAsync('doHover')<cr>

    " Refresh the clang diagnostics shown by Coc
    nnoremap <silent> <leader>r :CocRestart<cr>

    " Apply clang-tidy fixes to C++ code
    nnoremap <leader>f :execute ':!clang-tidy -p ' . shellescape(getcwd()) . ' --checks=modernize-type-traits --fix % -- -std=c++20 -x c++'<cr>

    " Always show the signcolumn, otherwise it would shift the text each time
    " diagnostics appear/become resolved
    set signcolumn=yes

    " Use tab for trigger completion with characters ahead and navigate
    " NOTE: There's always complete item selected by default, you may want to enable
    " no select by `"suggest.noselect": true` in your configuration file
    " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
    " other plugin before putting this into your config
    inoremap <silent><expr> <TAB>
          \ coc#pum#visible() ? coc#pum#next(1) :
          \ CheckBackspace() ? "\<Tab>" :
          \ coc#refresh()
    inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

    " Make <CR> to accept selected completion item or notify coc.nvim to format
    " <C-g>u breaks current undo, please make your own choice
    inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

    " Use <c-space> to trigger completion
    if has('nvim')
      inoremap <silent><expr> <c-space> coc#refresh()
    else
      inoremap <silent><expr> <c-@> coc#refresh()
    endif

    " Use `[g` and `]g` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)

    " GoTo code navigation
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " Remap <C-f> and <C-b> to scroll float windows/popups
    if has('nvim-0.4.0') || has('patch-8.2.0750')
      nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
      nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
      inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
      inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
      vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
      vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    endif
endfunction

function! SetupCenviron()
  call SetupCandCPPenviron()
  set commentstring=/*%s*/
endfunction

function! SetupCPPenviron()
  call SetupCandCPPenviron()
  set commentstring=//%s
endfunction

"
" For Python
"
au BufNewFile,BufRead *.py call SetupPythonEnviron()
function! SetupPythonEnviron()
    "
    " flake8: ignore 'too long lines'
    "
    let g:flake8_ignore="E501,E225,C103"

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

    "
    " Syntastic - Ignore 'too long lines' and 'missing whitespace around op'
    "
    let g:syntastic_python_checker_args = "--ignore=E501,E225"
    let g:syntastic_python_pylint_post_args = "--disable=C0103,C0301,W0212,C0111"

    "
    " Map SyntasticCheck to F6
    "
    noremap <buffer> <silent> <F6> :SyntasticCheck<CR>
    noremap! <buffer> <silent> <F6> <ESC>:SyntasticCheck<CR>

    " Somehow, ts for python files is autoset to 4. 
    " Only sts should be 4, nothing else.
    set ts=8

    "
    " Jedi auto-completion
    "
    :setlocal omnifunc=jedi#completions

endfunction

"
" OCaml
"

"
" Merlin
"
if executable('ocamlmerlin') && has('python')
    let s:ocamlmerlin = substitute(system('opam config var share'), '\n$', '', '''') . "/ocamlmerlin"
    execute "set rtp+=".s:ocamlmerlin."/vim"
    execute "set rtp+=".s:ocamlmerlin."/vimbufsync"
    let g:syntastic_ocaml_checkers = ['merlin']
endif

if executable('ocp-indent')
    let $OCPPATHVIM = substitute(system('opam config var share'), '\n$', '', '''') . "/vim/syntax/ocp-indent.vim"
    autocmd FileType ocaml source $OCPPATHVIM
endif

au BufNewFile,BufRead *.ml call SetupOCamlEnviron()
function! SetupOCamlEnviron()
    se shiftwidth=2
    "
    " Remap F7 to make if the file is an .ml one
    "
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>

    "
    " Thanks to Merlin
    "
    noremap <buffer> <silent> <F6> :SyntasticCheck<CR>
    noremap! <buffer> <silent> <F6> <ESC>:SyntasticCheck<CR>
    inoremap <buffer> <C-Space> <C-x><C-o>
    noremap <buffer> <C-]> :Locate<CR>
    inoremap <buffer> <C-]> <ESC>:Locate<CR>
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

"
" Markdown
"
let g:vim_markdown_folding_disabled = 1
set conceallevel=0

function ToggleConcealLevel()
    if &conceallevel == 2
        set conceallevel=0
        echo "conceallevel DISABLED"
    else
        set conceallevel=2
        echo "conceallevel ENABLED"
    endif
endfunction

au BufNewFile,BufRead *.md call SetupMDEnviron()
function! SetupMDEnviron()
    "
    " Remap F7 to make (I use custom Makefiles for .md)
    "
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>
    noremap <silent> <F6> :call ToggleConcealLevel()<CR>
endfunction

"
" LaTEX
"
au BufNewFile,BufRead *.tex call SetupTexEnviron()
function! SetupTexEnviron()
    "
    " Remap F7 to make (I use custom Makefiles for .tex)
    "
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>
endfunction

"
" HTML
"
au BufNewFile,BufRead *.htm,*.html call SetupHTMLenviron()
function! SetupHTMLenviron()
    "
    " I use custom Makefiles that do many things
    " (e.g. rules that invoke tidy, etc)
    "
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>

    "
    " Map SyntasticCheck with local HTML5 validator to F6
    "
    let g:syntastic_html_validator_api="http://localhost:8888"
    let g:syntastic_html_validator_parser="html5"
    noremap <buffer> <silent> <F6> :SyntasticCheck validator<CR>
    noremap! <buffer> <silent> <F6> <ESC>:SyntasticCheck validator<CR>
endfunction

"
" XML (Read my related blog post at http://ttsiodras.github.io/regexp.html)
"
" First, XSD-based autocompletion via ... erm... Eclim.
" There's no better way, currently... (ashamed, cowers in corner)
"
function! CommonEclim(myfiletype)
    "
    " Step 1: Make the file known to Eclipse, by hiting F8 (with .xml/.java file open)
    "
    exec printf('noremap <buffer> <F8> :ProjectCreate %%:p:h -n %s<CR>', a:myfiletype)
    exec printf('noremap! <buffer> <F8> :ProjectCreate %%:p:h -n %s<CR>', a:myfiletype)
    "
    " Step 2: Ctrl-x Ctrl-u is too difficult - for insert mode, map to TAB
    "
    inoremap <buffer> <C-Space> <C-x><C-u>
    "
    " Step 3: Auto-close preview window when insertion cursor moves (usually,
    "         by just hitting space) or escaping into normal mode.
    "
    autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
    autocmd InsertLeave * if pumvisible() == 0|pclose|endif
endfunction

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
    vnoremap <buffer> <Leader>= :Tabularize/\v\zs\w+\ze\=["']/l1l0<CR>

    " 
    " We sometimes need XSD-based autocompletion for .xml files
    " Step 1: Spawn eclimd in some screen
    " Step 2: Open your file, make sure filetype is xml (:se filetype)
    " Step 3: Unfortunately, eclim/eclipse sometimes get confused with BOM and DOS
    "         newlines... Hit F12 for instant dos2unix
    "
    noremap <buffer> <F12> :!dos2unix %:p<CR>
    noremap! <buffer> <F12> :!dos2unix %:p<CR>
    call CommonEclim("none")
endfunction

au BufNewFile,BufRead *.nrl call SetupXMLEnviron()

"
" Java autocompletion - also via Eclim
"
au BufNewFile,BufRead *.java call SetupJavaEnviron()
function! SetupJavaEnviron()
    call CommonEclim("java")
endfunction

"
" Typescript - autocompletion via typescript-tools plugin
" and custom Makefile-based builds...
"
let $PATH .= ':' . $HOME . '/.vim/bundle/typescript-tools/bin'
set rtp+=$HOME/.vim/bundle/typescript-tools/

au BufNewFile,BufRead *.ts call SetupTSEnviron()
au BufNewFile,BufRead *.tsx call SetupTSEnviron()
function! SetupTSEnviron()
    setlocal filetype=typescript
    se makeprg=make
    nnoremap <buffer> <F8> :TSSstarthere<CR>
    nnoremap <buffer> <F7> :make<CR>
    nnoremap <buffer> <C-]> :TsuquyomiDefinition<CR>
    nnoremap <buffer> \t :TSSsymbol<CR>
    set errorformat=%+A\ %#%f\ %#(%l\\\,%c):\ %m,%C%m
endfunction

"
" Work-related hell: People all around me use Windows,
" and their stupid editors put ^M everywhere.
" Hide them, when we are working with .stg files.
"
au BufNewFile,BufRead *.stg call SetupStringTemplateEnviron()
function! SetupStringTemplateEnviron()
    ed ++ff=dos %
endfunction

"
" .rst files (ReSTructured text)
"
au BufNewFile,BufRead *.rst call SetupRSTEnviron()
function! SetupRSTEnviron()
    setlocal filetype=rst
    nnoremap <buffer> <F7> :make html<CR>
endfunction

"
" .clj files (Clojure)
"
" The Clojure workflow goes like this:
" You 
"    lein repl
" and then you edit in VIM, where you
"    :Connect
" and attach to the port of your nrepl (shown during startup of 'lein repl')
" After that, I have mapped F7 to :Eval the function you are in... i.e. send
" it to the running repl, where you can call, inspect results, etc.
" F6 sends the whole file.
"
au BufNewFile,BufRead *.clj call SetupCLJEnviron()
function! SetupCLJEnviron()
se nohlsearch
noremap <buffer> <silent> K :exe "Doc" expand('<cword>') <CR>
vmap <buffer> <silent> <F7> :Eval<CR>
nmap <F7> ?^(<CR>V%:Eval<CR>%
nnoremap <buffer> <silent> <F6> ggVG:Eval<CR>
endfunction

"
" .rs files (Rust)
"
au BufNewFile,BufRead *.rs call SetupRSEnviron()
function! SetupRSEnviron()
    "
    " Remap F7 to make
    "
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>
endfunction

"
" .java files (Java)
"
au BufNewFile,BufRead *.java call SetupJavaEnviron()
function! SetupJavaEnviron()
    setlocal omnifunc=javacomplete#Complete
    nmap <F4> <Plug>(JavaComplete-Imports-AddSmart)
    nmap <F5> <Plug>(JavaComplete-Imports-Add)
    imap <F5> <Plug>(JavaComplete-Imports-Add)
    nmap <F6> <Plug>(JavaComplete-Imports-AddMissing)
    imap <F6> <Plug>(JavaComplete-Imports-AddMissing)
    nmap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)
    imap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>
endfunction

"
" .acn files
"
au BufNewFile,BufRead *.acn call SetupACNEnviron()
function! SetupACNEnviron()
    se filetype=acn
endfunction

"
" Cscope accelerators
"
if has("cscope")
        set csto=0
        set cst
        set nocsverb
        " add any database in current directory
        if filereadable("cscope.out")
            cs add cscope.out
        " else add database pointed to by environment
        elseif $CSCOPE_DB != ""
            cs add $CSCOPE_DB
        endif
        set csverb
endif

map <C-\> :cs find 0 <C-R>=expand("<cword>")<CR><CR>

"
" Looks like I don't need tmux anymore...
"
noremap <C-n> :terminal bash<CR>

"
" VHDL files
"
au BufNewFile,BufRead *.vhd call SetupVHDL()
function! SetupVHDL()
    se shiftwidth=4
    "
    " Remap F7 to make
    "
    set colorcolumn=80
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>
endfunction

"
" .s assembly files
"
au BufNewFile,BufRead *.s call SetupASM()
function! SetupASM()
    se shiftwidth=4
    "
    " Remap F7 to make
    "
    noremap <buffer> <special> <F7> :make<CR>
    noremap! <buffer> <special> <F7> <ESC>:make<CR>
endfunction

"
" Now read machine-local customizations
"
if filereadable(glob("~/.vimrc.local")) 
    source ~/.vimrc.local
endif

if has("gui_running")
let $GVIMCFG = $HOME . '/.gvimrc'
source $GVIMCFG
endif
