%code top {
#include <misc_parser.h>
#define YYDEBUG 1
}

%code requires {
union YYSTYPE {
    int intval;
    double floatval;
    char *strval;
    int subtok;
};
}

%code {
void init_table();
int yylex(void);
void yyerror(char const *);
}

/* Declarations Section */
%defines "misc_yy_gen.h"
%define api.value.type {union YYSTYPE}
    
%token NAME
%token STRING
%token INTNUM APPROXNUM

/* operators */

%left OR
%left AND
%left NOT
%left <subtok> COMPARISON /* = <> < > <= >= */
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

/* literal keyword tokens */
%token ALL AMMSC ANY AS ASC AUTHORIZATION BETWEEN BY
%token CHARACTER CHECK CLOSE COMMIT CONTINUE CREATE CURRENT
%token CURSOR DECIMAL DECLARE DEFAULT DELETE DESC DISTINCT DOUBLE
%token ESCAPE EXISTS FETCH FLOAT FOR FOREIGN FOUND FROM GOTO
%token GRANT GROUP HAVING IN INDICATOR INSERT INTEGER INTO
%token IS KEY LANGUAGE LIKE MODULE NULLX NUMERIC OF ON
%token OPEN OPTION ORDER PRECISION PRIMARY PRIVILEGES PROCEDURE
%token PUBLIC REAL REFERENCES ROLLBACK SCHEMA SELECT SET
%token SMALLINT SOME SQLCODE SQLERROR TABLE TO UNION
%token UNIQUE UPDATE USER VALUES VIEW WHENEVER WHERE WITH WORK
%token COBOL FORTRAN PASCAL PLI C ADA

%destructor { printf("destructor intval, do nothing.\n"); } <intval>
%destructor { printf("destructor floatval, do nothing.\n"); } <floatval>
%destructor { printf("destructor subtok, do nothing.\n"); } <subtok>
%destructor { printf("Discarding tagless symbol.\n"); } <>
%destructor { free($$); } <*>
%%
sql_list:
        sql ';'
    |   sql_list sql ';'
    ;


/* schema definition language */
/* Note: other ``sql:'' rules appear later in the grammar */
sql:        schema
    ;
    
schema:
        CREATE SCHEMA AUTHORIZATION user opt_schema_element_list
    ;

opt_schema_element_list:
        /* empty */
    |   schema_element_list
    ;

schema_element_list:
        schema_element
    |   schema_element_list schema_element
    ;

schema_element:
        base_table_def
    |   view_def
    |   privilege_def
    ;

base_table_def:
        CREATE TABLE table '(' base_table_element_commalist ')'
    ;

base_table_element_commalist:
        base_table_element
    |   base_table_element_commalist ',' base_table_element
    ;

base_table_element:
        column_def
    |   table_constraint_def
    ;

column_def:
        column data_type column_def_opt_list
    ;

column_def_opt_list:
        /* empty */
    |   column_def_opt_list column_def_opt
    ;

column_def_opt:
        NOT NULLX
    |   NOT NULLX UNIQUE
    |   NOT NULLX PRIMARY KEY
    |   DEFAULT literal
    |   DEFAULT NULLX
    |   DEFAULT USER
    |   CHECK '(' search_condition ')'
    |   REFERENCES table
    |   REFERENCES table '(' column_commalist ')'
    ;

table_constraint_def:
        UNIQUE '(' column_commalist ')'
    |   PRIMARY KEY '(' column_commalist ')'
    |   FOREIGN KEY '(' column_commalist ')'
            REFERENCES table 
    |   FOREIGN KEY '(' column_commalist ')'
            REFERENCES table '(' column_commalist ')'
    |   CHECK '(' search_condition ')'
    ;

column_commalist:
        column
    |   column_commalist ',' column
    ;

view_def:
        CREATE VIEW table opt_column_commalist
        AS query_spec opt_with_check_option
    ;
    
opt_with_check_option:
        /* empty */
    |   WITH CHECK OPTION
    ;

opt_column_commalist:
        /* empty */
    |   '(' column_commalist ')'
    ;

privilege_def:
        GRANT privileges ON table TO grantee_commalist
        opt_with_grant_option
    ;

opt_with_grant_option:
        /* empty */
    |   WITH GRANT OPTION
    ;

privileges:
        ALL PRIVILEGES
    |   ALL
    |   operation_commalist
    ;

operation_commalist:
        operation
    |   operation_commalist ',' operation
    ;

operation:
        SELECT
    |   INSERT
    |   DELETE
    |   UPDATE opt_column_commalist
    |   REFERENCES opt_column_commalist
    ;


grantee_commalist:
        grantee
    |   grantee_commalist ',' grantee
    ;

grantee:
        PUBLIC
    |   user
    ;

    /* module language */
sql:        module_def
    ;

module_def:
        MODULE opt_module
        LANGUAGE lang
        AUTHORIZATION user
        opt_cursor_def_list
        procedure_def_list
    ;

opt_module:
        /* empty */
    |   module
    ;

lang:
        COBOL
    |   FORTRAN
    |   PASCAL
    |   PLI
    |   C
    |   ADA
    ;

opt_cursor_def_list:
        /* empty */
    |   cursor_def_list
    ;

cursor_def_list:
        cursor_def
    |   cursor_def_list cursor_def
    ;

cursor_def:
        DECLARE cursor CURSOR FOR query_exp opt_order_by_clause
    ;

opt_order_by_clause:
        /* empty */
    |   ORDER BY ordering_spec_commalist
    ;

ordering_spec_commalist:
        ordering_spec
    |   ordering_spec_commalist ',' ordering_spec
    ;

ordering_spec:
        INTNUM opt_asc_desc
    |   column_ref opt_asc_desc
    ;

opt_asc_desc:
        /* empty */
    |   ASC
    |   DESC
    ;

procedure_def_list:
        procedure_def
    |   procedure_def_list procedure_def
    ;

procedure_def:
        PROCEDURE procedure parameter_def_list ';'
        manipulative_statement_list
    ;

manipulative_statement_list:
        manipulative_statement
    |   manipulative_statement_list manipulative_statement
    ;

parameter_def_list:
        parameter_def
    |   parameter_def_list parameter_def
    ;

parameter_def:
        parameter data_type
    |   SQLCODE
    ;

    /* manipulative statements */

sql:        manipulative_statement
    ;

manipulative_statement:
        close_statement
    |   commit_statement
    |   delete_statement_positioned
    |   delete_statement_searched
    |   fetch_statement
    |   insert_statement
    |   open_statement
    |   rollback_statement
    |   select_statement
    |   update_statement_positioned
    |   update_statement_searched
    ;

close_statement:
        CLOSE cursor
    ;

commit_statement:
        COMMIT WORK
    ;

delete_statement_positioned:
        DELETE FROM table WHERE CURRENT OF cursor
    ;

delete_statement_searched:
        DELETE FROM table opt_where_clause
    ;

fetch_statement:
        FETCH cursor INTO target_commalist
    ;

insert_statement:
        INSERT INTO table opt_column_commalist values_or_query_spec
    ;

values_or_query_spec:
        VALUES '(' insert_atom_commalist ')'
    |   query_spec
    ;

insert_atom_commalist:
        insert_atom
    |   insert_atom_commalist ',' insert_atom
    ;

insert_atom:
        atom
    |   NULLX
    ;

open_statement:
        OPEN cursor
    ;

rollback_statement:
        ROLLBACK WORK
    ;

select_statement:
        SELECT opt_all_distinct selection
        INTO target_commalist
        table_exp
    |   SELECT opt_all_distinct selection
        table_exp
    ;

opt_all_distinct:
        /* empty */
    |   ALL
    |   DISTINCT
    ;

update_statement_positioned:
        UPDATE table SET assignment_commalist
        WHERE CURRENT OF cursor
    ;

assignment_commalist:
    |   assignment
    |   assignment_commalist ',' assignment
    ;

assignment:
        column '=' scalar_exp
    |   column '=' NULLX
    ;

update_statement_searched:
        UPDATE table SET assignment_commalist opt_where_clause
    ;

target_commalist:
        target
    |   target_commalist ',' target
    ;

target:
        parameter_ref
    ;

opt_where_clause:
        /* empty */
    |   where_clause
    ;

    /* query expressions */

query_exp:
        query_term
    |   query_exp UNION query_term
    |   query_exp UNION ALL query_term
    ;

query_term:
        query_spec
    |   '(' query_exp ')'
    ;

query_spec:
        SELECT opt_all_distinct selection table_exp
    ;

selection:
        scalar_exp_commalist
    |   '*'
    ;

table_exp:
        from_clause
        opt_where_clause
        opt_group_by_clause
        opt_having_clause
    ;

from_clause:
        FROM table_ref_commalist
    ;

table_ref_commalist:
        table_ref
    |   table_ref_commalist ',' table_ref
    ;

table_ref:
        table 
    |   table range_variable
    ;

where_clause:
        WHERE search_condition
    ;

opt_group_by_clause:
        /* empty */
    |   GROUP BY column_ref_commalist
    ;

column_ref_commalist:
        column_ref
    |   column_ref_commalist ',' column_ref
    ;

opt_having_clause:
        /* empty */
    |   HAVING search_condition
    ;

    /* search conditions */

search_condition:
    |   search_condition OR search_condition
    |   search_condition AND search_condition
    |   NOT search_condition
    |   '(' search_condition ')'
    |   predicate
    ;

predicate:
        comparison_predicate
    |   between_predicate
    |   like_predicate
    |   test_for_null
    |   in_predicate
    |   all_or_any_predicate
    |   existence_test
    ;

comparison_predicate:
        scalar_exp COMPARISON scalar_exp
    |   scalar_exp COMPARISON subquery
    ;

between_predicate:
        scalar_exp NOT BETWEEN scalar_exp AND scalar_exp
    |   scalar_exp BETWEEN scalar_exp AND scalar_exp
    ;

like_predicate:
        scalar_exp NOT LIKE atom opt_escape
    |   scalar_exp LIKE atom opt_escape
    ;

opt_escape:
        /* empty */
    |   ESCAPE atom
    ;

test_for_null:
        column_ref IS NOT NULLX
    |   column_ref IS NULLX
    ;

in_predicate:
        scalar_exp NOT IN '(' subquery ')'
    |   scalar_exp IN '(' subquery ')'
    |   scalar_exp NOT IN '(' atom_commalist ')'
    |   scalar_exp IN '(' atom_commalist ')'
    ;

atom_commalist:
        atom
    |   atom_commalist ',' atom
    ;

all_or_any_predicate:
        scalar_exp COMPARISON any_all_some subquery
    ;
            
any_all_some:
        ANY
    |   ALL
    |   SOME
    ;

existence_test:
        EXISTS subquery
    ;

subquery:
        '(' SELECT opt_all_distinct selection table_exp ')'
    ;

    /* scalar expressions */

scalar_exp:
        scalar_exp '+' scalar_exp
    |   scalar_exp '-' scalar_exp
    |   scalar_exp '*' scalar_exp
    |   scalar_exp '/' scalar_exp
    |   '+' scalar_exp %prec UMINUS
    |   '-' scalar_exp %prec UMINUS
    |   atom
    |   column_ref
    |   function_ref
    |   '(' scalar_exp ')'
    ;

scalar_exp_commalist:
        scalar_exp
    |   scalar_exp_commalist ',' scalar_exp
    ;

atom:
        parameter_ref
    |   literal
    |   USER
    ;

parameter_ref:
        parameter
    |   parameter parameter
    |   parameter INDICATOR parameter
    ;

function_ref:
        AMMSC '(' '*' ')'
    |   AMMSC '(' DISTINCT column_ref ')'
    |   AMMSC '(' ALL scalar_exp ')'
    |   AMMSC '(' scalar_exp ')'
    ;

literal:
        STRING
    |   INTNUM
    |   APPROXNUM
    ;

    /* miscellaneous */

table:
        NAME
    |   NAME '.' NAME
    ;

column_ref:
        NAME
    |   NAME '.' NAME   /* needs semantics */
    |   NAME '.' NAME '.' NAME
    ;

        /* data types */

data_type:
        CHARACTER
    |   CHARACTER '(' INTNUM ')'
    |   NUMERIC
    |   NUMERIC '(' INTNUM ')'
    |   NUMERIC '(' INTNUM ',' INTNUM ')'
    |   DECIMAL
    |   DECIMAL '(' INTNUM ')'
    |   DECIMAL '(' INTNUM ',' INTNUM ')'
    |   INTEGER
    |   SMALLINT
    |   FLOAT
    |   FLOAT '(' INTNUM ')'
    |   REAL
    |   DOUBLE PRECISION
    ;

    /* the various things you can name */

column:     NAME
    ;

cursor:     NAME
    ;

module:     NAME
    ;

parameter:
        ':' NAME
    ;

procedure:  NAME
    ;

range_variable: NAME
    ;

user:       NAME
    ;

    /* embedded condition things */
sql:        WHENEVER NOT FOUND when_action
    |   WHENEVER SQLERROR when_action
    ;

when_action:    GOTO NAME
    |   CONTINUE
    ;
%%

/* --------------------------------------------------------------------- */
/* Epilogue */
void init_table(void)
{
    /* do nothing */
}

int yylex (void)
{
    /* TODO should be integrated with flex al any lexer else */
    return 0;
}

void yyerror(const char *s)
{
    /* TODO should be integrated with flex al any lexer else */
    fprintf(stderr,"%s\n",s);
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
