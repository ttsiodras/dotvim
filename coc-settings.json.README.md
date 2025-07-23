Make sure that clangd-mine contains:

#!/bin/bash
exec /usr/local/bin/clangd  --query-driver=/usr/lib/ccache/g++-11 --header-insertion=never --background-index=0 "$@"
