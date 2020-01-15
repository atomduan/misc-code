#ifndef DJT_SERVICES_MEMTRACKER_H_
#define DJT_SERVICES_MEMTRACKER_H_

#include "services/nmt_common.h"
#include "utilities/native_call_stack.h"

class MemTracker : AllStatic {
 public:
  static inline void* record_free(void* memblock, NMT_TrackingLevel level) { return memblock; }
  static inline void* record_malloc(void* mem_base, 
                                    size_t size, 
                                    MEMFLAGS flag,
                                    const NativeCallStack& stack, 
                                    NMT_TrackingLevel level) { return mem_base; }
};
#endif // DJT_SERVICES_MEMTRACKER_H_
