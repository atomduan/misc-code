#include <linux_config.h>
#include <misc_yy_gen.h>

int
main(int argc,char **argv)
{
    yylloc.first_line = yylloc.last_line = 1;
    yylloc.first_column = yylloc.last_column = 0;
    return yyparse();
}

