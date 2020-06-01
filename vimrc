set nocompatible
syntax on
filetype on

colorscheme default
set syntax=on
set filetype=on
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
set incsearch
set ruler
set nofoldenable

"set foldmethod=syntax
"set cursorline

let mapleader=","

hi Search term=reverse ctermfg=Black guifg=Yellow
hi StatusLine term=reverse ctermbg=0 ctermfg=30

nnoremap <F4> :NERDTree<cr>
"<shift>+b open bookmark; <shift>+d remove bookmark; <leader>+b add bookemark
nnoremap <leader>b :Bookmark<cr>
nnoremap <leader>z :nohl<cr>
nnoremap <leader>x :NERDTreeFind<cr>*0n
nnoremap <leader>j 12j
nnoremap <leader>k 12k

"let NERDTreeShowHidden=1

let NERDTreeWinSize=28
let NERDTreeIgnore=['\.o$','\.bin$', '\.swp$', '\.pyc$', '\.jar$']
"let NERDTreeShowBookmarks=1

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
Plugin 'python.vim'
Plugin 'EasyGrep'
Plugin 'Markdown'
Plugin 'c.vim'
"Plugin 'atom-java.vim'

""Need more learning
"Plugin 'session.vim'
"Plugin 'vimwiki'
"Plugin 'FencView.vim'
"let g:fencview_autodetect = 1  
"let g:fencview_checklines = 10

let g:bufExplorerDefaultHelp=0       " Do not show default help.
let g:bufExplorerShowRelativePath=1  " Show relative paths.
let g:bufExplorerSortBy='mru'        " Sort by most recently used.
nnoremap <leader>m :BufExplorer<cr>

let g:ctrlp_dont_split = 'NERD'
let g:ctrlp_open_new_file = 'v'
let g:ctrlp_root_markers = ['pom.xml', 'Makefile', 'README', 'README.md']
let g:ctrlp_by_filename = 1
let g:ctrlp_working_path_mode = 'rw'
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/](\.(git|hg|svn)$|target$)',
            \ 'file': '\v\.(exe|so|dll|class|bin|jar|o)$',
            \ }
let g:ctrlp_follow_symlinks = 1

let EasyGrepRecursive = 1
let EasyGrepFilesToExclude = '*.class,target,*tar.gz,*.jar,*.war, .git/**.*,target/**.*'

let g:go_highlight_structs = 1 
let g:go_highlight_methods = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

nnoremap <F3> :ConqueTermVSplit bash<cr>
nnoremap * *N

"auto open nertree
autocmd VimEnter * NERDTree

nnoremap <leader>ev :vsplit ~/.vimrc<cr>
nnoremap <leader>cl :1,%s/\r//g<cr><c-o>
nnoremap <leader>cw "+yiw
nnoremap <leader>cy "+yy


"cscope config
if has("cscope")
	set csprg=/usr/local/bin/cscope
	set csto=0
	set cst
	set nocsverb
	" add any database in current directory
	if filereadable("cscope.out")
	    cs add cscope.out
	" else add database pointed to by environment
	elseif $CSCOPE_DB != ""
	    cs add $CSCOPE_DB
	endif
	set csverb
endif

"nnoremap <leader>fs :cs find s <C-R>=expand("<cword>")<CR><CR>
"nnoremap <leader>fg :cs find g <C-R>=expand("<cword>")<CR><CR>
"nnoremap <leader>fc :cs find c <C-R>=expand("<cword>")<CR><CR>
"nnoremap <leader>ft :cs find t <C-R>=expand("<cword>")<CR><CR>
"nnoremap <leader>fe :cs find e <C-R>=expand("<cword>")<CR><CR>
"nnoremap <leader>ff :cs find f <C-R>=expand("<cfile>")<CR><CR>
"nnoremap <leader>fi :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
"nnoremap <leader>fd :cs find d <C-R>=expand("<cword>")<CR><CR>
"nnoremap <leader>fa :cs find a <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>fs :vert scs find s <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>fg :vert scs find g <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>fc :vert scs find c <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>ft :vert scs find t <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>fe :vert scs find e <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>fi :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nnoremap <leader>fd :vert scs find d <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>fa :vert scs find a <C-R>=expand("<cword>")<CR><CR>

au BufRead,BufNewFile todo set filetype=todo
