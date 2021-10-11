#include <kit_sys.h>


int main(int argc, char **argv)
{
    rusage *r = malloc(sizeof(rusage));
    printf("r is %p", r);
    return 0;
}
