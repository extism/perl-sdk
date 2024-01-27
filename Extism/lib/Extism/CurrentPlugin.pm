package Extism::CurrentPlugin;

use 5.006;
use strict;
use warnings;
use Extism::XS qw(current_plugin_memory
    current_plugin_memory_alloc
    current_plugin_memory_length
    current_plugin_memory_free);

our $VERSION = '0.01';

# These functions are only valid within a host function
# instance is set by Extism::Function::host_function_caller_perl, valid only for
# the host function.

sub memory {
    return current_plugin_memory($Extism::CurrentPlugin::instance);
}

sub memory_alloc {
    return current_plugin_memory_alloc($Extism::CurrentPlugin::instance);
}

sub memory_length {
    return current_plugin_memory_length($Extism::CurrentPlugin::instance);
}

sub memory_free {
    return current_plugin_memory_length($Extism::CurrentPlugin::instance);
}

1; # End of Extism::CurrentPlugin
