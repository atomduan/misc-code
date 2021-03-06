#ifndef DJT_RUNTIME_OS_H_
#define DJT_RUNTIME_OS_H_

#include "memory/allocation.h"
#include "utilities/native_call_stack.h"

// Platform-independent error return values from OS functions
enum OSReturn {
    OS_OK         =  0,        // Operation was successful
    OS_ERR        = -1,        // Operation failed
    OS_INTRPT     = -2,        // Operation was interrupted
    OS_TIMEOUT    = -3,        // Operation timed out
    OS_NOMEM      = -5,        // Operation failed for lack of memory
    OS_NORESOURCE = -6         // Operation failed for lack of nonmemory resource
};

enum ThreadPriority {        // JLS 20.20.1-3
    NoPriority       = -1,     // Initial non-priority value
    MinPriority      =  1,     // Minimum priority
    NormPriority     =  5,     // Normal (non-daemon) priority
    NearMaxPriority  =  9,     // High priority, used for VMThread
    MaxPriority      = 10,     // Highest priority, used for WatcherThread
                               // ensures that VMThread doesn't starve profiler
    CriticalPriority = 11      // Critical thread priority
};

class os: public AllStatic {
    public:
        // Size of _page_sizes array (8 plus a sentinel)
        enum {
            page_sizes_max = 9
        };
        // General allocation (must be MT-safe)
        static void* malloc(size_t size,
                            MEMFLAGS flags,
                            const NativeCallStack& stack);
        static void free(void *memblock);

        static jlong elapsed_counter();
        static jlong javaTimeNanos();
        static jlong elapsed_frequency();
};
#endif // DJT_RUNTIME_OS_H_
