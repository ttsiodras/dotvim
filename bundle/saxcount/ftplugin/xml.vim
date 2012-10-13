se errorformat=%E,%CError\ at\ file\ %f%.\ line\ %l%.\ char\ %c,\ \ Message:\ %m,%Z
se makeprg=SAXCount\ -n\ -s\ -f\ %
noremap <buffer> <F7> :make<CR>
noremap! <buffer> <F7> :make<CR>
