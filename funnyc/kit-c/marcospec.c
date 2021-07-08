#include <kit_sys.h>

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
  mt_number_of_types 
};

int main(int argc, char **argv)
{
    int h = 0;
    char p[] = "8871613";

    printf("hello kit unit case......\n");
    for (char *tp = p; *tp!='\0'; tp++) {
        printf("v,%d\n", *tp);
        h = h * 31 + *tp;
    }
    if (h < 0) {
        h = -h;
    }
    printf("shard index --> %d\n", h % 100);
    return 0;
}
