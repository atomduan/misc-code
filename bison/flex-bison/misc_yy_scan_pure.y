/* --------------------------------------------------------------------- */
%code top {
#include <misc_parser.h>
#define YYDEBUG 1
}/*code top end*/
/** 
 * writing dependency code for YYSTYPE and YYLTYPE, 
 * should prefer %code requires over %code top
 */
%code requires {
/* Function type.  */
typedef double (*func_t)(double);
/* Data type for links in the chain of symbols.  */
typedef struct symrec_s symrec;
struct symrec_s {
    char *name;  /* name of symbol */
    int type;    /* type of symbol: either VAR or FNCT */
    int has_init;
    union {
        double var;      /* value of a VAR */
        func_t fnctptr;  /* value of a FNCT */
    } value;
    symrec *next;  /* link field */
};
#define YYLTYPE YYLTYPE
typedef struct YYLTYPE {
    int first_line; 
    int first_column; 
    int last_line; 
    int last_column; 
    char *filename;
} YYLTYPE; 
union YYSTYPE {
    double  DNUM;    
    symrec *FUNC_PTR;
};
int init_lexer();
}/*code requires end*/
%code {
int yylex(YYSTYPE *lvalp, YYLTYPE *llocp);
void yyerror(YYLTYPE *yylsp, char const *msg);
}/*code end*/




/* --------------------------------------------------------------------- */
/* Declarations Section */
%defines "misc_yy_gen.h"
%define api.value.type {union YYSTYPE}
/*pure option not compatitable with %glr-parser */
%define api.pure full 

%token  <DNUM>        NUM
%token  <FUNC_PTR>    VAR FNCT
%nterm  <DNUM>        exp

%left '-' '+'
%left '*' '/'
%precedence NEG
%right '^'
%expect 5

%destructor { printf("DNUM dsctructor, do nothing\n"); } <DNUM>
%destructor { printf("FUNC_PTR dsctructor\n"); free($$); } <FUNC_PTR>
%destructor { free($$); } <*>
%destructor { printf("Discarding tagless symbol.\n"); } <>

%printer { /*do nothing*/ } <*>
%printer { /*do nothing*/ } <>
%printer { printf("FUNC_PTR, name:%s\n", $$->name); } <FUNC_PTR>




/* --------------------------------------------------------------------- */
/* Grammar Rules Section */ 
%%
input:
    %empty                          /*If you don’t specify an action for a rule, Bison supplies a default: $$ = $1.*/
|   input line
;

line:
    '\n'
|   exp '\n'                        { printf("%.10g\n", $1); }
|   error '\n'                      { yyerrok; }
;

exp:
    NUM                             { $$ = $1; }
|   VAR[var]                        { 
                                        if ($[var]->has_init == 1) {
                                            $$ = $[var]->value.var; 
                                        } else {
                                            printf("use uninit VAR name %s\n", $[var]->name);
                                            yyerror(yylsp,"use uninit VAR error\n");
                                        }
                                    }
|   VAR[var] '=' exp                { 
                                        $$ = $3; 
                                        $[var]->value.var = $3;
                                        $[var]->has_init = 1;
                                    }
|   FNCT[func] '(' exp ')'          { $$ = (*($[func]->value.fnctptr))($3); }
|   exp[left] '+' exp[right]        { $$ = $[left] + $[right]; }
|   exp[left] '-' exp[right]        { $$ = $[left] - $[right]; }
|   exp[left] '*' exp[right]        { $$ = $[left] * $[right]; }
|   exp[left] '/' exp[right]        { 
                                        if ($[right] != 0) {
                                            $$ = $[left] / $[right];
                                        } else {
                                            $$ = 1;
                                            fprintf(stderr,"(%d,%d)-(%d,%d): division bu zero\n",
                                                    @[right].first_line,@[right].first_column,
                                                    @[right].last_line,@[right].last_column);
                                            yyerror(yylsp,"zero error\n");
                                        }
                                    }
|   '-' exp %prec NEG               { $$ = -$2; }
|   exp[base] '^' exp[factor]       { $$ =  pow($[base],$[factor]); }
|   '(' exp ')'                     { $$ =  $2; }
;
%%




/* --------------------------------------------------------------------- */
/* Epilogue Begin */
void yyerror(YYLTYPE *yylsp, char const *msg)
{
    USE(yylsp);
    fprintf(stderr,"%s\n",msg);
}
