#ifndef _CONFIG_H_INCLUDED_
#define _CONFIG_H_INCLUDED_

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#define _FILE_OFFSET_BITS  64

#include <unistd.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <math.h>
#include <errno.h>
#include <string.h>
#include <signal.h>
#include <pwd.h>
#include <grp.h>
#include <dirent.h>
#include <glob.h>
#include <fcntl.h>

#include <time.h>
#include <limits.h>
#include <stdbool.h>

/* use of dirname */
#include <libgen.h>
#include <dlfcn.h>

extern char **environ;
#endif /* _CONFIG_H_INCLUDED_ END */
