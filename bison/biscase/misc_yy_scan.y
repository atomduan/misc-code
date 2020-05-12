/* --------------------------------------------------------------------- */
%code top {
#include <misc_parser.h>
}

/* --------------------------------------------------------------------- */
/** 
 * writing dependency code for YYSTYPE and YYLTYPE, 
 * should prefer %code requires over %code top
 * if some file depend on misc_yy_gen.h, then all staff should define in %code requires
 */
%code requires {
#define YYDEBUG 1
#define USE(VALUE) /*empty*/

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

symrec *sym_table;
typedef struct init_fnct_s init_fnct;
struct init_fnct_s {
    char const *fname;
    double (*fnct) (double);
};

static const init_fnct arith_fncts[] =
{
    { "atan", atan },
    { "cos",  cos  },
    { "exp",  exp  },
    { "ln",   log  },
    { "sin",  sin  },
    { "sqrt", sqrt },
    { 0, 0 },
};

/* The symbol table: a chain of 'struct symrec'.  */
symrec *putsym(char const *, int);
symrec *getsym(char const *);
}

/* --------------------------------------------------------------------- */
%code provides {
void trace_token(enum yytokentype token, YYLTYPE loc);
}

/* --------------------------------------------------------------------- */
%code {
void print_token(FILE *file, int token, YYSTYPE val);
int yylex(void);
void yyerror(int argc, char **argv, char const *msg);
void init_table();
}

/* --------------------------------------------------------------------- */

/* Declarations Section */
%verbose
%defines "misc_yy_gen.h"
%define parse.trace
%define parse.error verbose
%define lr.keep-unreachable-state true
%define api.value.type {union YYSTYPE}
%define api.pure false
%parse-param {int argc} {char **argv}

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

%printer { printf("FUNC_PTR, name:%s\n", $$->name); } <FUNC_PTR>
%printer { /*do nothing*/ } <*>
%printer { /*do nothing*/ } <>

%glr-parser

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
                                            yyerror(argc,argv,"use uninit VAR error\n");
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
                                            yyerror(argc,argv,"zero error\n");
                                        }
                                    }
|   '-' exp %prec NEG               { $$ = -$2; }
|   exp[base] '^' exp[factor]       { $$ =  pow($[base],$[factor]); }
|   '(' exp ')'                     { $$ =  $2; }
;
%%

/* --------------------------------------------------------------------- */
/* Epilogue Begin */
symrec * putsym(const char *sym_name, int sym_type)
{
    symrec *ptr = (symrec*) malloc(sizeof(symrec));
    ptr->name = (char*)malloc(strlen(sym_name)+1);
    strcpy (ptr->name,sym_name);
    ptr->type = sym_type;
    ptr->value.var = 0; /* Set value to 0 even if fctn.  */
    ptr->has_init = 0;
    ptr->next = sym_table;
    sym_table = ptr;
    return ptr;
}

symrec * getsym(const char *sym_name)
{
    symrec *ptr = NULL;
    for (ptr=sym_table; ptr!=NULL; ptr=ptr->next) {
        if (strcmp(ptr->name,sym_name) == 0) {
            return ptr;
        }
    }
    return 0;
}

/* Called by yyparse on error */
void print_token(FILE *file, int token, YYSTYPE val)
{
    //do nothing...
}

void yyerror(int argc, char **argv, char const *msg)
{
    USE(argc);
    USE(argv);
    fprintf(stderr,"%s\n",msg);
}

void init_table(void)
{
    int i;
    for (i=0; arith_fncts[i].fname != 0; i++) {
        symrec *ptr = putsym(arith_fncts[i].fname,FNCT);
        ptr->value.fnctptr = arith_fncts[i].fnct;
    }
}

int process_yy(int argc,char **argv)
{
    int i;
    /* Enable parse traces on option -x.  */
    for (i = 1; i < argc; ++i)
        if (strcmp(argv[i],"-x") == 0)
            yydebug = 1;
    init_table ();
    return yyparse(argc,argv);
}
