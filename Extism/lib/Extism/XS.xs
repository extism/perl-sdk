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
typedef uint64_t ExtismMemoryHandle;
typedef struct ExtismFunction ExtismFunction;
typedef struct ExtismPlugin ExtismPlugin;
typedef struct ExtismCurrentPlugin ExtismCurrentPlugin;

typedef enum {
  Extism_I32,
  Extism_I64,
  Extism_F32,
  Extism_F64,
  Extism_V128,
  Extism_FuncRef,
  Extism_ExternRef,
} ExtismValType;

typedef union {
  int32_t i32;
  int64_t i64;
  float f32;
  double f64;
} ExtismValUnion;

typedef struct {
  ExtismValType t;
  ExtismValUnion v;
} ExtismVal;

// perl relies on union being 8 bytes aligned
static_assert(sizeof(ExtismVal) == 16);

typedef void (*ExtismFunctionType)(ExtismCurrentPlugin *plugin,
                                   const ExtismVal *inputs,
                                   ExtismSize n_inputs,
                                   ExtismVal *outputs,
                                   ExtismSize n_outputs,
                                   void *data);

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

ExtismFunction *extism_function_new(const char *name,
                                    const ExtismValType *inputs,
                                    ExtismSize n_inputs,
                                    const ExtismValType *outputs,
                                    ExtismSize n_outputs,
                                    ExtismFunctionType func,
                                    void *user_data,
                                    void (*free_user_data)(void *_));

uint8_t *extism_current_plugin_memory(ExtismCurrentPlugin *plugin);

ExtismMemoryHandle extism_current_plugin_memory_alloc(ExtismCurrentPlugin *plugin, ExtismSize n);

ExtismSize extism_current_plugin_memory_length(ExtismCurrentPlugin *plugin, ExtismMemoryHandle n);

void extism_current_plugin_memory_free(ExtismCurrentPlugin *plugin, ExtismMemoryHandle ptr);

bool extism_log_file(const char *filename, const char *log_level);

static void host_function_caller (ExtismCurrentPlugin *plugin,
                                   const ExtismVal *inputs,
                                   ExtismSize n_inputs,
                                   ExtismVal *outputs,
                                   ExtismSize n_outputs,
                                   void *data) {
    dTHX;
    dSP;

	ENTER;
    SAVETMPS;

    PUSHMARK(SP);
    EXTEND(SP, 6);
    PUSHs(sv_2mortal(newSVuv((UV)plugin)));
    PUSHs(sv_2mortal(newSVuv((UV)inputs)));
    PUSHs(sv_2mortal(newSVuv(n_inputs)));
    PUSHs(sv_2mortal(newSVuv((UV)outputs)));
    PUSHs(sv_2mortal(newSVuv(n_outputs)));
    PUSHs(data);
    PUTBACK;

    call_pv("Extism::Function::host_function_caller_perl", G_DISCARD);

    FREETMPS;
    LEAVE;
}

static void host_function_caller_cleanup(void *data) {
    dTHX;
    sv_2mortal(data);
}

typedef const void * PV;

MODULE = Extism::XS		PACKAGE = Extism::XS

PROTOTYPES: DISABLE

TYPEMAP: <<HERE
ExtismPlugin * T_PTR
const uint8_t * T_PV
ExtismSize T_UV
const ExtismFunction ** T_PTR
ExtismFunction ** T_PTR
char ** T_PTR
int32_t T_IV
const void * T_PTR
ExtismFunction * T_PTR
const ExtismValType * T_PTR
ExtismCurrentPlugin * T_PTR
ExtismMemoryHandle T_UV
PV T_PV
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
        extism_log_file("/dev/stdout", "error");
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

ExtismFunction *
function_new(name, inputs, n_inputs, outputs, n_outputs, data)
    const char *name
    const ExtismValType *inputs
    ExtismSize n_inputs
    const ExtismValType *outputs
    ExtismSize n_outputs
    SV *data
    CODE:
        RETVAL = extism_function_new(name, inputs, n_inputs, outputs, n_outputs, &host_function_caller, SvREFCNT_inc(data), &host_function_caller_cleanup);
    OUTPUT:
        RETVAL

void *
current_plugin_memory(plugin)
    ExtismCurrentPlugin *plugin
    CODE:
        RETVAL = extism_current_plugin_memory(plugin);
    OUTPUT:
        RETVAL

ExtismMemoryHandle
current_plugin_memory_alloc(plugin, n)
    ExtismCurrentPlugin *plugin
    ExtismSize n
    CODE:
        RETVAL = extism_current_plugin_memory_alloc(plugin, n);
    OUTPUT:
        RETVAL

ExtismSize
current_plugin_memory_length(plugin, handle)
    ExtismCurrentPlugin *plugin
    ExtismMemoryHandle handle
    CODE:
        RETVAL = extism_current_plugin_memory_length(plugin, handle);
    OUTPUT:
        RETVAL


void
current_plugin_memory_free(plugin, handle)
    ExtismCurrentPlugin *plugin
    ExtismMemoryHandle handle
    CODE:
        extism_current_plugin_memory_free(plugin, handle);

void
CopyToPtr(src, dest, n)
    PV src
    void *dest
    size_t n
    CODE:
        Copy(src, dest, n, uint8_t);
