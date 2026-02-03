let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/relationships
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +102 view.go
badd +227 ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/pkg/utils/error.go
badd +36 ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/model/list.go
badd +1 ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/model/model.go
badd +34 ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/pkg/api/meshery.go
badd +38 ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/relationships/relationship.go
badd +18 ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/model/view.go
badd +74 ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/connections/view.go
badd +52 ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/connections/connection.go
badd +20 ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/connections/error.go
badd +25 ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/pkg/display/output.go
argglobal
%argdel
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit view.go
argglobal
balt ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/relationships/relationship.go
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
let s:l = 102 - ((20 * winheight(0) + 15) / 31)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 102
normal! 0
tabnext
edit ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/connections/view.go
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
balt ~/Workspace/meshery/meshery/refactor/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/pkg/display/output.go
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
let s:l = 74 - ((11 * winheight(0) + 14) / 29)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 74
normal! 0
tabnext 2
set stal=1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
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
