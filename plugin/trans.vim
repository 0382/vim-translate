" 提供一个命令，翻译用命令 `:Trans hello world`
command! -nargs=+ Trans call trans#Mytranslate(<q-args>)
