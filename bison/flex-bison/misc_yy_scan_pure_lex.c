#include <misc_parser.h>
#include <misc_yy_gen.h>

/* --------------------------------------------------------------------- */
/* The symbol table: a chain of 'struct symrec'.  */
static symrec *sym_table = NULL;

/* --------------------------------------------------------------------- */

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


/* --------------------------------------------------------------------- */
int init_lexer(void)
{
    int i;
    for (i=0; arith_fncts[i].fname != 0; i++) {
        symrec *ptr = putsym(arith_fncts[i].fname,FNCT);
        ptr->value.fnctptr = arith_fncts[i].fnct;
    }
    return 0;
}
