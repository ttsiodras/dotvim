
These are my VIM settings, mostly targeting development with C, C++ and Python.

Here is a [Vimeo-hosted video](http://vimeo.com/37875339) showing some of
the things I can do when I work in C or C++. You can also
[download](http://www.mediafire.com/file/ge1imhbivswsixr/Vim.C.and.C++.flv)
a high resolution version of the video for offline playback, using
[MPlayer](http://www.mplayerhq.hu) or [VideoLAN](http://www.videolan.org/).

I use a small number of plugins, and did some minor customization for
keyboard shortcuts. The plugins are maintained with pathogen, and
are placed under bundle/ via Git submodules (so I always have the latest
plugin versions).

Installation
-------------

In any new machine/account I need to work on, I clone from the repository:

    cd
    git clone https://github.com/ttsiodras/dotvim .vim
    cd .vim
    git submodule init
    git submodule update
    cd ..
    ln -s .vim/.vimrc

I therefore use the same VIM environment in all my machines.

For C/C++ development
---------------------

I create /usr/include/tags:

    (become root via su/sudo)
    cd /usr/include
    ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .

My .vimrc is set to use these, as well as any local "tags" I build
in my project-specific Makefiles:

    set tags+=/usr/include/tags

I use [clang complete](http://www.vim.org/scripts/script.php?script_id=3302)
  to get Intellisense-like autocompletion (see the video above).

The 'A' plugin allows me to quickly switch between .h/c{c,pp} with ':A'

Pressing 'K' shows manpages on the symbol under the cursor in an "inner window"
(which allows me to copy/paste). I quickly close the manpage "window" with Ctrl-F12.

F8 shows taglists (macros/types/variables/functions/classes).

For Python development
----------------------

I've mapped F7 to invoke flake8 (install it with: "easy_install flake8") to get
static analysis error reports from "pyflakes" and style issues from "pep8", navigating
from error to error in the usual way (":cn", ":cp")

I've also added a "screen" based SLIME-like environment. Here's a
[demonstration of the process on Vimeo](http://www.vimeo.com/37894593)
and an [HD version](http://www.mediafire.com/file/zz9gpv3095fkizl/Vim.SLIME.flv)
that you can download for offline playback, using [MPlayer](http://www.mplayerhq.hu)
or [VideoLAN](http://www.videolan.org/).


Basically, spawn a screen session via...

    screen -c python.screenrc

(or "python.screenrc.for.ArchLinux" if your screen doesn't support the "split -v"
command) and you will get two screen windows: one with a VIM, one with a python
instance. Navigate to whatever function/class you want in VIM, and hit Ctrl-c Ctrl-c
(i.e. Ctrl-c twice). This will send the function/class to the running python instance.
You can switch between VIM and python via Alt-[ and Alt-]

Generic stuff
-------------

I've mapped:

- NERDTreeToggle to F10, for direct access to "file manager" interface
- Ctrl-cursors to navigate windows (under both XTerms and GVim)
- Ctrl-L to clear search results (hate seeing yellow stuff after search)
- Ctrl-F12 to quickly close "window" (buffer)
- I also have easy motion in, so I can navigate to any place in the screen
  with a simple \\\\w followed by a character. Amazing plugin.

Am I insane to use VIM?
-----------------------
[No,](http://www.viemu.com/a-why-vi-vim.html) I am [not](http://users.softlab.ntua.gr/~ttsiod/vim.html).
