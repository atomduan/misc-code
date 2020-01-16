#include "runtime/os.h"
#include "memory/allocation.h"
#include "utilities/debug.h"
#include "services/mem_tracker.h"


// allocate using malloc; will fail if no memory available
char* allocateHeap(size_t size,
                   MEMFLAGS flags,
                   const NativeCallStack& stack,
                   AllocFailType alloc_failmode /* = AllocFailStrategy::EXIT_OOM*/) {
  char* p = (char*) os::malloc(size, flags, stack);
  if (p == NULL && alloc_failmode == AllocFailStrategy::EXIT_OOM) {
    vm_exit_out_of_memory(size, OOM_MALLOC_ERROR, "allocateHeap");
  }
  return p;
}

// handles NULL pointers
void freeHeap(void* p) {
  os::free(p);
}

void* StackObj::operator new(size_t size) throw() {
    UNUSED(size);
    ShouldNotCallThis();
    return 0;
}
void  StackObj::operator delete(void* p) {
    UNUSED(p);
    ShouldNotCallThis();
}
void* StackObj::operator new [](size_t size) throw() {
    UNUSED(size);
    ShouldNotCallThis();
    return 0;
}
void  StackObj::operator delete [](void* p) {
    UNUSED(p);
    ShouldNotCallThis();
}

void* ResourceObj::operator new [](size_t size, allocation_type type, MEMFLAGS flags) throw() {
  return (address) operator new(size, type, flags);
}

void* ResourceObj::operator new [](size_t size, const std::nothrow_t&  nothrow_constant,
    allocation_type type, MEMFLAGS flags) throw() {
  return (address)operator new(size, nothrow_constant, type, flags);
}

void ResourceObj::operator delete(void* p) {
  freeHeap(p);
}

void ResourceObj::operator delete [](void* p) {
  operator delete(p);
}

void ResourceObj::set_allocation_type(address res, allocation_type type) {
  // Set allocation type in the resource object
  uintptr_t allocation = (uintptr_t)res;
  ResourceObj* resobj = (ResourceObj *)res;
  resobj->_allocation_t[0] = ~(allocation + type);
  if (type != STACK_OR_EMBEDDED) {
    // Called from operator new(), set verification value.
    resobj->_allocation_t[1] = (uintptr_t)&(resobj->_allocation_t[1]) + type;
  }
}

ResourceObj::allocation_type ResourceObj::get_allocation_type() const {
  return (allocation_type)((~_allocation_t[0]) & allocation_mask);
}

bool ResourceObj::is_type_set() const {
  allocation_type type = (allocation_type)(_allocation_t[1] & allocation_mask);
  return get_allocation_type()  == type &&
         (_allocation_t[1] - type) == (uintptr_t)(&_allocation_t[1]);
}

// This whole business of passing information from ResourceObj::operator new
// to the ResourceObj constructor via fields in the "object" is technically UB.
// But it seems to work within the limitations of HotSpot usage (such as no
// multiple inheritance) with the compilers and compiler options we're using.
// And it gives some possibly useful checking for misuse of ResourceObj.
void ResourceObj::initialize_allocation_info() {
  if (~(_allocation_t[0] | allocation_mask) != (uintptr_t)this) {
    // Operator new() is not called for allocations
    // on stack and for embedded objects.
    set_allocation_type((address)this, STACK_OR_EMBEDDED);
  } else if (allocated_on_stack()) { // STACK_OR_EMBEDDED
    // For some reason we got a value which resembles
    // an embedded or stack object (operator new() does not
    // set such type). Keep it since it is valid value
    // (even if it was garbage).
    // Ignore garbage in other fields.
  } else if (is_type_set()) {
    // Operator new() was called and type was set.
  } else {
    // Operator new() was not called.
    // Assume that it is embedded or stack object.
    set_allocation_type((address)this, STACK_OR_EMBEDDED);
  }
  _allocation_t[1] = 0; // Zap verification value
}

ResourceObj::ResourceObj() {
  initialize_allocation_info();
}

ResourceObj::ResourceObj(const ResourceObj&) {
  // Initialize _allocation_t as a new object, ignoring object being copied.
  initialize_allocation_info();
}

ResourceObj& ResourceObj::operator=(const ResourceObj& r) {
  UNUSED(r);
  // Keep current _allocation_t value;
  return *this;
}

ResourceObj::~ResourceObj() {
  // allocated_on_C_heap() also checks that encoded (in _allocation) address == this.
  if (!allocated_on_C_heap()) { // ResourceObj::delete() will zap _allocation for C_heap.
    _allocation_t[0] = (uintptr_t)badHeapOopVal; // zap type
  }
}
