
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
extern FILE *yyout;

typedef struct _savebuf{
    char save_buf[200];
    char *savebp;
    int len;
} savebuf;

savebuf buf;

void start_save(void) {
    memset(buf.save_buf, 0, sizeof(buf.save_buf));
    buf.len = 0;
    buf.savebp = buf.save_buf;
}

void yyerror(char *s) {
    buf.savebp--;
    buf.savebp = '\0';
    printf("yyerror %s at %s\n", s, buf.save_buf);
    start_save();
}

void save_str(char *str) {
    int len = strlen(str);
    strncpy(buf.savebp, str, len);
    buf.savebp +=len;
    buf.len += len;
    printf("save_str : %s | buf.save_buf : %s\n", str, buf.save_buf);
}

void end_sql(void) {
    buf.savebp--;
    buf.savebp = '\0'; //replace ';' to '\0'
    fprintf(yyout, "+OK %s\n", buf.save_buf);
    start_save();
}

void print_tag(char *s) {
    printf("test accept %s\n", s);
}