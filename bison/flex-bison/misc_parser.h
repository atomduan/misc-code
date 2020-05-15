#ifndef MISC_YY_PARSER

#include <misc_config.h>

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

typedef struct init_fnct_s init_fnct;
struct init_fnct_s {
    char const *fname;
    double (*fnct) (double);
};

int init_lexer();
symrec *putsym(char const *, int);
symrec *getsym(char const *);

#endif/*MISC_YY_PARSER END*/
