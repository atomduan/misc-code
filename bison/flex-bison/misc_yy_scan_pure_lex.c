#include <misc_parser.h>
#include <misc_yy_gen.h>

/* The symbol table: a chain of 'struct symrec'.  */
symrec *sym_table;
static symrec *putsym(char const *, int);
static symrec *getsym(char const *);

/* --------------------------------------------------------------------- */

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

/* --------------------------------------------------------------------- */

static symrec * putsym(const char *sym_name, int sym_type)
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

static symrec * getsym(const char *sym_name)
{
    symrec *ptr = NULL;
    for (ptr=sym_table; ptr!=NULL; ptr=ptr->next) {
        if (strcmp(ptr->name,sym_name) == 0) {
            return ptr;
        }
    }
    return 0;
}

void init_lexer(void)
{
    int i;
    for (i=0; arith_fncts[i].fname != 0; i++) {
        symrec *ptr = putsym(arith_fncts[i].fname,FNCT);
        ptr->value.fnctptr = arith_fncts[i].fnct;
    }
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
int yylex(YYSTYPE *lvalp, YYLTYPE *llocp)
{
    USE(llocp);
    int c;
    /* Ignore white space, get first nonwhite character. */
    while ((c=getchar())==' ' || c=='\t')
        continue;
    if (c == EOF) return 0;
    /* Char starts a number => parse the number. */
    if (c == '.' || isdigit(c)) {
        ungetc(c, stdin);
        scanf("%lf", &lvalp->DNUM);
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
        /* If s is not NULL, it is inited to a FNCT already in init_lexer() */
        if (s == 0) s = putsym(symbuf,VAR);
        lvalp->FUNC_PTR = s;
        return s->type;
    }
    /* Any other character is a token by itself. */
    return c;
}

