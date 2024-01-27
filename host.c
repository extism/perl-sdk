#define EXTISM_IMPLEMENTATION
#include "extism-pdk.h"
#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

EXTISM_IMPORT_USER("hello_void")
extern void hello_void(void);

int32_t EXTISM_EXPORTED_FUNCTION(call_hello_void)
{
    hello_void();
    return 0;
}

EXTISM_IMPORT_USER("hello_params")
extern uint64_t hello_params(double d, int32_t i, float f, int64_t i64);

int32_t EXTISM_EXPORTED_FUNCTION(call_hello_params)
{
    uint64_t from_host = hello_params(M_PI, 0xFFFFFFFF, M_PI, 0xFFFFFFFF);
    char buf[64];
    snprintf(buf, sizeof(buf), "from: host %llu\n", from_host);
    extism_log_sz(buf, ExtismLogError);
    return 0;
}