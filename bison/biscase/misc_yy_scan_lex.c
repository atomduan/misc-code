#include <misc_parser.h>
#include <misc_yy_gen.h>

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
int yylex(void)
{
    int c;
    /* Ignore white space, get first nonwhite character. */
    while ((c=getchar())==' ' || c=='\t')
        continue;
    if (c == EOF) return 0;
    /* Char starts a number => parse the number. */
    if (c == '.' || isdigit(c)) {
        ungetc(c, stdin);
        scanf("%lf", &yylval.DNUM);
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

