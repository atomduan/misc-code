set nocompatible

syntax enable
filetype plugin indent on

colorscheme peachpuff
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
set scrolloff=8
set incsearch
set ruler
set nofoldenable
set clipboard=unnamedplus

"set foldmethod=syntax
"set cursorline

let mapleader=","

hi Search term=reverse ctermfg=Black guifg=Yellow
hi StatusLine term=reverse ctermbg=0 ctermfg=30
hi Visual term=reverse ctermbg=0

nnoremap <F4> :NERDTree<cr>

""
""<shift>+b --> open bookmark
""<shift>+d --> remove bookmark
""add bookmark:
nnoremap <leader>b :Bookmark<cr>

nnoremap <leader>z :nohl<cr>
nnoremap <leader>x :NERDTreeFind<cr>*0n
nnoremap <leader>j 16j
nnoremap <leader>k 16k

vnoremap <leader>j 16j
vnoremap <leader>k 16k

let NERDTreeWinSize=28
let NERDTreeIgnore=['\.o$','\.bin$', '\.swp$', '\.pyc$', '\.jar$']
"let NERDTreeShowHidden=1
"let NERDTreeShowBookmarks=1

filetype plugin indent on

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()

Plugin 'VundleVim/Vundle.vim'
Plugin 'The-NERD-tree'
Plugin 'ctrlp.vim'
Plugin 'lrvick/Conque-Shell'
Plugin 'bufexplorer.zip'
Plugin 'python.vim'
Plugin 'c.vim'
Plugin 'FencView.vim'
Plugin 'rust-lang/rust.vim'
"Plugin 'zelda.vim'
Plugin 'arrufat/vala.vim'

let g:fencview_autodetect = 1  
let g:fencview_checklines = 10

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
let g:ctrlp_switch_buffer = 'Et'

nnoremap <F3> :ConqueTermVSplit bash<cr>
nnoremap * *N

"auto open nertree
autocmd VimEnter * NERDTree

"print register
nnoremap <leader>p0 "0P
nnoremap <leader>p1 "1P
nnoremap <leader>p2 "2P
nnoremap <leader>p3 "3P
nnoremap <leader>p4 "4P
nnoremap <leader>p5 "5P

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

nnoremap <leader>fi :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nnoremap <leader>fs :vert scs find s <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>fg :vert scs find g <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>fc :vert scs find c <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>ft :vert scs find t <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>fe :vert scs find e <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>fd :vert scs find d <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>fa :vert scs find a <C-R>=expand("<cword>")<CR><CR>

au BufRead,BufNewFile todo set filetype=todo

if executable("/usr/local/bin/rg")
    set grepprg=/usr/local/bin/rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

nnoremap <leader>ev :vsplit ~/.vimrc<cr>
nnoremap <leader>cl :1,%s/\r//g<cr><c-o>

" for mac os clipboard support
" nnoremap <leader>cw "+yiw
" nnoremap <leader>cy "+yy

" for linux clipboard support
" 1. sudo apt-get install xsel
" 2. define functions below
" 3. nnoremapping shortcut to function
" 4. set clipboard=unnamedplus
function! CopyWord()
  normal "+yiw
  :call system('xsel -ib', getreg('+'))
endfunction
function! CopyLine()
  normal "+yy
  :call system('xsel -ib', getreg('+'))
endfunction
nnoremap <leader>cw :call CopyWord()<cr>
nnoremap <leader>cy :call CopyLine()<cr>
