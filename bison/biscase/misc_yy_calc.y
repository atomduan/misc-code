/* Infix notation calculator.  */
%{
#include <linux_config.h>

int yylex(void);
void yyerror(char const *);

%}

%defines "misc_yy_gen.h"

%define api.value.type {double}
%token NUM

/* the higher the line number of the declaration */
/* (lower on the page or screen), the higher the precedence */
%left '-' '+'
%left '*' '/'
%precedence NEG   /* negation--unary minus, also has a precedence, Context-Dependent Precedence */
%right '^'        /* exponentiation */

/* Grammar rules begin */
%%
input:
    %empty
|   input line
;

line:
    '\n'
|   exp '\n'                { printf ("%.10g\n", $1); }
;

/* the pseudo-variable $$ stands for the semantic value */
/* for the grouping that the rule is going to construct */
/* Assigning a value to $$ is the main job of most actions */
exp:
    NUM                     { $$ = $1; }
|   exp '+' exp             { $$ = $1 + $3; }
|   exp '-' exp             { $$ = $1 - $3; }
|   exp '*' exp             { $$ = $1 * $3; }
|   exp '/' exp             { $$ = $1 / $3; }
|   '-' exp  %prec NEG      { $$ = -$2; }
|   exp '^' exp             { $$ = pow($1, $3); }
|   '(' exp ')'             { $$ = $2; }
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
