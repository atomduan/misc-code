"set nocompatible "what does this really mean?

colorscheme default
set syntax=on
set filetype=go
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
map ,z Pu
map ,x :NERDTreeFind<cr>*
map ,c :nohl<cr>

let NERDTreeWinSize=32
let NERDTreeIgnore=['\.o$','\.bin$', '\.pyc$']

filetype plugin indent on

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()

Plugin 'VundleVim/Vundle.vim'
Plugin 'matrix.vim--Yang'
Plugin 'bufexplorer.zip'
Plugin 'The-NERD-tree'
Plugin 'lrvick/Conque-Shell'
Plugin 'snipMate'
Plugin 'ctrlp.vim'
Plugin 'EasyGrep'
Plugin 'Markdown'
Plugin 'c.vim'
Plugin 'fatih/vim-go'

""Need more learning
"Plugin 'vimwiki'
"Plugin 'FencView.vim'
"let g:fencview_autodetect = 1  
"let g:fencview_checklines = 10

let g:ctrlp_dont_split = 'NERD'
let g:ctrlp_open_new_file = 'v'
let g:ctrlp_root_markers = ['pom.xml', 'Makefile', 'README', 'README.md']
let g:ctrlp_by_filename = 1
let g:ctrlp_working_path_mode = 'rw'
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/](\.(git|hg|svn)$|target$)',
            \ 'file': '\v\.(exe|so|dll|class|o)$',
            \ }
let g:ctrlp_follow_symlinks = 1

let EasyGrepRecursive = 1
let EasyGrepFilesToExclude = '*.class,target,*tar.gz,*.jar,*.war, .git/**.*,target/**.*'

let g:go_highlight_structs = 1 
let g:go_highlight_methods = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

map <F3> :ConqueTermTab bash<cr>

"auto open nertree
au VimEnter * NERDTree
