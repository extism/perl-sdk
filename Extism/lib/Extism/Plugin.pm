package Extism::Plugin;

use 5.006;
use strict;
use warnings;
use Extism::XS qw(
    plugin_new
    plugin_new_error_free
    plugin_call plugin_error
    plugin_output_length
    plugin_output_data
    plugin_free
    plugin_reset);
use Data::Dumper qw(Dumper);
our $VERSION = '0.01';

sub new {
    my ($name, $wasm, $with_wasi) = @_;
    my $errptr = "\x00" x 8;
    my $errptrptr = unpack('Q', pack('P', $errptr));
    my $plugin = plugin_new($wasm, length($wasm), 0, 0, $with_wasi, $errptrptr);
    if (! $plugin) {
        my $errmsg = unpack('p', $errptr);
        print "error: $errmsg\n";
        plugin_new_error_free(unpack('Q', $errptr));
        return undef
    }
    bless \$plugin, $name
}

sub call {
    my ($self, $func_name, $input) = @_;
    my $rc = plugin_call($$self, $func_name, $input, length($input));
    if ($rc != 0) {
        print "error: " . plugin_error($$self) . "\n";
        return undef;
    }
    my $output_size = plugin_output_length($$self);
    my $output_ptr = plugin_output_data($$self);
    my $output = unpack('P'.$output_size, pack('Q', plugin_output_data($$self)));
    return $output;
}

sub reset {
    my ($self) = @_;
    return plugin_reset($$self);
}

sub DESTROY {
    my ($self) = @_;
    $$self or return;
    plugin_free($$self);
}

1; # End of Extism::Plugin
