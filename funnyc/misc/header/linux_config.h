#ifndef _LINUX_CONFIG_H_INCLUDED_
#define _LINUX_CONFIG_H_INCLUDED_

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#define _FILE_OFFSET_BITS  64

#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <errno.h>
#include <string.h>
#include <signal.h>
#include <pwd.h>
#include <grp.h>
#include <dirent.h>
#include <glob.h>
#include <sys/vfs.h>

#include <sys/uio.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <sys/wait.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <sched.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/un.h>

#include <time.h>
#include <malloc.h>
#include <limits.h>
#include <sys/ioctl.h>
#include <crypt.h>
#include <sys/utsname.h>
#include <stdbool.h>

#include <inttypes.h>

/* use of dirname */
#include <libgen.h>
#include <dlfcn.h>

extern char **environ;
#endif /* _LINUX_CONFIG_H_INCLUDED_ */
