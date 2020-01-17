#include "runtime/os.h"
#include "services/mem_tracker.h"


jlong os::elapsed_counter() {
    return javaTimeNanos() - 0;
}

jlong os::javaTimeNanos() {
    timeval time;
    gettimeofday(&time, NULL);
    jlong usecs = jlong(time.tv_sec) * (1000 * 1000) + jlong(time.tv_usec);
    return 1000 * usecs;
}

void* os::malloc(size_t size, MEMFLAGS memflags, const NativeCallStack& stack) {
    UNUSED(memflags);
    UNUSED(stack);
    if (size == 0) {
        // return a valid pointer if size is zero
        // if NULL is returned the calling functions assume out of memory.
        size = 1;
    }
    u_char* ptr;
    ptr = (u_char*)::malloc(size);
    if (ptr == NULL) {
        return NULL;
    }
    return (address)ptr;
}

// handles NULL pointers
void os::free(void *memblock) {
    if (memblock == NULL) return;
    ::free(memblock);
}
