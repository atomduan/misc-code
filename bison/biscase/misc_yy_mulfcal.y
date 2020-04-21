/* Infix notation calculator.  */
%{

#include <misc_parser.h>
#include <misc_yy_mulfcal.h>

#define YYDEBUG 1

int yylex();
void yyerror(const char *);
void init_table();

%}

%defines "misc_yy_gen.h"

%define api.value.type union
%token  <double>        NUM
%token  <symrec*>       VAR FNCT
%type   <double>        exp

/* the higher the line number of the declaration */
/* (lower on the page or screen), the higher the precedence */
%left '-' '+'
%left '*' '/'
%precedence NEG   /* negation--unary minus, also has a precedence, Context-Dependent Precedence */
%right '^'        /* exponentiation */

%expect 5   /* Means we expect 5 s-r conflicts */

/* Grammar rules begin */
%%
input:
    %empty
|   input line
;

line:
    '\n'
|   exp '\n'                { printf("%.10g\n", $1); }
|   error '\n'              { yyerrok; }
;

exp:
    NUM                     { $$ = $1; }
|   VAR                     { 
                                if ($1->has_init == 1) {
                                    $$ = $1->value.var; 
                                } else {
                                    printf("use uninit VAR name %s\n", $1->name);
                                    yyerror("use uninit VAR error\n");
                                }
                            }
|   VAR '=' exp             { 
                                $$ = $3; 
                                $1->value.var = $3;
                                $1->has_init = 1;
                            }
|   FNCT '(' exp ')'        { $$ = (*($1->value.fnctptr))($3); }
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

int
yylex(void)
{
    int c;
    /* Ignore white space, get first nonwhite character. */
    while ((c=getchar())==' ' || c=='\t')
        continue;
    if (c == EOF) return 0;
    /* Char starts a number => parse the number. */
    if (c == '.' || isdigit(c)) {
        ungetc(c, stdin);
        scanf("%lf", &yylval.NUM);
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

void
yyerror(const char *s)
{
    fprintf(stderr,"%s\n",s);
}

void
init_table(void)
{
    int i;
    for (i=0; arith_fncts[i].fname != 0; i++) {
        symrec *ptr = putsym(arith_fncts[i].fname,FNCT);
        ptr->value.fnctptr = arith_fncts[i].fnct;
    }
}

int
process_yy(int argc,char **argv)
{
    int i;
    /* Enable parse traces on option -x.  */
    for (i = 1; i < argc; ++i)
        if (strcmp(argv[i],"-x") == 0)
            yydebug = 1;
    init_table ();
    return yyparse();
}
