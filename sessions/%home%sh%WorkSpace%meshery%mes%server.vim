let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/WorkSpace/meshery/mes/server
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
set shortmess+=aoO
badd +76 router/server.go
badd +23 ~/WorkSpace/meshery/mes/server/models/handlers.go
badd +141 ~/WorkSpace/meshery/mes/server/handlers/middlewares.go
badd +378 ~/WorkSpace/meshery/mes/server/models/providers.go
badd +58 ~/WorkSpace/meshery/mes/server/models/remote_provider.go
badd +21 ~/WorkSpace/meshery/mes/server/handlers/handler_instance.go
badd +14 ~/WorkSpace/meshery/mes/server/handlers/middlewares_test.go
badd +161 ~/WorkSpace/meshery/mes/server/handlers/common_handlers.go
badd +20 ~/WorkSpace/meshery/mes/server/core/redirects.go
badd +228 ~/WorkSpace/meshery/mes/server/models/default_local_provider.go
badd +245 ~/WorkSpace/meshery/mes/server/models/remote_auth.go
badd +431 ~/WorkSpace/meshery/mes/server/models/error.go
badd +452 /usr/lib/go/src/net/http/request.go
badd +371 /usr/lib/go/src/net/http/cookie.go
badd +139 cmd/main.go
badd +17 handlers/pattern_handler_test.go
badd +1 health://
badd +429 /usr/lib/go/src/encoding/base64/base64.go
argglobal
%argdel
edit ~/WorkSpace/meshery/mes/server/models/remote_auth.go
argglobal
balt router/server.go
setlocal foldmethod=manual
setlocal foldexpr=0
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal nofoldenable
silent! normal! zE
let &fdl = &fdl
let s:l = 245 - ((14 * winheight(0) + 15) / 31)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 245
normal! 0
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
