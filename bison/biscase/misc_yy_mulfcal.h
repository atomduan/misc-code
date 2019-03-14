#ifndef MISC_YY_MULFCAL
/* Function type.  */
typedef double (*func_t)(double);

/* Data type for links in the chain of symbols.  */
typedef struct symrec_s symrec;
struct symrec_s {
  char *name;  /* name of symbol */
  int type;    /* type of symbol: either VAR or FNCT */
  union {
    double var;      /* value of a VAR */
    func_t fnctptr;  /* value of a FNCT */
  } value;
  symrec *next;  /* link field */
};

/* The symbol table: a chain of 'struct symrec'.  */
symrec *putsym(char const *, int);
symrec *getsym(char const *);
#endif
