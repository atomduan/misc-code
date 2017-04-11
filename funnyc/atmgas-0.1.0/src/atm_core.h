#ifndef _ATM_CORE_H_INCLUDED_
#define _ATM_CORE_H_INCLUDED_

#include <stdlib.h>
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "atm_config.h"

void *atm_malloc(size_t size);
void *atm_calloc(size_t nmemb, size_t size);
void atm_free(void *ptr);

#endif
