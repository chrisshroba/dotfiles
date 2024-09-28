
" ===== Vim Settings =====
"
" Line numbers on
set number

" Don't need vi compatibility
set nocompatible

" Syntax highlighting on
syntax on

" Leader should be <Space>
nnoremap <SPACE> <Nop>
let mapleader=" "

" Modelines are a security risk.
set modelines=0

" Show File stats
set ruler

" Blink cursor on error instead of beeping (grr)
set visualbell

" Encoding
set encoding=utf-8

" Automatically write when doing a bunch of things
set autowrite
set autowriteall

" TODO: comment this
set autoread

au FocusGained,BufEnter * :checktime

" Visually, wrap lines
set wrap

" Whitespace Settings:
" Wrap lines after 80 characters
set textwidth=80

" Formatting Options
" t: auto wrap text using textwidth
" c: Automatically add comment leader when wrapping
" q: Allow formatting of comments with "gq"
" r: Automatically add comment leader when hitting <enter> in Ins mode
" n: Auto-indent wrapped numbered list items to line up (sort of like this
"    description does)
" 1: Don't break a line after a one-letter word (break before instead)
set formatoptions=tcqrn1

" Visually, how wide a Tab character (\t) looks
set tabstop=2

" How many spaces to insert when using >> or << or vim auto indents something
set shiftwidth=2

" How many spaces to insert when you press <Tab>
set softtabstop=2

" Pressing <Tab> inserts spaces instead of tabs.
set expandtab

" Makes > and < commands round the indent level to a multiple of shiftwidth
set shiftround

" Keep same indent level when pressing <enter>
set autoindent

" C-style indenting
set cindent

" Try to be smart about indenting (TODO: how?)
set smartindent

" Try to be smart about tabbing (TODO: how?)
set smarttab


" Enable mouse interaction
set mouse=a



" Cursor Settings:
" Always show at least this many lines above and below cursor
set scrolloff=4

" Allow backspacing over auto-indentation, line breaks, and start of insert mode
set backspace=indent,eol,start

" Adding to pairs that % can jump between
set matchpairs+=<:>


" Makes vim's rendering faster (as long as you have a fast tty connection)
set ttyfast

" Show what mode we're in in the status bar (insert/visual/etc.)
set showmode

" Show current command in status bar
set showcmd

" Searching:
" Highlight current search matches
set hlsearch

" Search incrementally (as the query is input)
set incsearch

" Undo Settings:
" How much undo history to keep
set undolevels=1000

" Persist Undo history to file
set undofile

" Write undo files here instead of in same directory as file being edited.
set undodir=~/.vim/undodir

" Create that directory if it doesn't exist
silent !mkdir ~/.vim/undodir > /dev/null 2>&1


" Swap File Settings:
set backupdir=~/.vim/backup

" Create that directory if it doesn't exist
silent !mkdir ~/.vim/backup > /dev/null 2>&1



" Show matching left bracket character when typing right bracket (or vice versa)
set showmatch

" ===== End Vim Settings =====


" ===== Plugins =====
" Install vim-plug if not installed.
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC | q
endif

" TODO: Move this to a separate file


call plug#begin('~/.vim/plugged')

" File browser
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

" Make [- [= [+ work for jumping around indent levels
Plug 'jeetsukumaran/vim-indentwise'

" Fuzzy searching
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Commenting
Plug 'tpope/vim-commentary'
nmap <leader>c gcc<cr>
vmap <leader>c gc

" Allow fast 2-character searching with s<char><char> and ; to move to next
" result
" TODO: Figure out how I want to use this without taking away existing
" functionality of s
"Plug 'justinmk/vim-sneak'
"
Plug 'ctrlpvim/ctrlp.vim'

" TODO: get this to work properly.
" Plug 'psf/black', { 'branch': 'stable' }

Plug 'terryma/vim-smooth-scroll'
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>


Plug 'tmux-plugins/vim-tmux-focus-events'

Plug 'dense-analysis/ale'

Plug 'ayu-theme/ayu-vim'

Plug 'mzlogin/vim-markdown-toc'

Plug 'tpope/vim-eunuch'

Plug 'NoahTheDuke/vim-just'

call plug#end()

" Run PlugInstall if there are missing plugins
if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC | q
endif

" ===== End Plugins =====


" ===== Mappings =====
nnoremap <leader>pi :PlugInstall<cr>

nnoremap <cr> :silent nohlsearch<cr><cr>

" TODO:
" autocmd FileType vim nnoremap <leader>e
" autocmd FileType vim nnoremap <leader>E
" autocmd FileType vim vnoremap <leader>e
" autocmd FileType vim vnoremap <leader>e

nnoremap <C-l> :Lines<cr>

vnoremap > >gv
vnoremap < <gv

nnoremap ~ @q
" ===== End Mappings =====


" ===== Custom Functions and Behavior=====

" Automatically Enable Paste Mode When Pasting:
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <leader>t :wa<CR>:NERDTreeToggle<CR>
let g:NERDTreeQuitOnOpen = 1
let g:NERDTreeShowHidden=1
autocmd BufEnter NERD_tree_* map <buffer> <Esc> :NERDTreeToggle<CR>


silent !mkdir ~/.vim/swapfiles > /dev/null 2>&1
set directory=$HOME/.vim/swapfiles//

" ======
"

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['prettier', 'eslint'],
\   'typescript': ['prettier', 'eslint'],
\   'vue': ['prettier', 'eslint'],
\   'css': ['prettier'],
\   'json': ['jq'],
\   'python': ['black'],
\}
let g:ale_python_black_options = '--line-length=80'

let g:ale_linters = {'rust': ['analyzer']}


let g:ale_lint_on_enter = 1
let g:ale_lint_on_filetype_changed = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 1
let g:ale_lint_on_insert_leave = 1

let g:ale_fix_on_save = 1

let g:ale_history_log_output = 1

set termguicolors     " enable true colors support
" let ayucolor="light"  " for light version of theme
" let ayucolor="mirage" " for mirage version of theme
let ayucolor="dark"   " for dark version of theme
colorscheme ayu

set inex=substitute(v:fname,'^\\~','resources/assets/js','')

vnoremap p "_dP

command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>).' :!package-lock.json', 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

nnoremap <C-i> :GGrep<CR>
nnoremap diW diW"_x
nnoremap <leader>vimrc :e ~/.vimrc<CR>
