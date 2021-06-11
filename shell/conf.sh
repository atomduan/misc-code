sudo apt install \
    libncurses5-dev libgnome2-dev libgnomeui-dev \
    libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
    libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
    python3.7-dev ruby-dev lua5.1 liblua5.1-dev libperl-dev git

cd $vim_src_dir

./configure --with-features=huge \
            --enable-multibyte \
	        --enable-rubyinterp=yes \
	        --enable-pythoninterp=yes \
	        --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
	        --enable-python3interp=yes \
	        --with-python3-config-dir=/usr/lib/python3.7/config-3.7m-x86_64-linux-gnu \
	        --enable-perlinterp=yes \
	        --enable-luainterp=yes \
            --enable-gui=gtk2 \
            --enable-cscope \
	        --prefix=/home/mi/Binary/opt
