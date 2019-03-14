#include <linux_config.h>
#include <misc_parser.h>
#include <misc_yy_mulfcal.h>

symrec *sym_table;

symrec *
putsym(const char *sym_name, int sym_type)
{
    symrec *ptr = (symrec*) malloc(sizeof(symrec));
    ptr->name = (char*)malloc(strlen(sym_name)+1);
    strcpy (ptr->name,sym_name);
    ptr->type = sym_type;
    ptr->value.var = 0; /* Set value to 0 even if fctn.  */
    ptr->next = sym_table;
    sym_table = ptr;
    return ptr;
}

symrec *
getsym(const char *sym_name)
{
    symrec *ptr = NULL;
    for (ptr=sym_table; ptr!=NULL; ptr=ptr->next) {
        if (strcmp(ptr->name,sym_name) == 0) {
            return ptr;
        }
    }
    return 0;
}
