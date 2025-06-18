".vimrc 

"disable modelines
set nomodeline

"set color scheme
set background=dark
colorscheme dim

"Use syntax highlighting
syntax on

"Show statusline
set laststatus=2

"Status line
set statusline=%#todo#%t    " todo highlighting, filename
set statusline+=%*[%{strlen(&fenc)?&fenc:'none'},    " standard highlighting, file encoding
set statusline+=%{&ff}]   " file format
set statusline+=%h    " help file flag
set statusline+=%m    " modified flag
set statusline+=%#error#%r    " error highlihgting, read only flag
set statusline+=%#todo#%y   " todo highlighting, filetype flag
set statusline+=%*%=    " standard highlighting, left/right separator
set statusline+=%{synIDattr(synID(line('.'),col('.'),1),'name')}\     " syntax detected item
set statusline+=%c,   " cursor column
set statusline+=%l/%L   " cursor line/total lines
set statusline+=\ %P    " percent through file

"Use line numbers
set number

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
