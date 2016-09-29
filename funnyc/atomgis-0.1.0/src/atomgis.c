/*
 * =====================================================================================
 *
 *       Filename:  atomgis.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  2016-08-18 14:57:11
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  juntaoduan ttys003  Aug 17 16:18  
 *   Organization:  
 *
 * =====================================================================================
 */
#include <stdlib.h>
#include <stdio.h>

#include "atomgis.h"

static bool begin_newline = true;

void print_one_line(char *str)
{
	bool line_tail = false; 
	char *sp = str;
	do {
		if (*sp == '\r') {
			line_tail = true;
			break;
		}
	} while (*sp++ != '\0');
	if (begin_newline)
		printf("LINE: %s", str);
	else
		printf("%s", str);

	begin_newline = line_tail ? true : false;
}

int main(int argc, char **argv) 
{
	FILE *fp;
	char *tmp, buffer[BUFFER_SIZE];
	fp = fopen("/etc/passwd", "r");
	while ((tmp=fgets(buffer,BUFFER_SIZE-1,fp)) != NULL) {
		print_one_line(tmp);
	}
	printf("hello atomgis\n");
	return 0;
}

