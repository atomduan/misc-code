#ifndef DJT_ALLOCATION_H_
#define DJT_ALLOCATION_H_

#include <new>

#include "utilities/macros.h"
#include "utilities/global_definitions.h"
#include "utilities/debug.h"


class AllocFailStrategy {
 public:
  enum AllocFailEnum {
      EXIT_OOM,
      RETURN_NULL
  };
};
typedef AllocFailStrategy::AllocFailEnum AllocFailType;


#define MEMORY_TYPES_DO(f) \
  /* Memory type by sub systems. It occupies lower byte. */  \
  f(mtJavaHeap,      "Java Heap")   /* Java heap                                 */ \
  f(mtClass,         "Class")       /* Java classes                              */ \
  f(mtThread,        "Thread")      /* thread objects                            */ \
  f(mtThreadStack,   "Thread Stack")                                                \
  f(mtCode,          "Code")        /* generated code                            */ \
  f(mtGC,            "GC")                                                          \
  f(mtCompiler,      "Compiler")                                                    \
  f(mtJVMCI,         "JVMCI")                                                       \
  f(mtInternal,      "Internal")    /* memory used by VM, but does not belong to */ \
                                    /* any of above categories, and not used by  */ \
                                    /* NMT                                       */ \
  f(mtOther,         "Other")       /* memory not used by VM                     */ \
  f(mtSymbol,        "Symbol")                                                      \
  f(mtNMT,           "Native Memory Tracking")  /* memory used by NMT            */ \
  f(mtClassShared,   "Shared class space")      /* class data sharing            */ \
  f(mtChunk,         "Arena Chunk") /* chunk that holds content of arenas        */ \
  f(mtTest,          "Test")        /* Test type for verifying NMT               */ \
  f(mtTracing,       "Tracing")                                                     \
  f(mtLogging,       "Logging")                                                     \
  f(mtStatistics,    "Statistics")                                                  \
  f(mtArguments,     "Arguments")                                                   \
  f(mtModule,        "Module")                                                      \
  f(mtSafepoint,     "Safepoint")                                                   \
  f(mtSynchronizer,  "Synchronization")                                             \
  f(mtNone,          "Unknown")                                                     \
  //end
#define MEMORY_TYPE_DECLARE_ENUM(type, human_readable) type,
/*
 * Memory types
 */
enum MemoryType {
  MEMORY_TYPES_DO(MEMORY_TYPE_DECLARE_ENUM)
  mt_number_of_types   // number of memory types (mtDontTrack
                       // is not included as validate type)
};
typedef MemoryType MEMFLAGS;


char* allocateHeap(size_t size,
                   MEMFLAGS flags,
                   AllocFailType alloc_failmode = AllocFailStrategy::EXIT_OOM);


// handles NULL pointers
void freeHeap(void* p);

template <MEMFLAGS F> class CHeapObj {
 public:
  void* operator new(size_t size) throw() {
    return (void*)allocateHeap(size, F);
  }
  void* operator new(size_t size, const std::nothrow_t&) throw() {
    return (void*)allocateHeap(size, F, AllocFailStrategy::RETURN_NULL);
  }
  void* operator new[](size_t size) throw() {
    return (void*)allocateHeap(size, F);
  }
  void* operator new[](size_t size, const std::nothrow_t&) throw() {
    return (void*)allocateHeap(size, F, AllocFailStrategy::RETURN_NULL);
  }
  void  operator delete(void* p)     { freeHeap(p); }
  void  operator delete [] (void* p) { freeHeap(p); }
};


// Base class for objects allocated on the stack only.
// Calling new or delete will result in fatal error.
class StackObj {
 private:
  void* operator new(size_t size) throw();
  void* operator new [](size_t size) throw();
  void  operator delete(void* p);
  void  operator delete [](void* p);
};


// Base class for classes that constitute name spaces.
class AllStatic {
 public:
  AllStatic()   { ShouldNotCallThis(); }
  ~AllStatic()  { ShouldNotCallThis(); }
};


//----------------------------------------------------------------------
// Base class for objects allocated in the resource area per default.
// Optionally, objects may be allocated on the C heap with
// new(ResourceObj::C_HEAP) Foo(...) or in an Arena with new (&arena)
// ResourceObj's can be allocated within other objects, but don't use
// new or delete (allocation_type is unknown).  If new is used to allocate,
// use delete to deallocate.
class ResourceObj {
 public:
  enum allocation_type {
      STACK_OR_EMBEDDED = 0,
      RESOURCE_AREA,
      C_HEAP,
      ARENA,
      allocation_mask = 0x3
  };

  allocation_type get_allocation_type() const;
  bool allocated_on_stack()    const { return get_allocation_type() == STACK_OR_EMBEDDED; }
  bool allocated_on_res_area() const { return get_allocation_type() == RESOURCE_AREA; }
  bool allocated_on_C_heap()   const { return get_allocation_type() == C_HEAP; }
  bool allocated_on_arena()    const { return get_allocation_type() == ARENA; }

  void* operator new(size_t size, allocation_type type, MEMFLAGS flags) throw();
  void* operator new(size_t size, const std::nothrow_t&  nothrow_constant,
      allocation_type type, MEMFLAGS flags) throw();
  void  operator delete(void* p);
  void  operator delete [](void* p);

 protected:
  ResourceObj(); // default constructor
  ResourceObj(const ResourceObj& r); // default copy constructor
  ResourceObj& operator=(const ResourceObj& r); // default copy assignment
  ~ResourceObj();

 private:
  // When this object is allocated on stack the new() operator is not
  // called but garbage on stack may look like a valid allocation_type.
  // Store negated 'this' pointer when new() is called to distinguish cases.
  // Use second array's element for verification value to distinguish garbage.
  uintptr_t _allocation_t[2];
  bool is_type_set() const;
  void initialize_allocation_info();
  void set_allocation_type(address res, allocation_type type);
};


//------------------------------ReallocMark---------------------------------
// Code which uses REALLOC_RESOURCE_ARRAY should check an associated
// ReallocMark, which is declared in the same scope as the reallocated
// pointer.  Any operation that could __potentially__ cause a reallocation
// should check the ReallocMark.
class ReallocMark: public StackObj {
 public:
  ReallocMark()   {};
  void check()    {};
};


// Helper class to allocate arrays that may become large.
// Uses the OS malloc for allocations smaller than ArrayAllocatorMallocLimit
// and uses mapped memory for larger allocations.
// Most OS mallocs do something similar but Solaris malloc does not revert
// to mapped memory for large allocations. By default ArrayAllocatorMallocLimit
// is set so that we always use malloc except for Solaris where we set the
// limit to get mapped memory.
template <class E> class ArrayAllocator : public AllStatic {
 public:
  static E* allocate(size_t length, MEMFLAGS flags);
  static E* reallocate(E* old_addr, size_t old_length, size_t new_length, MEMFLAGS flags);
  static void free(E* addr, size_t length);
 private:
  static bool should_use_malloc(size_t length);
  static E* allocate_malloc(size_t length, MEMFLAGS flags);
  static E* allocate_mmap(size_t length, MEMFLAGS flags);
  static void free_malloc(E* addr, size_t length);
  static void free_mmap(E* addr, size_t length);
};


// Uses mmaped memory for all allocations. All allocations are initially
// zero-filled. No pre-touching.
template <class E> class MmapArrayAllocator : public AllStatic {
 public:
  static E* allocate_or_null(size_t length, MEMFLAGS flags);
  static E* allocate(size_t length, MEMFLAGS flags);
  static void free(E* addr, size_t length);
 private:
  static size_t size_for(size_t length);
};


// Uses malloc:ed memory for all allocations.
template <class E> class MallocArrayAllocator : public AllStatic {
 public:
  static size_t size_for(size_t length);
  static E* allocate(size_t length, MEMFLAGS flags);
  static void free(E* addr);
};

#endif // DJT_ALLOCATION_H_
