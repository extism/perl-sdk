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
    plugin_reset
    );
use Data::Dumper qw(Dumper);
use Devel::Peek qw(Dump);
use JSON::PP qw(encode_json);
use Scalar::Util qw(reftype);
use version 0.77; our $VERSION = qv(v0.0.1);

sub new {
    my ($name, $wasm, $options) = @_;
    my $functions = [];
    my $with_wasi = 0;
    if ($options) {
        if (exists $options->{functions}) {
            $functions = $options->{functions};
        }
        if (exists $options->{wasi}) {
            $with_wasi = $options->{wasi};
        }
    }
    my $errptr = "\x00" x 8;
    my $errptrptr = unpack('Q', pack('P', $errptr));
    my @rawfunctions = map {$$_} @{$functions};
    my $functionsarray = pack('Q*', @rawfunctions);
    my $functionsptr = unpack('Q', pack('P', $functionsarray));
    my $plugin = plugin_new($wasm, length($wasm), $functionsptr, scalar(@rawfunctions), $with_wasi, $errptrptr);
    if (! $plugin) {
        my $errmsg = unpack('p', $errptr);
        print "error: $errmsg\n";
        plugin_new_error_free(unpack('Q', $errptr));
        return undef;
    }
    my $pluginobj = \$plugin;
    return bless $pluginobj, $name;
}

# call PLUGIN,FUNCNAME,INPUT
# call PLUGIN,FUNCNAME
# If INPUT is provided and is not a reference the contents of the scalar will be
# passed to the plugin. If INPUT is a reference, the referenced item will be
# encoded with json and then passed to the plugin.
sub call {
    my ($self, $func_name, $input) = @_;
    $input //= '';
    my $type = reftype($input);
    if ($type) {
        $input = $$input if($type eq 'SCALAR');
        $input = encode_json($input);
    }
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
