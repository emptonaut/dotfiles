syntax on
filetype off

" Non-vundle related config

set nocompatible
set number                      "Line numbers are good
set title                       "Titles are cool
set hidden                      "Hide buffer instead of closing it - stop buffering of empty files
set pastetoggle=<F2>            "Paste without being smart
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=1000                "Store lots of :cmdline history
set showcmd                     "Show incomplete cmds down the bottom
set visualbell                  "No sounds
set noerrorbells                "Removes error bells
set autoread                    "Reload files changed outside vim
set autoindent                  "Auto indentation
set smartindent                 "Smart indentation
set smartcase                   "Smart casing
set smarttab                    "Smart tab
set hlsearch                    "Highlights search results
set incsearch                   "Includes partial searches
set showmatch                   "Shows matching braces
set ignorecase                  "Ignores case in searches
set shiftround                  "Move word to word with shift navigation
set history=1000                "Command history
set undolevels=1000             "Undo history
set udf                         "Persistant undo across sessions
set scrolloff=4                 "Makes cursor stay 8 lines away from the top or bottom

" Tabs to spaces
set tabstop=4 shiftwidth=4 expandtab

nnoremap <Leader>rtw :%s/\s\+$//e<CR>

""""""""""""""""""""""""""""""""""""""""""""""""" HIGHLIGHTING

" match ErrorMsg '\s\+$'

" Matching parentheses
hi MatchParen cterm=bold ctermbg=none ctermfg=34
" Colored line numbers are better
"hi LineNr cterm=none ctermfg=green ctermfg=blue

" Trigger a highlight in the appropriate direction when pressing these keys:
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

function! s:SetHighlightings()
    hi Pmenu           guifg=#66D9EF guibg=#000000
    hi PmenuSel                      guibg=#808080
    hi PmenuSbar                     guibg=#080808
    hi PmenuThumb      guifg=#66D9EF
endfunction

call s:SetHighlightings()

""""""""""""""""""""""""""""""""""""""""""""""""" COLORS
autocmd ColorScheme * call <SID>SetHighlightings()

highlight ColorColumn ctermbg=235 guibg=#2c2d27
let &colorcolumn=join(range(81,999),",")

" colors
"let g:rehash256 = 1
if filereadable(expand("~/.config/nvim/colors/molokia.config/nvim"))
    source ~/.config/nvim/colors/molokia.config/nvim
    set t_ut=
endif

" lightline
set laststatus=2 " no display fix
set noshowmode

" Setting up pretty status bar
let g:lightline = {
    \ 'colorscheme': 'powerline',
	\ 'component': {
    \   'readonly': '%{&readonly?"":""}',
    \ },
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': '', 'right': '' }
  \ }

""""""""""""""""""""""""""""""""""""""""""""""""" OTHER

" netrw
let g:netrw_liststyle=3         "List styles for file explorer
let g:netrw_altv=1
let g:netrw_preview=1
let g:netrw_sort_sequence='[\/]$,*' " sort is affecting only: directories on the top, files below
let g:netrw_list_hide='.*\.swp$'
let g:netrw_use_noswf=0

" nerdtree
let NERDTreeShowHidden=1
let NERDTreeSortOrder=['[\/]$', '*']
let NERDTreeIgnore=['.*\.swp$', '.*\.swo$',]

let asmsyntax='armasm'
let filetype_inc='armasm'

" Key mappings
let mapleader = "\<Space>"
let maplocalleader = "\\"
nnoremap <leader>c :noh<cr>         " Clear search highlighting with <space>c
nnoremap <tab> :bnext<cr>           " Tab to next buffer
nnoremap <s-tab> :bprevious<cr>     " Shift-tab to previous buffer
noremap <Leader><tab> :NERDTreeTabsToggle<CR>
noremap <Leader>` :call VexToggle("")<CR>
noremap <Leader>i :exe "normal i".nr2char(getchar())<CR>
nnoremap <Leader>s :%s/\<<C-r><C-w>\>/

map j gj
map k gk


let g:python2_host_prog = '%python-path%'

" Load plugins
if filereadable(expand("~/.config/nvim/vundle.vim"))
  source ~/.config/nvim/vundle.vim
endif

" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<C-j>"
let g:UltiSnipsJumpForwardTrigger = "<C-j>"
let g:UltiSnipsJumpBackwardTrigger = "<C-k>"

" vim-jsx settings
let g:jsx_ext_required = 0

" Undo
if has('persistent_undo')
  silent !mkdir ~/.config/nvim/undo > /dev/null 2>&1
  set undodir=~/.config/nvim/undo
  set undofile
endif

if !has('gui_running') " no color fix
    set t_Co=256

    " Odd `esc` lag fix
    set ttimeoutlen=10
    set nottimeout
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=0
        au InsertLeave * set timeoutlen=1000
    augroup END
endif


"" use the previous window to

set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*DS_Store*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**

set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg,*.svg
set wildignore+=*.swp,*.pyc,*.bak,*.class,*.orig
set wildignore+=.git,.hg,.bzr,.svn
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows

let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = {
 \ 'dir':  '\v[\/]\.(git|hg|svn)$',
 \ 'file': '\v\.(exe|so|dll)$',
 \ 'link': 'some_bad_symbolic_links',
 \ }

augroup makefile
     autocmd!
     autocmd FileType make setlocal noexpandtab
augroup END

" Spell check
augroup spell_check
	autocmd!
	autocmd FileType no ft setlocal spell spelllang-en_us
augroup END

autocmd BufRead,BufNewFile *.md setlocal spell spelllang=en_us
