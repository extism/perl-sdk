#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Extism ':all';
use JSON::PP;
use Devel::Peek qw(Dump);
plan tests => 12;

ok(Extism::version());

my $notplugin = Extism::Plugin->new('');
ok(!defined $notplugin);

my $wasm = do { local(@ARGV, $/) = 'count_vowels.wasm'; <> };
my $plugin = Extism::Plugin->new($wasm, {wasi => 1});
ok($plugin);
my $output = $plugin->call('count_vowels', "this is a test");
ok($output);
my $outputhash = decode_json($output);
ok($outputhash->{count} == 4);
ok($plugin->reset());

my $failwasm = do { local(@ARGV, $/) = 'fail.wasm'; <> };
my $failplugin = Extism::Plugin->new($failwasm, {wasi => 1});
my $failed = $failplugin->call('run_test', "");
ok(!$failed);

my $voidfunction = Extism::Function->new("hello_void", [], [], sub {
    print "hello_void\n";
    return;
});
ok($voidfunction);
my $paramsfunction = Extism::Function->new("hello_params", [Extism_F64, Extism_I32, Extism_F32, Extism_I64], [Extism_I64], sub {
    print "hello_params: ".join(' ', @_) . "\n";
    return 18446744073709551615;
});
ok($paramsfunction);
my $hostwasm = do { local(@ARGV, $/) = 'host.wasm'; <> };
my $fplugin = Extism::Plugin->new($hostwasm, {functions => [$voidfunction, $paramsfunction], wasi => 1});
ok($fplugin);
ok(defined $fplugin->call('call_hello_void'));
ok(defined $fplugin->call('call_hello_params'));
