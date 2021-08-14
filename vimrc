syntax enable
filetype plugin indent on
set ttymouse=xterm2
set expandtab
set shiftwidth=2
set softtabstop=2
set clipboard+=autoselect
set guioptions+=a
set autoindent
set backspace=indent,eol,start
set incsearch
set hlsearch
set ru
set sc

" Set the terminal's title
set title

" Global tab width.
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" Set to show invisibles (tabs & trailing spaces) & their highlight color
set list listchars=tab:»\ ,trail:·

" Strip whitespace on save
fun! <SID>StripTrailingWhitespaces()
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  %s/\s\+$//e
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfun

command -nargs=0 Stripwhitespace :call <SID>StripTrailingWhitespaces()

" Default to magic mode when using substitution
cnoremap %s/ %s/\v
cnoremap \>s/ \>s/\v

" Unsmart Quotes
nnoremap guq :%s/\v[“”]/"/g<cr>

if has("autocmd")
  " StripTrailingWhitespaces
  autocmd BufWritePre * Stripwhitespace
  " Set filetype tab settings
  autocmd FileType python,doctest set ai ts=4 sw=4 sts=4 et
endif
