package Extism::XS;

use 5.006;
use strict;
use warnings;
use Exporter 'import';

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Extism::XS', $VERSION);

our @EXPORT_OK = qw(
    version
    plugin_new
    plugin_new_error_free
    plugin_call
    plugin_error
    plugin_output_length
    plugin_output_data
    plugin_free
    plugin_reset
    function_new
    current_plugin_memory
    current_plugin_memory_alloc
    current_plugin_memory_length
    current_plugin_memory_free
    CopyToPtr
);

our %EXPORT_TAGS;
$EXPORT_TAGS{all} = [@EXPORT_OK];

1; # End of Extism::XS
