let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/Workspace/Orkflow.git/feat/add-parser
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +15 ~/Workspace/Orkflow.git/feat/add-parser/pkg/types/agent.go
badd +13 internal/parser/parser.go
badd +8 ~/Workspace/Orkflow.git/feat/add-parser/pkg/types/worflow.go
badd +5 ~/Workspace/Orkflow.git/feat/add-parser/pkg/types/config.go
badd +9 pkg/types/model.go
badd +3 ~/Workspace/Orkflow.git/feat/add-parser/pkg/types/workflow.go
badd +2 ~/Workspace/Orkflow.git/feat/add-parser/internal/parser/validate.go
badd +3 ~/Workspace/Orkflow.git/feat/add-parser/internal/agent/agent.go
badd +14 internal/agent/context.go
badd +18 ~/Workspace/Orkflow.git/feat/add-parser/internal/agent/llm.go
argglobal
%argdel
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit ~/Workspace/Orkflow.git/feat/add-parser/internal/agent/llm.go
argglobal
balt ~/Workspace/Orkflow.git/feat/add-parser/internal/agent/agent.go
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
let s:l = 18 - ((12 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 18
normal! 09|
tabnext
edit ~/Workspace/Orkflow.git/feat/add-parser/pkg/types/workflow.go
argglobal
balt ~/Workspace/Orkflow.git/feat/add-parser/pkg/types/config.go
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
let s:l = 3 - ((2 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 3
normal! 06|
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
