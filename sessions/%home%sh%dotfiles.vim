let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/dotfiles
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
set shortmess+=aoO
badd +1 /tmp/gemini-cli-tool-modify-diffs/gemini-cli-modify-rc-old-1751727508486.lua
badd +374 /tmp/gemini-cli-tool-modify-diffs/gemini-cli-modify-rc-new-1751727508486.lua
argglobal
%argdel
$argadd /tmp/gemini-cli-tool-modify-diffs/gemini-cli-modify-rc-old-1751727508486.lua
$argadd /tmp/gemini-cli-tool-modify-diffs/gemini-cli-modify-rc-new-1751727508486.lua
edit /tmp/gemini-cli-tool-modify-diffs/gemini-cli-modify-rc-old-1751727508486.lua
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
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
exe 'vert 1resize ' . ((&columns * 73 + 73) / 147)
exe 'vert 2resize ' . ((&columns * 73 + 73) / 147)
argglobal
setlocal foldmethod=diff
setlocal foldexpr=v:lua.vim.treesitter.foldexpr()
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldenable
let s:l = 374 - ((21 * winheight(0) + 20) / 40)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 374
let s:c = 66 - ((50 * winwidth(0) + 36) / 73)
if s:c > 0
  exe 'normal! ' . s:c . '|zs' . 66 . '|'
else
  normal! 066|
endif
wincmd w
argglobal
2argu
balt /tmp/gemini-cli-tool-modify-diffs/gemini-cli-modify-rc-old-1751727508486.lua
setlocal foldmethod=diff
setlocal foldexpr=v:lua.vim.treesitter.foldexpr()
setlocal foldmarker={{{,}}}
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldenable
let s:l = 374 - ((21 * winheight(0) + 20) / 40)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 374
let s:c = 79 - ((63 * winwidth(0) + 36) / 73)
if s:c > 0
  exe 'normal! ' . s:c . '|zs' . 79 . '|'
else
  normal! 079|
endif
wincmd w
2wincmd w
exe 'vert 1resize ' . ((&columns * 73 + 73) / 147)
exe 'vert 2resize ' . ((&columns * 73 + 73) / 147)
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
