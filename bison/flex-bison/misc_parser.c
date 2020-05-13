#include <misc_parser.h>
#include <misc_yy_gen.h>

int
main(int argc,char **argv)
{
    int i;
    /* Enable parse traces on option -x.  */
    for (i = 1; i < argc; ++i)
        if (strcmp(argv[i],"-x") == 0)
            yydebug = 1;
    init_lexer();
    return yyparse();
}

int init_parser()
{
    /*do noting*/
    return 0;
}
