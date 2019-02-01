"echo 'atom-java.vim plugin logic loaded......'
let s:plugin_root_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')

python << EOF
import sys
from os.path import normpath,join
import vim
plugin_root_dir = vim.eval('s:plugin_root_dir')
python_root_dir = normpath(join(plugin_root_dir, '..', 'python'))
sys.path.insert(0, python_root_dir)
import plugin_entry
EOF

function! AtomFoo()
python << EOF
from plugin_entry import atom_foo
atom_foo()
EOF
endfunction
command! -nargs=0 AtomFoo call AtomFoo()
