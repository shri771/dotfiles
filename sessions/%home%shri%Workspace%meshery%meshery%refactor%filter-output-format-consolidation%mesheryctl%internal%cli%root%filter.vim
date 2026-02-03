let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +177 view.go
badd +37 error.go
badd +101 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/relationships/view.go
badd +721 ~/go/pkg/mod/golang.org/toolchain@v0.0.1-go1.25.5.linux-amd64/src/io/io.go
badd +52 ~/go/pkg/mod/github.com/ghodss/yaml@v1.0.0/yaml.go
badd +705 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/pkg/utils/helpers.go
badd +99 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/pkg/utils/auth.go
argglobal
%argdel
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit view.go
argglobal
balt ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/pkg/utils/auth.go
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
let s:l = 177 - ((13 * winheight(0) + 14) / 29)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 177
normal! 09|
tabnext
edit ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/relationships/view.go
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
let s:l = 119 - ((17 * winheight(0) + 14) / 29)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 119
normal! 04|
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
