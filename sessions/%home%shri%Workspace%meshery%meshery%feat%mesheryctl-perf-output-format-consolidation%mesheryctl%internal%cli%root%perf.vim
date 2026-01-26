let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/Workspace/meshery/meshery/feat/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/perf
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +71 profile.go
badd +147 ~/Workspace/meshery/meshery/feat/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/perf/result.go
badd +111 ~/Workspace/meshery/meshery/feat/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/perf/apply.go
badd +226 ~/Workspace/meshery/meshery/feat/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/root.go
badd +29 ~/Workspace/meshery/meshery/feat/mesheryctl-perf-output-format-consolidation/mesheryctl/pkg/utils/helpers.go
argglobal
%argdel
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit ~/Workspace/meshery/meshery/feat/mesheryctl-perf-output-format-consolidation/mesheryctl/internal/cli/root/root.go
argglobal
balt profile.go
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
let s:l = 226 - ((18 * winheight(0) + 15) / 30)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 226
normal! 019|
tabnext
edit ~/Workspace/meshery/meshery/feat/mesheryctl-perf-output-format-consolidation/mesheryctl/pkg/utils/helpers.go
argglobal
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
let s:l = 29 - ((14 * winheight(0) + 15) / 30)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 29
normal! 033|
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
