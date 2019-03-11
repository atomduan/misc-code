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
|   exp '\n'                { printf("%.10g\n", $1); }
|   error '\n'              { 
                                fprintf(stderr,"recover by using yyerrok, waiting for next input\n");
                                yyerrok; 
                            }
;

/* the pseudo-variable $$ stands for the semantic value */
/* for the grouping that the rule is going to construct */
/* Assigning a value to $$ is the main job of most actions */
exp:
    NUM                     { $$ = $1; }
|   exp '+' exp             { $$ = $1 + $3; }
|   exp '-' exp             { $$ = $1 - $3; }
|   exp '*' exp             { $$ = $1 * $3; }
|   exp '/' exp             { 
                                if ($3 != 0) {
                                    $$ = $1 / $3;
                                } else {
                                    $$ = 1;
                                    fprintf(stderr,"(%d,%d)-(%d,%d): division bu zero\n",
                                            @3.first_line,@3.first_column,
                                            @3.last_line,@3.last_column);
                                    yyerror("zero error\n");
                                }
                            }
|   '-' exp  %prec NEG      { $$ = -$2; }
|   exp '^' exp             { $$ = pow($1, $3); }
|   '(' exp ')'             { $$ = $2; }
;
%%

/* Epilogue Begin */
int
yylex (void)
{
    int c;
    float yyfval;
    /* Skip white space */
    while ((c=getchar())==' ' || c=='\t')
        ++yylloc.last_column;
    /* Step */
    yylloc.first_line = yylloc.last_line;
    yylloc.first_column = yylloc.last_column;
    /* Process numbers */
    if (isdigit(c)) {
        yylval = c - '0';
        ++yylloc.last_column;
        while (isdigit(c = getchar())) {
            ++yylloc.last_column;
            yylval = (yylval*10) + (c-'0');
        }
        if (c == '.') {
            ++yylloc.last_column;
            yyfval = 0.0;
            while (isdigit(c = getchar())) {
                ++yylloc.last_column;
                yyfval = (yyfval*0.1) + (c-'0')*0.1;
            }
            yylval += yyfval;
        }
        ungetc (c, stdin);
        return NUM;
    }
    /* Return end-of-input */
    if (c == EOF) return 0;
    /* Return a single char, and update location */
    if (c == '\n') {
        ++yylloc.last_line;
        yylloc.last_column = 0;
    } else {
        ++yylloc.last_column;
    }
    return c;
}

/* Called by yyparse on error */
void
yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}
