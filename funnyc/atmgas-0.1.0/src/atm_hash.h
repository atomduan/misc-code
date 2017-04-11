#ifndef _ATM_HASH_H_INCLUDED_
#define _ATM_HASH_H_INCLUDED_

#include "atm_config.h"
#include "atm_core.h"

typedef struct {
    atm_hash_entry_t **table;
    atm_ulong_t size;
    atm_uint_t (* hash_func)(atm_str_t *key);
    atm_uint_t (* key_compare)(atm_str_t *key1, atm_str_t *key2);
} atm_hash_t;

typedef struct {
    void *value;
    atm_str_t *key;
    atm_hash_entry_t *next;
} atm_hash_entry_t;

void atm_hash_init_siphash_seed();

atm_hash_t *atm_hash_init();
atm_int_t atm_hash_contains(atm_str_t *key);
atm_uint_t atm_hash_key_func(atm_str_t *key);
void *atm_hash_get(atm_hash_t *hash, atm_str_t *key);
void *atm_hash_set(atm_hash_t *hash, atm_str_t *key, atm_str_t *value);
atm_int_t atm_hash_remove(atm_hash_t *hash, atm_str_t *key);

uint64_t atm_siphash(uint8_t *in, size_t inlen, uint8_t *k);
#endif
