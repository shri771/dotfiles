let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd /home/sh/WorkSpace/meshery/meshery/server
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +182 handlers/mesh_ops_handlers.go
badd +63 /home/sh/WorkSpace/meshery/meshery/server/models/preference.go
badd +26 /home/sh/WorkSpace/meshery/meshery/server/models/adapter.go
badd +49 ~/go/pkg/mod/github.com/meshery/meshkit@v0.8.53/models/events/build.go
badd +1 models/connections/connections.go
badd +695 handlers/connections_handlers.go
badd +318 /home/sh/WorkSpace/meshery/meshery/server/handlers/error.go
badd +272 /nix/store/0a3dyfq09dnkw28ap2i450wjimvdmv6s-go-1.25.4/share/go/src/builtin/builtin.go
badd +45 ~/go/pkg/mod/github.com/meshery/schemas@v0.8.93/models/v1beta1/connection/connection.go
argglobal
%argdel
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit handlers/mesh_ops_handlers.go
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
balt /nix/store/0a3dyfq09dnkw28ap2i450wjimvdmv6s-go-1.25.4/share/go/src/builtin/builtin.go
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
let s:l = 182 - ((11 * winheight(0) + 15) / 31)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 182
normal! 051|
tabnext
edit handlers/connections_handlers.go
argglobal
balt ~/go/pkg/mod/github.com/meshery/schemas@v0.8.93/models/v1beta1/connection/connection.go
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
let s:l = 695 - ((15 * winheight(0) + 15) / 31)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 695
normal! 099|
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
