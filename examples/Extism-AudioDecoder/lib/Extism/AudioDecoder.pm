package Extism::AudioDecoder;
use 5.010;
use strict;
use warnings;
use Carp;
use Extism;
use feature 'say';
use JSON::PP;

sub new {
    my ($name, $filename, $plugins) = @_;
    my $audiodata = do { local(@ARGV, $/) = $filename; <> };
    foreach my $plugin (@$plugins) {
        say "trying plugin $plugin";
        my $wasm = do { local(@ARGV, $/) = $plugin; <> };
        my ($extism, $errmsg) = Extism::Plugin->new($wasm, {wasi => 1});
        $extism or croak $errmsg;
        my $decoder = $extism->call('open_memory', $audiodata) or next;
        return bless {'plugin' => $extism, 'decoder' => $decoder}, $name;
    }
    undef;
}

sub get_metadata {
    my ($self) = @_;
    my $metajson = $self->{plugin}->call('get_metadata', $self->{decoder});
    $metajson or die "Failed to retrieve metadata";
    decode_json($metajson);
}

sub decode {
    my ($self) = @_;
    $self->{plugin}->call('decode', $self->{decoder});
}

1;