#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
    int h = 0;
    int i = 0;
    char *p = NULL;

    if (argc <= 1) {
        printf("USAGE: cmd <str>\n");
        return 1;
    }

    p = argv[1];
    for (i = 0; i < strlen(p); i++) {
        h = h * 31 + p[i];
    }
    if (h < 0) {
        h = -h;
    }
    printf("%s hashcode is --> %d\n", p, h);
    return 0;
}
