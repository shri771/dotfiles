let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/WorkSpace/Go/BlogAggregator
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
set shortmess+=aoO
badd +50 main.go
badd +24 ~/WorkSpace/Go/BlogAggregator/handler_agg.go
badd +74 ~/WorkSpace/Go/BlogAggregator/handler_user.go
badd +29 ~/WorkSpace/Go/BlogAggregator/handler_feed.go
badd +1 ~/WorkSpace/Go/BlogAggregator/internal/rssapi/rssFeed_types.go
badd +34 ~/WorkSpace/Go/BlogAggregator/internal/rssapi/rssfeed.go
badd +19 ~/WorkSpace/Go/BlogAggregator/internal/rssapi/client.go
badd +14 middleware.go
badd +889 /usr/lib/go/src/net/http/request.go
badd +48 ~/WorkSpace/Go/BlogAggregator/handler_follow.go
argglobal
%argdel
edit ~/WorkSpace/Go/BlogAggregator/internal/rssapi/rssfeed.go
argglobal
balt ~/WorkSpace/Go/BlogAggregator/handler_follow.go
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
let s:l = 26 - ((18 * winheight(0) + 16) / 32)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 26
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
