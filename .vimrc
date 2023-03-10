".vimrc 

"set color scheme
colorscheme default

"Use syntax highlighting
syntax on

"Use line numbers
"set number

"Blink cursor on error instead of sound
set visualbell

"Show file stats
set ruler

"2-space indentation for yaml files
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

"Indentation lines for tabs
set list lcs=tab:\⦙\ 

"IndentLine settings
let g:indentLine_char_list = ['⦙']

"Needed to prevent concealing quotes in json
let g:vim_json_conceal = 0
