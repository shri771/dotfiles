let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/Workspace/meshery/meshery/fix/mesehryctl-adapter-unit-tests
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +137 mesheryctl/internal/cli/root/adapter/deploy_test.go
badd +49 term://~/Workspace/meshery/meshery/fix/mesehryctl-adapter-unit-tests/mesheryctl/internal/cli/root/adapter//12052:/run/current-system/sw/bin/fish
badd +6205 term://~/Workspace/meshery/meshery/fix/mesehryctl-adapter-unit-tests//17119:/run/current-system/sw/bin/fish
argglobal
%argdel
argglobal
if bufexists(fnamemodify("term://~/Workspace/meshery/meshery/fix/mesehryctl-adapter-unit-tests//17119:/run/current-system/sw/bin/fish", ":p")) | buffer term://~/Workspace/meshery/meshery/fix/mesehryctl-adapter-unit-tests//17119:/run/current-system/sw/bin/fish | else | edit term://~/Workspace/meshery/meshery/fix/mesehryctl-adapter-unit-tests//17119:/run/current-system/sw/bin/fish | endif
if &buftype ==# 'terminal'
  silent file term://~/Workspace/meshery/meshery/fix/mesehryctl-adapter-unit-tests//17119:/run/current-system/sw/bin/fish
endif
balt mesheryctl/internal/cli/root/adapter/deploy_test.go
setlocal foldmethod=manual
setlocal foldexpr=0
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal nofoldenable
let s:l = 6205 - ((20 * winheight(0) + 15) / 31)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 6205
normal! 0
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
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
