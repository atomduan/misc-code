#include <linux_config.h>

#define BOOL_TO_STR(_b_) ((_b_) ? "true" : "false")

// Format 32-bit quantities.
#define INT32_FORMAT           "%" PRId32
#define UINT32_FORMAT          "%" PRIu32
#define INT32_FORMAT_W(width)  "%" #width PRId32
#define UINT32_FORMAT_W(width) "%" #width PRIu32

#define PTR32_FORMAT           "0x%08" PRIx32
#define PTR32_FORMAT_W(width)  "0x%" #width PRIx32

// Format 64-bit quantities.
#define INT64_FORMAT           "%" PRId64
#define UINT64_FORMAT          "%" PRIu64
#define UINT64_FORMAT_X        "%" PRIx64
#define INT64_FORMAT_W(width)  "%" #width PRId64
#define UINT64_FORMAT_W(width) "%" #width PRIu64
#define UINT64_FORMAT_X_W(width) "%" #width PRIx64

#define PTR64_FORMAT           "0x%016" PRIx64

static void 
next_line(FILE *f)
{
  int c;
  do {
    c = fgetc(f);
  } while (c != '\n' && c != EOF);
}


int
main(int argn, char **argv)
{
    int           which_logical_cpu = 3;
    FILE*         fh;
    uint64_t      userTicks, niceTicks, systemTicks, idleTicks;
    // since at least kernel 2.6 : iowait: time waiting for I/O to complete
    // irq: time  servicing interrupts; softirq: time servicing softirqs
    uint64_t      iowTicks = 0, irqTicks = 0, sirqTicks= 0;
    // steal (since kernel 2.6.11): time spent in other OS when running in a virtualized environment
    uint64_t      stealTicks = 0;
    // guest (since kernel 2.6.24): time spent running a virtual CPU for guest OS under the
    // control of the Linux kernel
    uint64_t      guestNiceTicks = 0;
    int           logical_cpu = -1;
    const int     required_tickinfo_count = (which_logical_cpu == -1) ? 4 : 5;
    int           n;


    if ((fh = fopen("/proc/stat", "r")) == NULL) {
        return 1;
    }

    if (which_logical_cpu == -1) {
        n = fscanf(fh, "cpu " UINT64_FORMAT " " UINT64_FORMAT " " UINT64_FORMAT " "
            UINT64_FORMAT " " UINT64_FORMAT " " UINT64_FORMAT " " UINT64_FORMAT " "
            UINT64_FORMAT " " UINT64_FORMAT " ",
            &userTicks, &niceTicks, &systemTicks, &idleTicks,
            &iowTicks, &irqTicks, &sirqTicks,
            &stealTicks, &guestNiceTicks);
    } else {
    // Move to next line
    next_line(fh);

    // find the line for requested cpu faster to just iterate linefeeds?
    for (int i = 0; i < which_logical_cpu; i++) {
        next_line(fh);
    }

    n = fscanf(fh, "cpu%u " UINT64_FORMAT " " UINT64_FORMAT " " UINT64_FORMAT " "
               UINT64_FORMAT " " UINT64_FORMAT " " UINT64_FORMAT " " UINT64_FORMAT " "
               UINT64_FORMAT " " UINT64_FORMAT " ",
               &logical_cpu, &userTicks, &niceTicks,
               &systemTicks, &idleTicks, &iowTicks, &irqTicks, &sirqTicks,
               &stealTicks, &guestNiceTicks);
    }

    fclose(fh);
    if (n < required_tickinfo_count || logical_cpu != which_logical_cpu) {
      return 2;
    }
 
    printf("logical_cpu %d\n", logical_cpu);
    printf("used-->userTicks:%lu, niceTicks:%lu\n",userTicks,niceTicks);
    printf("usedKernel-->systemTicks:%lu, irqTicks:%lu, sirqTicks:%lu\n",systemTicks, irqTicks, sirqTicks);
    printf("total-->userTicks:%lu, niceTicks:%lu, systemTicks:%lu, idleTicks:%lu\n",userTicks, niceTicks, systemTicks, idleTicks);
    printf("total-->iowTicks:%lu, irqTicks:%lu, sirqTicks:%lu, stealTicks:%lu, guestNiceTicks:%lu\n",iowTicks, irqTicks, sirqTicks, stealTicks, guestNiceTicks);
    printf("stealTicks:%lu\n", stealTicks);

    return 0;
}
