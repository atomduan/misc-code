#!/bin/bash -
#first we need to install: autoconf and automake
curr_path=$(cd `dirname $(which $0)`; pwd)

program_name="$1"
shift
version="$1"
shift

if [ "x${program_name}" = "x" ]; then
	cat << EOF

usage: $( basename $0 ) program_name [version]

EOF
	exit 1
fi

folder_name="${program_name}${version:+-$version}"

if [ -d "$folder_name" ]; then
	echo "ERROR: the folde [$folder_name] already exsited"
	exit 1
fi

mkdir -p $folder_name

if [ -d "$folder_name" ]; then
	cd $folder_name
	mkdir m4
	mkdir src
	mkdir config
	mkdir build

	touch AUTHORS
	touch COPYING
	touch ChangeLog
	touch NEWS
	touch README

	cat > Makefile.am << EOF
ACLOCAL_AMFLAGS = -I m4
SUBDIRS = src
EXTRA_DIST = autogen.sh
EOF
	cat > src/${program_name}.c << EOF
/*
 * =====================================================================================
 *
 *       Filename:  ${program_name}.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  $( date +'%Y-%m-%d %H:%M:%S' )
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  $(who am i) 
 *   Organization:  
 *
 * =====================================================================================
 */
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv) 
{
	printf("hello ${program_name}\n");
	return 0;
}

EOF

	cat > src/Makefile.am << EOF
bin_PROGRAMS = ${program_name}
${program_name}_SOURCES = ${program_name}.c
EOF

	cat > autogen.sh << EOF
#!/bin/sh
autoreconf --verbose --no-recursive --force --install -I config -I m4
EOF
	chmod 755 autogen.sh

	cat > configure.ac << EOF
#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([FULL-PACKAGE-NAME], [VERSION], [BUG-REPORT-ADDRESS])
AC_CONFIG_SRCDIR([src/${program_name}.c])
AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE

# Checks for programs.
AC_PROG_CC
AC_PROG_INSTALL

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([stdlib.h])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile
                 src/Makefile])
AC_OUTPUT
EOF

fi
