/* --------------------------------------------------------------------- */
%code top {
#include <misc_parser.h>
#define YYDEBUG 1

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

/* The symbol table: a chain of 'struct symrec'.  */
symrec *putsym(char const *, int);
symrec *getsym(char const *);
}

/* --------------------------------------------------------------------- */
/** 
 * writing dependency code for YYSTYPE and YYLTYPE, 
 * should prefer %code requires over %code top
 */
%code requires {
#define YYLTYPE YYLTYPE
typedef struct YYLTYPE {
    int first_line; 
    int first_column; 
    int last_line; 
    int last_column; 
    char *filename;
} YYLTYPE; 

/**/
union YYSTYPE {
    double  DNUM;    
    symrec *FUNC_PTR;
};
}

/* --------------------------------------------------------------------- */
%code provides {
void trace_token(enum yytokentype token, YYLTYPE loc);
}

/* --------------------------------------------------------------------- */
%code {
void print_token(FILE *file, int token, YYSTYPE val);
int yylex(void);
void yyerror(char const *);
void init_table();
}

/* --------------------------------------------------------------------- */

/* Declarations Section */
%defines "misc_yy_gen.h"
%define api.value.type {union YYSTYPE}

%token  <DNUM>        NUM
%token  <FUNC_PTR>          VAR FNCT
%nterm  <DNUM>        exp

%left '-' '+'
%left '*' '/'
%precedence NEG
%right '^'
%expect 5

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
                                        if ($var->has_init == 1) {
                                            $$ = $var->value.var; 
                                        } else {
                                            printf("use uninit VAR name %s\n", $var->name);
                                            yyerror("use uninit VAR error\n");
                                        }
                                    }
|   VAR[var] '=' exp                { 
                                        $$ = $3; 
                                        $var->value.var = $3;
                                        $var->has_init = 1;
                                    }
|   FNCT[func] '(' exp ')'          { $$ = (*($func->value.fnctptr))($3); }
|   exp[left] '+' exp[right]        { $$ = $left + $right; }
|   exp[left] '-' exp[right]        { $$ = $left - $right; }
|   exp[left] '*' exp[right]        { $$ = $left * $right; }
|   exp[left] '/' exp[right]        { 
                                        if ($right != 0) {
                                            $$ = $left / $right;
                                        } else {
                                            $$ = 1;
                                            fprintf(stderr,"(%d,%d)-(%d,%d): division bu zero\n",
                                                    @right.first_line,@right.first_column,
                                                    @right.last_line,@right.last_column);
                                            yyerror("zero error\n");
                                        }
                                    }
|   '-' exp %prec NEG               { $$ = -$2; }
|   exp[base] '^' exp[factor]       { $$ =  pow($base,$factor); }
|   '(' exp ')'                     { $$ =  $2; }
;
%%

/* --------------------------------------------------------------------- */
/* Epilogue Begin */
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

/**
 * The lexical analyzer’s job is low-level parsing: converting characters or sequences of char- acters into tokens.
 * This works in two ways. 
 * If the token type is a character literal, 
 * then its numeric code is that of the character; 
 * you can use the same character literal in the lexical analyzer to express the number. 
 * If the token type is an identifier, 
 * that identifier is defined by Bison as a C macro 
 * whose definition is the appropriate number. 
 * In this example, therefore, NUM becomes a macro for yylex to use.
 */
int yylex (void)
{
    int c;
    /* Ignore white space, get first nonwhite character. */
    while ((c=getchar())==' ' || c=='\t')
        continue;
    if (c == EOF) return 0;
    /* Char starts a number => parse the number. */
    if (c == '.' || isdigit(c)) {
        ungetc(c, stdin);
        scanf("%lf", &yylval.DNUM);
        return NUM;
    }
    /* Char starts an identifier => read the name. */
    if (isalpha(c)) {
        /* Initially make the buffer long enough
         for a 40-character symbol name. */
        static size_t length = 40;
        static char *symbuf = 0;
        symrec *s;
        size_t i;
        if (!symbuf)
            symbuf = (char*)malloc(length+1);
        i = 0;
        do {
            /* If buffer is full, make it bigger. */
            if (i == length) {
                length *= 2;
                symbuf = (char*)realloc(symbuf,length+1);
            }
            /* Add this character to the buffer. */
            symbuf[i++] = c;
            /* Get another character. */
            c = getchar();
        } while (isalnum(c));

        ungetc(c,stdin);
        symbuf[i] = '\0';

        s = getsym(symbuf);
        /* If s is not NULL, it is inited to a FNCT already in init_table() */
        if (s == 0) s = putsym(symbuf,VAR);
        *((symrec**) &yylval) = s;
        return s->type;
    }
    /* Any other character is a token by itself. */
    return c;
}

void yyerror(const char *s)
{
    fprintf(stderr,"%s\n",s);
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
    return yyparse();
}
