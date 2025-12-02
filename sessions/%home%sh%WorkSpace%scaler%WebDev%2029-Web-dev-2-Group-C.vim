let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/WorkSpace/scaler/WebDev/2029-Web-dev-2-Group-C
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
set shortmess+=aoO
badd +3 Class-1(Introduction\ to\ DOM)/4.html
badd +1 Class-1(Introduction\ to\ DOM)/dom.html
badd +11 ~/WorkSpace/scaler/WebDev/2029-Web-dev-2-Group-C/Class-1(Introduction\ to\ DOM)/3.html
badd +55 ~/WorkSpace/scaler/WebDev/2029-Web-dev-2-Group-C/Class-1(Introduction\ to\ DOM)/2.html
badd +38 ~/WorkSpace/scaler/WebDev/2029-Web-dev-2-Group-C/Class-1(Introduction\ to\ DOM)/1.html
badd +109 Class-2(Events\ in\ Detail)/6.html
badd +58 Class-2(Events\ in\ Detail)/5.html
badd +6 term://~/WorkSpace/scaler/WebDev/2029-Web-dev-2-Group-C//71089:/bin/fish
badd +1 Class-3(Kanban\ Board-1)/test.js
argglobal
%argdel
edit ~/WorkSpace/scaler/WebDev/2029-Web-dev-2-Group-C/Class-1(Introduction\ to\ DOM)/1.html
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
argglobal
balt Class-3(Kanban\ Board-1)/test.js
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
let s:l = 39 - ((17 * winheight(0) + 16) / 32)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 39
normal! 0
tabnext 1
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
