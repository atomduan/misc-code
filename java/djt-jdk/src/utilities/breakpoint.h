#ifndef DJT_UTILITIES_BREAKPOINT_H
#define DJT_UTILITIES_BREAKPOINT_H
// If no more specific definition provided, default to calling a
// function that is defined per-platform.  See also os::breakpoint().
#ifndef BREAKPOINT
extern "C" void breakpoint();
#define BREAKPOINT ::breakpoint()
#endif
#endif // DJT_UTILITIES_BREAKPOINT_H
