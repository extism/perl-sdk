// #define EXTISM_IMPLEMENTATION
#include "extism-pdk.h"
#include <stdexcept>
#include <stdint.h>

int32_t EXTISM_EXPORTED_FUNCTION(do_unreachable)
{
    std::terminate();
    return -1;
}
