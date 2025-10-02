let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd /home/sh/dotfiles
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
set shortmess+=aoO
badd +23 awesome/scripts/toggle_realmebuds_bind.sh
badd +0 fish/config.fish
badd +0 fish/fish_variables
badd +0 hypr/UserConfigs/UserSettings.conf
badd +0 hypr/scripts/ScreenShot.sh
badd +0 kdeglobals
badd +0 nvim/lazy-lock.json
badd +0 nvim/lua/custom/plugins/copilot.lua
badd +0 nvim/lua/custom/plugins/debugger.lua
badd +0 nvim/lua/custom/plugins/lsp.lua
badd +0 scripts/system/setup_firewall.sh
badd +0 sessions/\%home\%sh\%WorkSpace\%Go\%WebServer.vim
badd +0 sessions/\%home\%sh\%WorkSpace\%Go_boot.dev\%practice.vim
badd +0 sessions/\%home\%sh\%WorkSpace\%scaler\%Java\%Practice.vim
badd +0 sessions/\%home\%sh\%WorkSpace\%scaler\%WebDev\%protfolio.vim
badd +0 sessions/\%home\%sh\%dotfiles\%awesome.vim
badd +0 sessions/\%home\%sh\%dotfiles\%hypr.vim
badd +0 sessions/\%home\%sh\%dotfiles\%nvim.vim
badd +0 swaync/style.css
argglobal
%argdel
$argadd awesome/scripts/toggle_realmebuds_bind.sh
$argadd fish/config.fish
$argadd fish/fish_variables
$argadd hypr/UserConfigs/UserSettings.conf
$argadd hypr/scripts/ScreenShot.sh
$argadd kdeglobals
$argadd nvim/lazy-lock.json
$argadd nvim/lua/custom/plugins/copilot.lua
$argadd nvim/lua/custom/plugins/debugger.lua
$argadd nvim/lua/custom/plugins/lsp.lua
$argadd scripts/system/setup_firewall.sh
$argadd sessions/\%home\%sh\%WorkSpace\%Go\%WebServer.vim
$argadd sessions/\%home\%sh\%WorkSpace\%Go_boot.dev\%practice.vim
$argadd sessions/\%home\%sh\%WorkSpace\%scaler\%Java\%Practice.vim
$argadd sessions/\%home\%sh\%WorkSpace\%scaler\%WebDev\%protfolio.vim
$argadd sessions/\%home\%sh\%dotfiles\%awesome.vim
$argadd sessions/\%home\%sh\%dotfiles\%hypr.vim
$argadd sessions/\%home\%sh\%dotfiles\%nvim.vim
$argadd swaync/style.css
edit awesome/scripts/toggle_realmebuds_bind.sh
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
let s:l = 1 - ((0 * winheight(0) + 16) / 32)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 1
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
nohlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
