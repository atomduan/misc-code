#ifndef DJT_UTILITIES_DEBUG_H_
#define DJT_UTILITIES_DEBUG_H_

#include <stddef.h>

#include "utilities/breakpoint.h"
#include "utilities/compiler_warnings.h"
#include "utilities/macros.h"

#define ShouldNotCallThis()                                                       \
do {                                                                              \
  BREAKPOINT;                                                                     \
} while (0)

#define ShouldNotReachHere()                                                       \
do {                                                                              \
  BREAKPOINT;                                                                     \
} while (0)


// types of VM error - originally in vmError.hpp
enum VMErrorType {
  INTERNAL_ERROR   = 0xe0000000,
  OOM_MALLOC_ERROR = 0xe0000001,
  OOM_MMAP_ERROR   = 0xe0000002
};

void report_should_not_call(const char* file, int line);

#endif // DJT_UTILITIES_DEBUG_H_
