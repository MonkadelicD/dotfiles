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

"Enable autoindent
set autoindent

"2-space indentation for yaml files
"autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

"2-space indentation for all scripts/languages
set expandtab
set tabstop=2
set shiftwidth=2

"Indentation lines for tabs
set list lcs=tab:\⦙\ 

"IndentLine settings
let g:indentLine_char_list = ['⦙']

"Needed to prevent concealing quotes in json
let g:vim_json_conceal = 0
