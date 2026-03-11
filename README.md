Intro
-----
These are my VIM settings, mostly targeting development with C, C++ and Python.
I wrote a detailed blog post more than a decade ago about
[why I use VIM](https://www.thanassis.space/myvim.html). Many things changed
since then in terms of adopted solutions; but the core message still stands :-)

I use a small number of plugins, that keeps increasing over the years.

The plugins are maintained with pathogen and vim-plug, with the former placed
under bundle/ via Git submodules (so I control the exact plugin versions I use).

**UPDATE, 2026/March**: I added an isolated/ folder that allows you to work with
your vim using namespaces that **forbid network access**; and you can choose either
**complete** isolation, or **partial** *(enabling a whitelist of servers)*.
You can therefore use your plugins/language servers without worrying about
potential information leaks. 

Translation: yeah, I need language servers - but that doesn't mean I should
be trusting them :-)

Read details about how this works [here](isolated/vim).

Installation
-------------

In any new machine/account I need to work on, I clone from the repository:

    cd
    git clone --no-recurse-submodules https://github.com/ttsiodras/dotvim .vim
    cd .vim
    git submodule init
    git submodule update
    git submodule foreach --recursive git reset --hard
    cd ..
    ln -s .vim/.vimrc

I therefore use the same VIM environment in all my machines.

For C/C++ development
---------------------

Begin with `:PlugInstall` - `neoclide/coc.nvim` will be installed, and if you have a clangd available, that will be used to drive your language-aware autocompletion and navigation. 

*UPDATE*: I am actually now using a "proxy":

    $ cat /usr/local/bin/clangd-mine
    #!/bin/bash
    exec /usr/bin/clangd \
        --header-insertion=never \
        --background-index=0 "$@"

...because I am sick of some default behaviors :-)

Note also that the language server seems to have issues with the latest version of node in my Arch; but that's not really much of a problem: Just add a version that works in front of your PATH:

    $ cd
    $ mkdir -p local
    $ cd local
    $ wget -q -O- \
      https://nodejs.org/dist/v16.19.0/node-v16.19.0-linux-x64.tar.xz |\
      tar -Jxvf -

...and add `$HOME/local/node-v16.19.0-linux-x64/bin` in front of your PATH.
After that, your language server will work fine.

I have a lot of accumulated minutae in my setup (see `SetupCandCPPenviron`
in my `.vimrc` for details); e.g. the 'A' plugin allows me to quickly switch between .h/c{c,pp} with ':A'; 'K' shows manpages on the symbol under the cursor in an "inner window" (which allows me to copy/paste); auto-format with clang-format on every save; etc.

After a `:make` (F7) I navigate from error to next error via F4; as for the LS diagnostics, they are always available in list form via F6.

For Python development
----------------------

Current preferred LS is pyright (`:CocInstall coc-pyright`). Works very nicely; I also have F7 mapped to flake8 and F6 mapped to pylint.

For XML
-------
F7 is mapped to SAXCount (the Xerces XML validator) and F4 navigates
from each error (reported by SAXCount) to the next.

Here's a [blog post](https://www.thanassis.space/regexp.html) I wrote about using these.

Generic stuff
-------------

I've mapped:

- NERDTreeToggle to F10, for direct access to "file manager" interface
- TAB and Shift-TAB (in normal mode) cycle buffers
- Ctrl-l to clear search results (hate seeing yellow stuff after search)
- I've also installed the easymotion plugin, so I can navigate to any place in the screen with a simple \\\\w followed by a character. Amazing plugin.

...and there's much more. The point isn't for you to use my setup; the whole point with programmable editors is to tweak them to your liking. 

Use my setup as one more source of inspiration, nothing more.

Am I insane to use VIM?
-----------------------
[No,](https://web.archive.org/web/20250427210530/https://www.viemu.com/a-why-vi-vim.html) I am [not](https://www.thanassis.space/myvim.html).

How to add more plugins?
------------------------
Just...
    git submodule add https://.... bundle/something

How to uninstall a plugin?
--------------------------
Just...
    git submodule deinit bundle/something
    git rm bundle/something
    git rm --cached bundle/something
    rm -rf .git/modules/bundle/something
