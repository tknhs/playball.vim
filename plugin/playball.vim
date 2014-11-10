if &cp || (exists('g:loaded_playball') && g:loaded_playball)
  finish
endif
let g:loaded_playball = 1

let s:save_cpo = &cpo
set cpo&vim

if !has('python')
  finish
endif

if !exists('g:playball_enable') || g:playball_enable != 1
  finish
endif

if !exists('g:playball_team')
  finish
endif

command! -nargs=? Playball call playball#Playball(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
