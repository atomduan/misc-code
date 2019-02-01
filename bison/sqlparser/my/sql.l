%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

#define SV save_str(yytext)
#define TOK(name) { SV; return name; }

int lineno;
void yyerror(char *s);
%}

%%
ABS         TOK(RESERVED)
MIN         TOK(RESERVED)
MAX         TOK(RESERVED)
DISTINCT    TOK(DISTINCT)
SELECT      TOK(SELECT)
FROM        TOK(FROM)
WHERE       TOK(WHERE)
AND         TOK(AND)
OR          TOK(OR)
NOT         TOK(NOT)
IN          TOK(IN)
ALL         TOK(ALL)

"="  |
">"  |
"<"  |
">=" |
"<="        TOK(COMPARISON)

[-+*/:;(),.] TOK(yytext[0])

[a-zA-Z][a-zA-Z0-9_]* TOK(NAME)

[+-]?[1-9][0-9]* TOK(INTNUM)
([+-]?([1-9][0-9]*)?'.'[0-9]*) |
(([1-9][0-9]*)?[eE][+-]?([0-9][1-9]*)) TOK(APPROXNUM)

'[^'\n]*'   {
        int c = input();

        unput(c);   /* just peeking */
        if(c != '\'') {
            SV;
            return STRING;
        } else
            yymore();
}

        
'[^'\n]*$   { yyerror("Unterminated string"); }

\n      { save_str(" "); lineno++; }

[ \t\r]+   { save_str(" ");} ;   /* white space */

"--".*$     ;   /* comment */


%%

main(int ac, char **av)
{
    if(ac > 1 && (yyin = fopen(av[1], "r")) == NULL) {
        perror(av[1]);
        exit(1);
    }
    start_save();
    do {
        yyparse();
    } while(!feof(yyin));
} /* main */


