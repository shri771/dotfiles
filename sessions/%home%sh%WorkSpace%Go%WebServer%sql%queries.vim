let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/WorkSpace/Go/WebServer/sql
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
set shortmess+=aoO
badd +3 schema/001_users.sql
badd +6 schema/004_refresh_tokens.sql
badd +1 schema/002_chirps.sql
badd +33 queries/chiprs.sql
badd +0 oil:///home/sh/WorkSpace/Go/WebServer/sql/
argglobal
%argdel
$argadd oil:///home/sh/WorkSpace/Go/WebServer/sql/
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit queries/chiprs.sql
tcd ~/WorkSpace/Go/WebServer/sql/queries
argglobal
balt ~/WorkSpace/Go/WebServer/sql/schema/001_users.sql
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
let s:l = 33 - ((24 * winheight(0) + 17) / 34)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 33
normal! 05|
tabnext
edit ~/WorkSpace/Go/WebServer/sql/schema/002_chirps.sql
tcd ~/WorkSpace/Go/WebServer/sql/schema
argglobal
balt ~/WorkSpace/Go/WebServer/sql/schema/004_refresh_tokens.sql
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
let s:l = 7 - ((6 * winheight(0) + 17) / 34)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 7
normal! 017|
tabnext 1
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
