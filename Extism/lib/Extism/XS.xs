#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include <stdint.h>
#include <stdbool.h>
//#include <extism.h>

const char *extism_version(void);

typedef uint64_t ExtismSize;
typedef struct ExtismFunction ExtismFunction;
typedef struct ExtismPlugin ExtismPlugin;

static_assert(sizeof(UV) >= sizeof(ExtismSize));

ExtismPlugin *extism_plugin_new(const uint8_t *wasm,
                                ExtismSize wasm_size,
                                const ExtismFunction **functions,
                                ExtismSize n_functions,
                                bool with_wasi,
                                char **errmsg);

void extism_plugin_new_error_free(char *err);

int32_t extism_plugin_call(ExtismPlugin *plugin,
                           const char *func_name,
                           const uint8_t *data,
                           ExtismSize data_len);

const char *extism_plugin_error(ExtismPlugin *plugin);

ExtismSize extism_plugin_output_length(ExtismPlugin *plugin);

const uint8_t *extism_plugin_output_data(ExtismPlugin *plugin);

void extism_plugin_free(ExtismPlugin *plugin);

bool extism_plugin_reset(ExtismPlugin *plugin);

MODULE = Extism::XS		PACKAGE = Extism::XS

PROTOTYPES: DISABLE

TYPEMAP: <<HERE
ExtismPlugin * T_PTR
const uint8_t * T_PV
ExtismSize T_UV
const ExtismFunction ** T_PTR
char ** T_PTR
int32_t T_IV
const void * T_PTR
HERE

const char *
version()
    CODE:
        RETVAL = extism_version();
    OUTPUT:
        RETVAL

ExtismPlugin *
plugin_new(wasm, wasm_size, functions, n_functions, with_wasi, errmsg)
    const uint8_t *wasm
    ExtismSize wasm_size
    const ExtismFunction **functions
    ExtismSize n_functions
    bool with_wasi
    char **errmsg
    CODE:
        RETVAL = extism_plugin_new(wasm, wasm_size, functions, n_functions, with_wasi, errmsg);
    OUTPUT:
        RETVAL

void
plugin_new_error_free(err);
    void *err
    CODE:
        extism_plugin_new_error_free(err);

int32_t
plugin_call(plugin, func_name, data, data_len)
    ExtismPlugin *plugin
    const char *func_name
    const uint8_t *data
    ExtismSize data_len
    CODE:
        RETVAL = extism_plugin_call(plugin, func_name, data, data_len);
    OUTPUT:
        RETVAL

const char *
plugin_error(plugin)
    ExtismPlugin *plugin
    CODE:
        RETVAL = extism_plugin_error(plugin);
    OUTPUT:
        RETVAL

ExtismSize
plugin_output_length(plugin)
    ExtismPlugin *plugin
    CODE:
        RETVAL = extism_plugin_output_length(plugin);
    OUTPUT:
        RETVAL

const void *
plugin_output_data(plugin)
    ExtismPlugin *plugin
    CODE:
        RETVAL = extism_plugin_output_data(plugin);
    OUTPUT:
        RETVAL

void
plugin_free(plugin)
    ExtismPlugin *plugin
    CODE:
        extism_plugin_free(plugin);

bool
plugin_reset(plugin)
    ExtismPlugin *plugin
    CODE:
        RETVAL = extism_plugin_reset(plugin);
    OUTPUT:
        RETVAL
