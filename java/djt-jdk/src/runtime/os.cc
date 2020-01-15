#include "runtime/os.h"
#include "services/mem_tracker.h"

void* os::malloc(size_t size, MEMFLAGS memflags, const NativeCallStack& stack) {
  // Since os::malloc can be called when the libjvm.{dll,so} is
  // first loaded and we don't have a thread yet we must accept NULL also here.
  assert(!os::ThreadCrashProtection::is_crash_protected(Thread::current_or_null()),
         "malloc() not allowed when crash protection is set");

  if (size == 0) {
    // return a valid pointer if size is zero
    // if NULL is returned the calling functions assume out of memory.
    size = 1;
  }

  // NMT support
  NMT_TrackingLevel level = MemTracker::tracking_level();
  size_t            nmt_header_size = MemTracker::malloc_header_size(level);

  const size_t alloc_size = GuardedMemory::get_total_size(size + nmt_header_size);
  if (size + nmt_header_size > alloc_size) { // Check for rollover.
    return NULL;
  }

  // For the test flag -XX:MallocMaxTestWords
  if (has_reached_max_malloc_test_peak(size)) {
    return NULL;
  }

  u_char* ptr;
  ptr = (u_char*)::malloc(alloc_size);

  if (ptr == NULL) {
    return NULL;
  }
  // Wrap memory with guard
  GuardedMemory guarded(ptr, size + nmt_header_size);
  ptr = guarded.get_user_ptr();

  if ((intptr_t)ptr == (intptr_t)MallocCatchPtr) {
    log_warning(malloc, free)("os::malloc caught, " SIZE_FORMAT " bytes --> " PTR_FORMAT, size, p2i(ptr));
    breakpoint();
  }
  if (paranoid) {
    verify_memory(ptr);
  }

  // we do not track guard memory
  return MemTracker::record_malloc((address)ptr, size, memflags, stack, level);
}

// handles NULL pointers
void os::free(void *memblock) {
  if (memblock == NULL) return;
  if ((intptr_t)memblock == (intptr_t)MallocCatchPtr) {
    log_warning(malloc, free)("os::free caught " PTR_FORMAT, p2i(memblock));
    breakpoint();
  }
  void* membase = MemTracker::record_free(memblock, MemTracker::tracking_level());
  verify_memory(membase);

  GuardedMemory guarded(membase);
  size_t size = guarded.get_user_size();
  inc_stat_counter(&free_bytes, size);
  membase = guarded.release_for_freeing();
  ::free(membase);
}
