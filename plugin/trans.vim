" Author: 0382 <jshl0382@gmail.com>
" Github: https://github.com/0382
" Description: 有道翻译插件

if exists("g:loaded_trans")
    finish
endif
let g:loaded_trans = 1

if !has("python3")
    echoerr "vim-translate needs python3 support"
    finish
endif

function! s:optionset(argument, default) abort
    if !has_key(g:, a:argument)
        let g:{a:argument} = a:default
    endif
endfunction

let s:show_pronunciation = 1
let s:show_addition = 1

call s:optionset('translate_show_pronunciation', s:show_pronunciation)
call s:optionset('translate_show_addition', s:show_addition)

let s:settings = {}
let s:settings['show_pronunciation'] = g:translate_show_pronunciation
let s:settings['show_addition'] = g:translate_show_addition

" 提供一个命令`Trans`，例如`:Trans hello world`
if !exists(':Trans')
    command! -nargs=+ Trans call trans#Mytranslate(<q-args>, s:settings)
endif
