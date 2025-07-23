Make sure that clangd-mine contains:

```
#!/bin/bash
exec /usr/local/bin/clangd  --query-driver=/usr/lib/ccache/g++-11 --header-insertion=never --background-index=0 "$@"
```

Now, to debug things like the cursed `--background-index=0` above (that drove me mad,
opening compile-commands.json from other folders (!), I had to switch to a much more bare-bones
coc-settings.json setup:

```
{
  "clangd.path": "/usr/local/bin/clangd-mine",

  "inlayHint.display": false,

  "coc.preferences.previewAutoClose": false,
  "coc.preferences.previewSize": 35,

  "coc.preferences.rootPatterns": [
    "compile_commands.json",
    "compile_flags.txt",
    ".clangd"
  ],

  "diagnostic.checkCurrentLine": true,

  "clangd.arguments": [
    "--log=verbose",
    "--header-insertion=never",
    "--query-driver=/usr/lib/ccache/g++-11",
    "--background-index=0"
  ],

  "clangd.trace.server": "verbose"
}
```

...and then, after launching vim, `:CocInstall coc-clangd` and `:CocRestart`, I was able to issue:

```
:CocCommand workspace.showOutput clangd
```

...and that's where I saw that I was loading two compilation databases.
