let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/WorkSpace/158309813/dna
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +39 ~/WorkSpace/158309813/dna/dna.py
badd +1 sequences/2.txt
argglobal
%argdel
$argadd .
edit ~/WorkSpace/158309813/dna/dna.py
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
wincmd _ | wincmd |
split
3wincmd k
wincmd w
wincmd w
wincmd w
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe '1resize ' . ((&lines * 9 + 20) / 41)
exe 'vert 1resize ' . ((&columns * 40 + 73) / 146)
exe '2resize ' . ((&lines * 9 + 20) / 41)
exe 'vert 2resize ' . ((&columns * 40 + 73) / 146)
exe '3resize ' . ((&lines * 9 + 20) / 41)
exe 'vert 3resize ' . ((&columns * 40 + 73) / 146)
exe '4resize ' . ((&lines * 9 + 20) / 41)
exe 'vert 4resize ' . ((&columns * 40 + 73) / 146)
exe '5resize ' . ((&lines * 28 + 20) / 41)
exe 'vert 5resize ' . ((&columns * 105 + 73) / 146)
exe '6resize ' . ((&lines * 10 + 20) / 41)
exe 'vert 6resize ' . ((&columns * 77 + 73) / 146)
exe '7resize ' . ((&lines * 10 + 20) / 41)
exe 'vert 7resize ' . ((&columns * 27 + 73) / 146)
argglobal
enew
file DAP\ Scopes
balt ~/WorkSpace/158309813/dna/dna.py
setlocal foldmethod=manual
setlocal foldexpr=0
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal nofoldenable
wincmd w
argglobal
enew
file DAP\ Breakpoints
setlocal foldmethod=manual
setlocal foldexpr=0
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal nofoldenable
wincmd w
argglobal
enew
file DAP\ Stacks
setlocal foldmethod=manual
setlocal foldexpr=0
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal nofoldenable
wincmd w
argglobal
enew
file DAP\ Watches
setlocal foldmethod=manual
setlocal foldexpr=0
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal nofoldenable
wincmd w
argglobal
balt sequences/2.txt
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
let s:l = 39 - ((13 * winheight(0) + 14) / 28)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 39
normal! 0
wincmd w
argglobal
enew
file \[dap-repl-86]
balt ~/WorkSpace/158309813/dna/dna.py
setlocal foldmethod=manual
setlocal foldexpr=0
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal nofoldenable
wincmd w
argglobal
if bufexists(fnamemodify("\[dap-terminal]\ file:args", ":p")) | buffer \[dap-terminal]\ file:args | else | edit \[dap-terminal]\ file:args | endif
if &buftype ==# 'terminal'
  silent file \[dap-terminal]\ file:args
endif
setlocal foldmethod=manual
setlocal foldexpr=0
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal nofoldenable
let s:l = 1 - ((0 * winheight(0) + 5) / 10)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
normal! 0
wincmd w
5wincmd w
exe '1resize ' . ((&lines * 9 + 20) / 41)
exe 'vert 1resize ' . ((&columns * 40 + 73) / 146)
exe '2resize ' . ((&lines * 9 + 20) / 41)
exe 'vert 2resize ' . ((&columns * 40 + 73) / 146)
exe '3resize ' . ((&lines * 9 + 20) / 41)
exe 'vert 3resize ' . ((&columns * 40 + 73) / 146)
exe '4resize ' . ((&lines * 9 + 20) / 41)
exe 'vert 4resize ' . ((&columns * 40 + 73) / 146)
exe '5resize ' . ((&lines * 28 + 20) / 41)
exe 'vert 5resize ' . ((&columns * 105 + 73) / 146)
exe '6resize ' . ((&lines * 10 + 20) / 41)
exe 'vert 6resize ' . ((&columns * 77 + 73) / 146)
exe '7resize ' . ((&lines * 10 + 20) / 41)
exe 'vert 7resize ' . ((&columns * 27 + 73) / 146)
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
