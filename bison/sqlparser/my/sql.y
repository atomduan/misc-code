%{
#include <stdio.h>
%}

%union {
    int intval;
    double floatval;
    char *strval;
    int subtok;
}

%token NAME
%token INTNUM APPROXNUM
%token STRING

%left OR
%left AND
%left NOT
%left <subtok> COMPARISON
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%token RESERVED COMPARISON
%token DISTINCT ALL
%token SELECT WHERE FROM 
%token IN AND OR NOT BETWEEN

%% 

sql_list:
        sql ';' { printf("abc\n"); end_sql(); }
    |   sql_list sql ';' { end_sql(); }
    ;

sql: 
        select_statement
    ;

select_statement:
        SELECT opt_distinct_all selection table_exp
    ;

opt_distinct_all:
    /* empty */
    |   DISTINCT
    |   ALL
    ;

selection:
        column_command_list
    |   '*'
    ;

column_command_list:
        column_ref
    |   column_command_list ',' column_ref
    ;

column_ref:
        NAME
    |   NAME '.' NAME
    ;

table_exp:
        FROM table_command_list opt_where
    ;

table_command_list:
        table
    |   table_command_list ',' table
    ;

table:
        NAME
    |   NAME '.' NAME
;

opt_where:
    /* empty */
    |   WHERE search_condition
    ;

search_condition:
        search_condition AND search_condition
    |   search_condition OR search_condition
    |   NOT search_condition
    |   '(' search_condition ')'  
    |   predicate
    ;

predicate:
        comparison_predicate
    |   in_predicate
    |   between_predicate
    ;

comparison_predicate:
        atom_exp COMPARISON atom_exp
    |   atom_exp COMPARISON subquery
    ;

in_predicate:
        atom_exp IN subquery
        atom_exp IN '(' atom_exp_list ')'
        atom_exp NOT IN subquery
        atom_exp NOT IN '(' atom_exp_list ')'
    ;

between_predicate:
        BETWEEN atom_exp AND atom_exp
        NOT BETWEEN atom_exp AND atom_exp
    ;

atom_exp_list:
        atom_exp
    |   atom_exp_list ',' atom_exp
    ;

atom_exp:
        atom_exp '+' atom_exp
    |   atom_exp '-' atom_exp
    |   atom_exp '*' atom_exp 
    |   atom_exp '/' atom_exp
    |   '+' atom_exp %prec UMINUS
    |   '-' atom_exp %prec UMINUS
    |   column_ref
    |   literal
    |   function_ref
    ;

literal:
        STRING
    |   INTNUM
    |   APPROXNUM
    ;

function_ref:
        RESERVED '(' atom_exp ')'
    ;

subquery:
        '(' select_statement ')'
    ; 

%%
