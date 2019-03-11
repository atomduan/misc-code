/* Reverse Polish Notation calculator. */
%{
/* Prologue begin */
#include <linux_config.h>

int yylex(void);
void yyerror(char const *);
%}

%define api.value.type {double}

%token NUM


%%

/* Grammar rules begin */
input:
    %empty
|   input line
;

line:
    '\n'
|   exp '\n'    { printf ("%.10g\n", $1); }
;

/* the pseudo-variable $$ stands for the semantic value */
/* for the grouping that the rule is going to construct */
/* Assigning a value to $$ is the main job of most actions */
exp:
    NUM         { $$ = $1; }
|   exp exp '+' { $$ = $1 + $2; }
|   exp exp '-' { $$ = $1 - $2; }
|   exp exp '*' { $$ = $1 * $2; }
|   exp exp '/' { $$ = $1 / $2; }
|   exp exp '^' { $$ = pow($1, $2); }
|   exp 'n'     { $$ = -$1; }
;

%%

/*Epilogue Begin*/
int
yylex (void)
{
    int c;
    /* Skip white space. */
    while ((c=getchar()) == ' ' || c == '\t')
        continue;
    /* Process numbers. */
    if (c == '.' || isdigit(c)){
        ungetc(c, stdin);
        scanf("%lf", &yylval);
        return NUM;
    }
    /* Return end-of-input. */
    if (c == EOF)
        return 0;
    /* Return a single char. */
    return c;
}

/* Called by yyparse on error.  */
void
yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}
