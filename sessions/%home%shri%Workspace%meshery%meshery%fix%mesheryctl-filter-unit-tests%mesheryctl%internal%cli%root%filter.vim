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
badd +65 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/delete_test.go
badd +73 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/delete.go
badd +160 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/list.go
badd +365 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/pkg/utils/testing.go
badd +28 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/pkg/utils/formatter.go
badd +69 ~/go/pkg/mod/github.com/meshery/meshkit@v0.8.63/logger/logger.go
badd +10 ~/go/pkg/mod/github.com/meshery/meshkit@v0.8.63/logger/types.go
badd +98 ~/go/pkg/mod/github.com/sirupsen/logrus@v1.9.4-0.20230606125235-dd1b4c2e81af/logger.go
badd +455 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/pkg/utils/error.go
badd +46 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/error.go
badd +1259 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/pkg/utils/helpers.go
badd +70 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/view.go
badd +25 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/filter.go
badd +111 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/config/config.go
badd +137 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/import.go
badd +14 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/list_test.go
badd +53 mesheryctl/internal/cli/root/filter/list_test.go
badd +5 mesheryctl/internal/cli/root/filter/fixtures/list.filter.api.response.golden
badd +84 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/filter_test.go
badd +1 ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/testdata/filter.invalidID.view.output.golden
badd +117 mesheryctl/internal/cli/root/filter/view.go
badd +1 server/cmd/error.go
badd +147 ~/go/pkg/mod/github.com/eiannone/keyboard@v0.0.0-20220611211555-0d226195f203/keyboard_common.go
argglobal
%argdel
set stal=2
tabnew +setlocal\ bufhidden=wipe
tabrewind
edit ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/view.go
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
let s:l = 117 - ((11 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 117
normal! 048|
lcd ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter
tabnext
edit ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/list.go
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
balt ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter/import.go
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
let s:l = 160 - ((16 * winheight(0) + 13) / 27)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 160
normal! 036|
lcd ~/Workspace/meshery/meshery/fix/mesheryctl-filter-unit-tests/mesheryctl/internal/cli/root/filter
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
