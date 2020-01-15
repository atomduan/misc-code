#ifndef DJT_UTILITIES_GLOBALD_EFINITIONS_X86_H_
#define DJT_UTILITIES_GLOBALD_EFINITIONS_X86_H_

const int StackAlignmentInBytes  = 16;

// Indicates whether the C calling conventions require that
// 32-bit integer argument values are extended to 64 bits.
const bool CCallingConventionRequiresIntsAsLongs = false;

#define SUPPORTS_NATIVE_CX8

#define CPU_MULTI_COPY_ATOMIC

// The expected size in bytes of a cache line, used to pad data structures.
#if defined(TIERED)
  #ifdef _LP64
    // tiered, 64-bit, large machine
    #define DEFAULT_CACHE_LINE_SIZE 128
  #else
    // tiered, 32-bit, medium machine
    #define DEFAULT_CACHE_LINE_SIZE 64
  #endif
#elif defined(COMPILER1)
  // pure C1, 32-bit, small machine
  // i486 was the last Intel chip with 16-byte cache line size
  #define DEFAULT_CACHE_LINE_SIZE 32
#elif defined(COMPILER2)
  #ifdef _LP64
    // pure C2, 64-bit, large machine
    #define DEFAULT_CACHE_LINE_SIZE 128
  #else
    // pure C2, 32-bit, medium machine
    #define DEFAULT_CACHE_LINE_SIZE 64
  #endif
#endif

#if defined(COMPILER2)
// Include Restricted Transactional Memory lock eliding optimization
#define INCLUDE_RTM_OPT 1
#endif

#if defined(LINUX) || defined(SOLARIS) || defined(__APPLE__)
#define SUPPORT_RESERVED_STACK_AREA
#endif

#define THREAD_LOCAL_POLL

#endif // DJT_UTILITIES_GLOBALD_EFINITIONS_X86_H_
