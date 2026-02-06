let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/Workspace/meshery/meshery/master
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +124 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter/view.go
badd +37 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter/error.go
badd +119 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/relationships/view.go
badd +721 ~/go/pkg/mod/golang.org/toolchain@v0.0.1-go1.25.5.linux-amd64/src/io/io.go
badd +52 ~/go/pkg/mod/github.com/ghodss/yaml@v1.0.0/yaml.go
badd +261 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/pkg/utils/helpers.go
badd +99 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/pkg/utils/auth.go
badd +30 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter/view_test.go
badd +1 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter/testdata/view.id.filter.output.golden
badd +1 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter/fixtures/view.id.filter.api.response.golden
badd +1 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter/testdata/view.nonexisting.filter.output.golden
badd +1 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter/fixtures/view.filter.api.response.golden
badd +53 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter/import.go
badd +57 ~/go/pkg/mod/github.com/meshery/meshkit@v0.8.64/logger/logger.go
badd +20 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/pkg/utils/formatter.go
badd +17 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/pkg/api/meshery.go
badd +113 mesheryctl/internal/cli/root/filter/view.go
badd +1 mesheryctl/internal/cli/root/filter/testdata/view.filter.output.golden
badd +1 ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter/testdata/view.filter.output.golden
badd +1 mesheryctl/internal/cli/root/filter/fixtures/view.filter.api.response.golden
argglobal
%argdel
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter/view.go
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
balt mesheryctl/internal/cli/root/filter/view.go
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
let s:l = 124 - ((19 * winheight(0) + 15) / 30)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 124
normal! 061|
lcd ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter
tabnext
edit ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter/view_test.go
argglobal
balt ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter/view.go
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
let s:l = 30 - ((17 * winheight(0) + 15) / 30)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 30
normal! 033|
lcd ~/Workspace/meshery/meshery/refactor/filter-output-format-consolidation/mesheryctl/internal/cli/root/filter
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
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
