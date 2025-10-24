let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/WorkSpace/tenv
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
set shortmess+=aoO
badd +278 ~/WorkSpace/tenv/cmd/tenv/tenv.go
badd +49 ~/WorkSpace/tenv/config/config.go
badd +44 ~/WorkSpace/tenv/config/utils/utils.go
badd +95 ~/WorkSpace/tenv/config/envname/env.go
badd +390 /usr/lib/go/src/runtime/extern.go
badd +149 ~/WorkSpace/tenv/pkg/loghelper/loghelper.go
badd +46 ~/go/pkg/mod/github.com/hashicorp/hcl/v2@v2.24.0/hclparse/parser.go
badd +154 ~/WorkSpace/tenv/cmd/tenv/textui.go
argglobal
%argdel
edit ~/WorkSpace/tenv/config/config.go
argglobal
balt ~/WorkSpace/tenv/cmd/tenv/tenv.go
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
let s:l = 57 - ((20 * winheight(0) + 16) / 33)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 57
normal! 015|
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
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
