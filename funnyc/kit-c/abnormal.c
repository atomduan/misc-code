#include <kit_sys.h>

#define EXIT_INTERNAL_ERROR 14 

static void internal_error(void)
{
    if (1 == 1) {
        _exit(EXIT_INTERNAL_ERROR);
    }
}

int main(int argc, char **argv)
{
    internal_error();
    return 0;
}
