let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/WorkSpace/Go/WebServer
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
set shortmess+=aoO
badd +87 main.go
badd +3 go.mod
badd +45 helpers.go
badd +5 readiness.go
badd +10 reset.go
badd +25 json.go
badd +1 index.html
badd +1 go.sum
badd +59 internal/auth/helpers_password_test.go
badd +33 internal/auth/helpers_password.go
badd +1 sql/queries/chiprs.sql
badd +16 sql/queries/users.sql
badd +43 internal/database/users.sql.go
badd +128 internal/database/chiprs.sql.go
badd +4 handlerLogin.go
badd +37 internal/database/models.go
badd +1 all
badd +44 handler_chiprs_get.go
badd +41 handler_chiprs_del.go
badd +17 handler_chiprs_create.go
badd +20 handler_users_update.go
badd +14 handler_users_login.go
badd +21 handler_users_create.go
badd +32 handler_webhooks.go
argglobal
%argdel
$argadd oil:///home/sh/WorkSpace/Go/WebServer/
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit internal/database/chiprs.sql.go
tcd ~/WorkSpace/Go/WebServer/internal/database
argglobal
balt ~/WorkSpace/Go/WebServer/internal/database/users.sql.go
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
let s:l = 120 - ((23 * winheight(0) + 17) / 35)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 120
normal! 03|
tabnext
edit ~/WorkSpace/Go/WebServer/json.go
argglobal
balt ~/WorkSpace/Go/WebServer/internal/auth/helpers_password_test.go
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
let s:l = 29 - ((28 * winheight(0) + 17) / 35)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 29
normal! 0
tabnext 2
set stal=1
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
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
