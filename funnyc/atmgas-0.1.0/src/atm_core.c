#include "atm_config.h"
#include "atm_core.h"

void *atm_malloc(size_t size) {
    void * ptr = NULL;
    ptr = malloc(size);
    return ptr;
}

void *atm_calloc(size_t nmemb, size_t size) {
    void * ptr = NULL;
    ptr = calloc(nmemb, size);
    return ptr;
}

void atm_free(void *ptr) {
    free(ptr);
}
