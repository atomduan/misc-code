#ifndef KIT_UNIT_CASE
#define KIT_UNIT_CASE

#define _FILE_OFFSET_BITS  64

#ifdef HAVE_LXC
#define _GNU_SOURCE
#include <sched.h>
#endif /* HAVE_LXC */

#include <assert.h>
#include <ctype.h>
#include <dirent.h>
#include <dlfcn.h>
#include <errno.h>
#include <error.h>
#include <fcntl.h>
#include <getopt.h>
#include <glob.h>
#include <grp.h>
#include <libgen.h>
#include <limits.h>
#include <linux/sched.h>
#include <math.h>
#include <pwd.h>
#include <signal.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/queue.h>
#include <sys/stat.h>
#include <sys/termios.h>
#include <sys/time.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

extern char **environ;

//struct foo_struct;
struct foo_struct {
    int bar;
};
typedef struct foo_struct fs;

//typedef struct foo_struct fs;
#endif/*KIT_UNIT_CASE*/
