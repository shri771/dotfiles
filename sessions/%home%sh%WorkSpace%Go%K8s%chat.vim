let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/WorkSpace/Go/K8s/chat
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
set shortmess+=aoO
badd +6 ~/WorkSpace/Go/K8s/chat/web-deployment.yml
badd +1 ~/WorkSpace/Go/K8s/chat/synergycha-configmap.yml
badd +6 ~/WorkSpace/Go/K8s/chat/synergychat-api-configmap.yml
badd +1 api-service.yaml
badd +35 crawler-deployment.yml
badd +5 synergychat-crawler-configmap.yml
badd +5 crawler-service.yaml
badd +11 web-service.yaml
badd +5 ~/WorkSpace/Go/K8s/chat/api-pvc.yaml
badd +1 term://~/WorkSpace/Go/K8s/chat//430255:/bin/fish
badd +5 health://
badd +22 ~/WorkSpace/Go/K8s/chat/testcpu-deployment.yaml
badd +4 ~/WorkSpace/Go/K8s/chat/api-httprout.yaml
badd +29 ~/WorkSpace/Go/K8s/chat/api-deployment.yaml
badd +11 ~/WorkSpace/Go/K8s/chat/testcpu-hpa.yaml
badd +9 ~/WorkSpace/Go/K8s/chat/web-hpa.yaml
argglobal
%argdel
edit ~/WorkSpace/Go/K8s/chat/web-hpa.yaml
argglobal
balt ~/WorkSpace/Go/K8s/chat/testcpu-hpa.yaml
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
let s:l = 9 - ((8 * winheight(0) + 15) / 31)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 9
normal! 011|
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
