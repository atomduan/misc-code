/*
 * Copyright (c) 1997, 2019, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 *
 */

#ifndef SHARE_RUNTIME_OS_HPP
#define SHARE_RUNTIME_OS_HPP

#include "jvm.h"
#include "jvmtifiles/jvmti.h"
#include "metaprogramming/isRegisteredEnum.hpp"
#include "metaprogramming/integralConstant.hpp"
#include "runtime/extendedPC.hpp"
#include "utilities/exceptions.hpp"
#include "utilities/ostream.hpp"
#include "utilities/macros.hpp"
#ifndef _WINDOWS
# include <setjmp.h>
#endif
#ifdef __APPLE__
# include <mach/mach_time.h>
#endif

class AgentLibrary;
class frame;

// os defines the interface to operating system; this includes traditional
// OS services (time, I/O) as well as other functionality with system-
// dependent code.

typedef void (*dll_func)(...);

class Thread;
class JavaThread;
class NativeCallStack;
class methodHandle;
class OSThread;
class Mutex;

template<class E> class GrowableArray;

// %%%%% Moved ThreadState, START_FN, OSThread to new osThread.hpp. -- Rose

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

// Executable parameter flag for os::commit_memory() and
// os::commit_memory_or_exit().
const bool ExecMem = true;

// Typedef for structured exception handling support
typedef void (*java_call_t)(JavaValue* value, const methodHandle& method, JavaCallArguments* args, Thread* thread);

class MallocTracker;

class os: AllStatic {
  friend class VMStructs;
  friend class JVMCIVMStructs;
  friend class MallocTracker;

#ifdef ASSERT
 private:
  static bool _mutex_init_done;
 public:
  static void set_mutex_init_done() { _mutex_init_done = true; }
  static bool mutex_init_done() { return _mutex_init_done; }
#endif

 public:
  enum { page_sizes_max = 9 }; // Size of _page_sizes array (8 plus a sentinel)

 private:
  static OSThread*          _starting_thread;
  static address            _polling_page;
 public:
  static size_t             _page_sizes[page_sizes_max];

 private:
  static void init_page_sizes(size_t default_page_size) {
    _page_sizes[0] = default_page_size;
    _page_sizes[1] = 0; // sentinel
  }

  static char*  pd_reserve_memory(size_t bytes, char* addr = 0,
                                  size_t alignment_hint = 0);
  static char*  pd_attempt_reserve_memory_at(size_t bytes, char* addr);
  static char*  pd_attempt_reserve_memory_at(size_t bytes, char* addr, int file_desc);
  static void   pd_split_reserved_memory(char *base, size_t size,
                                      size_t split, bool realloc);
  static bool   pd_commit_memory(char* addr, size_t bytes, bool executable);
  static bool   pd_commit_memory(char* addr, size_t size, size_t alignment_hint,
                                 bool executable);
  // Same as pd_commit_memory() that either succeeds or calls
  // vm_exit_out_of_memory() with the specified mesg.
  static void   pd_commit_memory_or_exit(char* addr, size_t bytes,
                                         bool executable, const char* mesg);
  static void   pd_commit_memory_or_exit(char* addr, size_t size,
                                         size_t alignment_hint,
                                         bool executable, const char* mesg);
  static bool   pd_uncommit_memory(char* addr, size_t bytes);
  static bool   pd_release_memory(char* addr, size_t bytes);

  static char*  pd_map_memory(int fd, const char* file_name, size_t file_offset,
                           char *addr, size_t bytes, bool read_only = false,
                           bool allow_exec = false);
  static char*  pd_remap_memory(int fd, const char* file_name, size_t file_offset,
                             char *addr, size_t bytes, bool read_only,
                             bool allow_exec);
  static bool   pd_unmap_memory(char *addr, size_t bytes);
  static void   pd_free_memory(char *addr, size_t bytes, size_t alignment_hint);
  static void   pd_realign_memory(char *addr, size_t bytes, size_t alignment_hint);

  static size_t page_size_for_region(size_t region_size, size_t min_pages, bool must_be_aligned);

  // Get summary strings for system information in buffer provided
  static void  get_summary_cpu_info(char* buf, size_t buflen);
  static void  get_summary_os_info(char* buf, size_t buflen);

  static void initialize_initial_active_processor_count();

  LINUX_ONLY(static void pd_init_container_support();)

 public:
  static char* strdup(const char *, MEMFLAGS flags = mtInternal);  // Like strdup
  // Like strdup, but exit VM when strdup() returns NULL
  static char* strdup_check_oom(const char*, MEMFLAGS flags = mtInternal);

#ifndef PRODUCT
  static julong num_mallocs;         // # of calls to malloc/realloc
  static julong alloc_bytes;         // # of bytes allocated
  static julong num_frees;           // # of calls to free
  static julong free_bytes;          // # of bytes freed
#endif

  // SocketInterface (ex HPI SocketInterface )
  static int socket(int domain, int type, int protocol);
  static int socket_close(int fd);
  static int recv(int fd, char* buf, size_t nBytes, uint flags);
  static int send(int fd, char* buf, size_t nBytes, uint flags);
  static int raw_send(int fd, char* buf, size_t nBytes, uint flags);
  static int connect(int fd, struct sockaddr* him, socklen_t len);
  static struct hostent* get_host_by_name(char* name);

  // Support for signals (see JVM_RaiseSignal, JVM_RegisterSignal)
  static void  initialize_jdk_signal_support(TRAPS);
  static void  signal_notify(int signal_number);
  static void* signal(int signal_number, void* handler);
  static void  signal_raise(int signal_number);
  static int   signal_wait();
  static void* user_handler();
  static void  terminate_signal_thread();
  static int   sigexitnum_pd();

  // random number generation
  static int random();                     // return 32bit pseudorandom number
  static void init_random(unsigned int initval);    // initialize random sequence

  // Structured OS Exception support
  static void os_exception_wrapper(java_call_t f, JavaValue* value, const methodHandle& method, JavaCallArguments* args, Thread* thread);

  // On Posix compatible OS it will simply check core dump limits while on Windows
  // it will check if dump file can be created. Check or prepare a core dump to be
  // taken at a later point in the same thread in os::abort(). Use the caller
  // provided buffer as a scratch buffer. The status message which will be written
  // into the error log either is file location or a short error message, depending
  // on the checking result.
  static void check_dump_limit(char* buffer, size_t bufferSize);

  // Get the default path to the core file
  // Returns the length of the string
  static int get_core_path(char* buffer, size_t bufferSize);

  // JVMTI & JVM monitoring and management support
  // The thread_cpu_time() and current_thread_cpu_time() are only
  // supported if is_thread_cpu_time_supported() returns true.
  // They are not supported on Solaris T1.

  // Thread CPU Time - return the fast estimate on a platform
  // On Solaris - call gethrvtime (fast) - user time only
  // On Linux   - fast clock_gettime where available - user+sys
  //            - otherwise: very slow /proc fs - user+sys
  // On Windows - GetThreadTimes - user+sys
  static jlong current_thread_cpu_time();
  static jlong thread_cpu_time(Thread* t);

  // Thread CPU Time with user_sys_cpu_time parameter.
  //
  // If user_sys_cpu_time is true, user+sys time is returned.
  // Otherwise, only user time is returned
  static jlong current_thread_cpu_time(bool user_sys_cpu_time);
  static jlong thread_cpu_time(Thread* t, bool user_sys_cpu_time);

  // Return a bunch of info about the timers.
  // Note that the returned info for these two functions may be different
  // on some platforms
  static void current_thread_cpu_time_info(jvmtiTimerInfo *info_ptr);
  static void thread_cpu_time_info(jvmtiTimerInfo *info_ptr);

  static bool is_thread_cpu_time_supported();

  // System loadavg support.  Returns -1 if load average cannot be obtained.
  static int loadavg(double loadavg[], int nelem);

  // Amount beyond the callee frame size that we bang the stack.
  static int extra_bang_size_in_bytes();

  static char** split_path(const char* path, size_t* elements, size_t file_name_length);

  // support for mapping non-volatile memory using MAP_SYNC
  static bool supports_map_sync();

 public:
  class CrashProtectionCallback : public StackObj {
  public:
    virtual void call() = 0;
  };

  // Platform dependent stuff
#ifndef _WINDOWS
# include "os_posix.hpp"
#endif
#include OS_CPU_HEADER(os)
#include OS_HEADER(os)

#ifndef OS_NATIVE_THREAD_CREATION_FAILED_MSG
#define OS_NATIVE_THREAD_CREATION_FAILED_MSG "unable to create native thread: possibly out of memory or process/resource limits reached"
#endif

 public:
#ifndef PLATFORM_PRINT_NATIVE_STACK
  // No platform-specific code for printing the native stack.
  static bool platform_print_native_stack(outputStream* st, const void* context,
                                          char *buf, int buf_size) {
    return false;
  }
#endif

  // debugging support (mostly used by debug.cpp but also fatal error handler)
  static bool find(address pc, outputStream* st = tty); // OS specific function to make sense out of an address

  static bool dont_yield();                     // when true, JVM_Yield() is nop
  static void print_statistics();

  // Thread priority helpers (implemented in OS-specific part)
  static OSReturn set_native_priority(Thread* thread, int native_prio);
  static OSReturn get_native_priority(const Thread* const thread, int* priority_ptr);
  static int java_to_os_priority[CriticalPriority + 1];
  // Hint to the underlying OS that a task switch would not be good.
  // Void return because it's a hint and can fail.
  static const char* native_thread_creation_failed_msg() {
    return OS_NATIVE_THREAD_CREATION_FAILED_MSG;
  }

  // Used at creation if requested by the diagnostic flag PauseAtStartup.
  // Causes the VM to wait until an external stimulus has been applied
  // (for Unix, that stimulus is a signal, for Windows, an external
  // ResumeThread call)
  static void pause();

  // Builds a platform dependent Agent_OnLoad_<libname> function name
  // which is used to find statically linked in agents.
  static char*  build_agent_function_name(const char *sym, const char *cname,
                                          bool is_absolute_path);

  class SuspendedThreadTaskContext {
  public:
    SuspendedThreadTaskContext(Thread* thread, void *ucontext) : _thread(thread), _ucontext(ucontext) {}
    Thread* thread() const { return _thread; }
    void* ucontext() const { return _ucontext; }
  private:
    Thread* _thread;
    void* _ucontext;
  };

  class SuspendedThreadTask {
  public:
    SuspendedThreadTask(Thread* thread) : _thread(thread), _done(false) {}
    void run();
    bool is_done() { return _done; }
    virtual void do_task(const SuspendedThreadTaskContext& context) = 0;
  protected:
    ~SuspendedThreadTask() {}
  private:
    void internal_do_task();
    Thread* _thread;
    bool _done;
  };

#ifndef _WINDOWS
  // Suspend/resume support
  // Protocol:
  //
  // a thread starts in SR_RUNNING
  //
  // SR_RUNNING can go to
  //   * SR_SUSPEND_REQUEST when the WatcherThread wants to suspend it
  // SR_SUSPEND_REQUEST can go to
  //   * SR_RUNNING if WatcherThread decides it waited for SR_SUSPENDED too long (timeout)
  //   * SR_SUSPENDED if the stopped thread receives the signal and switches state
  // SR_SUSPENDED can go to
  //   * SR_WAKEUP_REQUEST when the WatcherThread has done the work and wants to resume
  // SR_WAKEUP_REQUEST can go to
  //   * SR_RUNNING when the stopped thread receives the signal
  //   * SR_WAKEUP_REQUEST on timeout (resend the signal and try again)
  class SuspendResume {
   public:
    enum State {
      SR_RUNNING,
      SR_SUSPEND_REQUEST,
      SR_SUSPENDED,
      SR_WAKEUP_REQUEST
    };

  private:
    volatile State _state;

  private:
    /* try to switch state from state "from" to state "to"
     * returns the state set after the method is complete
     */
    State switch_state(State from, State to);

  public:
    SuspendResume() : _state(SR_RUNNING) { }

    State state() const { return _state; }

    State request_suspend() {
      return switch_state(SR_RUNNING, SR_SUSPEND_REQUEST);
    }

    State cancel_suspend() {
      return switch_state(SR_SUSPEND_REQUEST, SR_RUNNING);
    }

    State suspended() {
      return switch_state(SR_SUSPEND_REQUEST, SR_SUSPENDED);
    }

    State request_wakeup() {
      return switch_state(SR_SUSPENDED, SR_WAKEUP_REQUEST);
    }

    State running() {
      return switch_state(SR_WAKEUP_REQUEST, SR_RUNNING);
    }

    bool is_running() const {
      return _state == SR_RUNNING;
    }

    bool is_suspend_request() const {
      return _state == SR_SUSPEND_REQUEST;
    }

    bool is_suspended() const {
      return _state == SR_SUSPENDED;
    }
  };
#endif // !WINDOWS


 protected:
  static volatile unsigned int _rand_seed;    // seed for random number generator
  static int _processor_count;                // number of processors
  static int _initial_active_processor_count; // number of active processors during initialization.

  static char* format_boot_path(const char* format_string,
                                const char* home,
                                int home_len,
                                char fileSep,
                                char pathSep);
  static bool set_boot_path(char fileSep, char pathSep);

};

#ifndef _WINDOWS
template<> struct IsRegisteredEnum<os::SuspendResume::State> : public TrueType {};
#endif // !_WINDOWS

// Note that "PAUSE" is almost always used with synchronization
// so arguably we should provide Atomic::SpinPause() instead
// of the global SpinPause() with C linkage.
// It'd also be eligible for inlining on many platforms.

extern "C" int SpinPause();

#endif // SHARE_RUNTIME_OS_HPP

