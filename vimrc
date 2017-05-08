colorscheme default
set copyindent
set preserveindent
set softtabstop=0
set shiftwidth=4
set smartcase
set tabstop=4
set expandtab
set autoindent
set hlsearch
set encoding=utf-8
set nu 
set nowrap
set scrolloff=6


highlight Search term=reverse ctermfg=Black guifg=Yellow

map <F4> :NERDTree<cr>
map ,c :nohl<cr>

let NERDTreeWinSize=30
let NERDTreeIgnore=['\.o$','\.bin$']

filetype plugin indent on

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()

Plugin 'VundleVim/Vundle.vim'
Plugin 'taglist.vim'
Plugin 'SuperTab'
Plugin 'vimwiki'
Plugin 'winmanager'
Plugin 'bufexplorer.zip'
Plugin 'The-NERD-tree'
Plugin 'matrix.vim--Yang'
Plugin 'FencView.vim'
Plugin 'lrvick/Conque-Shell'
Plugin 'Markdown'
Plugin 'LaTeX-Suite-aka-Vim-LaTeX'
Plugin 'c.vim'
Plugin 'snipMate'
Plugin 'ctrlp.vim'
Plugin 'EasyGrep'

let g:ctrlp_open_new_file = 'v'
let g:ctrlp_root_markers = ['pom.xml', 'Makefile', 'README', 'README.md']
let g:ctrlp_by_filename = 1
let g:ctrlp_working_path_mode = 'rw'

map <F3> :ConqueTermTab bash<cr>

"auto open nertree
au VimEnter * NERDTree
