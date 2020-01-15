#ifndef DJT_UTILITIES_COMPILER_WARNINGS_H
#define DJT_UTILITIES_COMPILER_WARNINGS_H

#include "utilities/macros.h"


// Macros related to control of compiler warnings.
// Diagnostic pragmas like the ones defined below in PRAGMA_FORMAT_NONLITERAL_IGNORED
// were only introduced in GCC 4.2. Because we have no other possibility to ignore
// these warnings for older versions of GCC, we simply don't decorate our printf-style
// functions with __attribute__(format) in that case.
#if ((__GNUC__ == 4) && (__GNUC_MINOR__ >= 2)) || (__GNUC__ > 4)
#ifndef ATTRIBUTE_PRINTF
#define ATTRIBUTE_PRINTF(fmt,vargs)  __attribute__((format(printf, fmt, vargs)))
#endif
#ifndef ATTRIBUTE_SCANF
#define ATTRIBUTE_SCANF(fmt,vargs)  __attribute__((format(scanf, fmt, vargs)))
#endif
#endif // gcc version check


#define PRAGMA_DISABLE_GCC_WARNING_AUX(x) _Pragma(#x)
#define PRAGMA_DISABLE_GCC_WARNING(option_string) \
  PRAGMA_DISABLE_GCC_WARNING_AUX(GCC diagnostic ignored option_string)


#define PRAGMA_FORMAT_NONLITERAL_IGNORED                \
  PRAGMA_DISABLE_GCC_WARNING("-Wformat-nonliteral")     \
  PRAGMA_DISABLE_GCC_WARNING("-Wformat-security")


#define PRAGMA_FORMAT_IGNORED PRAGMA_DISABLE_GCC_WARNING("-Wformat")


// Disable -Wstringop-truncation which is introduced in GCC 8.
// https://gcc.gnu.org/gcc-8/changes.html
#if !defined(__clang_major__) && (__GNUC__ >= 8)
#define PRAGMA_STRINGOP_TRUNCATION_IGNORED PRAGMA_DISABLE_GCC_WARNING("-Wstringop-truncation")
#endif


#if defined(__clang_major__) && \
      (__clang_major__ >= 4 || \
      (__clang_major__ >= 3 && __clang_minor__ >= 1)) || \
    ((__GNUC__ == 4) && (__GNUC_MINOR__ >= 6)) || (__GNUC__ > 4)
// Tested to work with clang version 3.1 and better.
#define PRAGMA_DIAG_PUSH             _Pragma("GCC diagnostic push")
#define PRAGMA_DIAG_POP              _Pragma("GCC diagnostic pop")
#endif // clang/gcc version check


#ifndef PRAGMA_DIAG_PUSH
#define PRAGMA_DIAG_PUSH
#endif


#ifndef PRAGMA_DIAG_POP
#define PRAGMA_DIAG_POP
#endif


#ifndef PRAGMA_DISABLE_GCC_WARNING
#define PRAGMA_DISABLE_GCC_WARNING(name)
#endif


#ifndef PRAGMA_DISABLE_MSVC_WARNING
#define PRAGMA_DISABLE_MSVC_WARNING(num)
#endif


#ifndef ATTRIBUTE_PRINTF
#define ATTRIBUTE_PRINTF(fmt, vargs)
#endif


#ifndef ATTRIBUTE_SCANF
#define ATTRIBUTE_SCANF(fmt, vargs)
#endif


#ifndef PRAGMA_FORMAT_NONLITERAL_IGNORED
#define PRAGMA_FORMAT_NONLITERAL_IGNORED
#endif


#ifndef PRAGMA_FORMAT_IGNORED
#define PRAGMA_FORMAT_IGNORED
#endif


#ifndef PRAGMA_STRINGOP_TRUNCATION_IGNORED
#define PRAGMA_STRINGOP_TRUNCATION_IGNORED
#endif

#endif // DJT_UTILITIES_COMPILER_WARNINGS_H
