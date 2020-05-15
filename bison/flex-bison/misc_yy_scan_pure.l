%option nounput noinput noyywrap

%{
#include <misc_parser.h>
#include <misc_yy_gen.h>
/**
 * From bison doc:
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
#define YY_DECL int yylex(YYSTYPE *lvalp, YYLTYPE *llocp)
%}

FUNC_NAME       (atan|cos|exp|ln|sin|sqrt)
VAR_NAME	    ([[:alpha:]_][[:alnum:]_-]*)
ANY_OTHER       .|\n

%%
[ \t]           {   ;/* ignore all whitespace*/    }
[0-9]+\.[0-9]+ 	{   lvalp->DNUM = atof(yytext); return NUM; }
[0-9]+		    {   lvalp->DNUM = atof(yytext); return NUM; }
{FUNC_NAME}     {
                    symrec *s = getsym(yytext);
                    lvalp->FUNC_PTR = s;
                    return s->type;
                }
"+"             {   return (int)*yytext;    }
"-"             {   return (int)*yytext;    }
"*"             {   return (int)*yytext;    }
"/"             {   return (int)*yytext;    }
"("             {   return (int)*yytext;    }
")"             {   return (int)*yytext;    }
"="             {   return (int)*yytext;    }
"^"             {   return (int)*yytext;    }
{VAR_NAME}      {   
                    symrec *s = putsym(yytext,VAR);
                    return s->type;
                }
{ANY_OTHER}     {   return (int)*yytext;    }
%%
