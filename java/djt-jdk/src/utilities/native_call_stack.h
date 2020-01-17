#ifndef DJT_UTILITIES_NATIVECALLSTACK_H_
#define DJT_UTILITIES_NATIVECALLSTACK_H_

#include "memory/allocation.h"
#include "services/nmt_common.h"
#include "utilities/ostream.h"

/*
 * This class represents a native call path (does not include Java frame)
 *
 * This class is developed in the context of native memory tracking, it can
 * be an useful tool for debugging purpose.
 *
 * For example, following code should print out native call path:
 *
 *   ....
 *   NativeCallStack here;
 *   here.print_on(tty);
 *   ....
 *
 * However, there are a couple of restrictions on this class. If the restrictions are
 * not strictly followed, it may break native memory tracking badly.
 *
 * 1. Number of stack frames to capture, is defined by native memory tracking.
 *    This number has impacts on how much memory to be used by native
 *    memory tracking.
 * 2. The class is strict stack object, no heap or virtual memory can be allocated
 *    from it.
 */

class NativeCallStack : public StackObj {
 public:
  NativeCallStack(int toSkip = 0, bool fillStack = false);
  NativeCallStack(address* pc, int frameCount);

  static inline const NativeCallStack& empty_stack() {
    static const NativeCallStack EMPTY_STACK(0, false);
    return EMPTY_STACK;
  }

  // if it is an empty stack
  inline bool is_empty() const {
    return _stack[0] == NULL;
  }

  // number of stack frames captured
  int frames() const;

  inline int compare(const NativeCallStack& other) const {
    return memcmp(_stack, other._stack, sizeof(_stack));
  }

  inline bool equals(const NativeCallStack& other) const {
    // compare hash values
    if (hash() != other.hash()) return false;
    // compare each frame
    return compare(other) == 0;
  }

  inline address get_frame(int index) const {
    return _stack[index];
  }

  // Hash code. Any better algorithm?
  unsigned int hash() const;

  void print_on(OutputStream* out) const;
  void print_on(OutputStream* out, int indent) const;
 private:
  address       _stack[NMT_TrackingStackDepth];
  unsigned int  _hash_value;

};

#endif // DJT_UTILITIES_NATIVECALLSTACK_H_
