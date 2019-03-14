/* Infix notation calculator.  */
/* code will be order to top --> requires --> provide --> norm*/

%code  {
#code norm 1
}

%code top {
#code top 1
}

%code requires {
#code requires 1
}

%code top {
#code top 2
}

%code provides {
#code provides 1
}

%code requires {
#code requires 2
}

%code  {
#code norm 2
}

%code provides {
#code provides 2
}

%code  {
#code norm 3
}

/* Grammar rules begin */
%%
input:
    %empty
;
%%

/* Epilogue Begin */
int
yylex (void)
{
    return 0;
}

/* Called by yyparse on error */
void
yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}

int
process_yy(int argc,char **argv)
{
    return yyparse();
}
