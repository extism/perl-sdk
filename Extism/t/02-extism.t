#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Extism;
use JSON::PP;
plan tests => 7;

ok(Extism::version());
my $notplugin = Extism::Plugin->new('', 1);
ok(!defined $notplugin);
my $wasm = do { local(@ARGV, $/) = 'count_vowels.wasm'; <> };
my $plugin = Extism::Plugin->new($wasm, 1);
ok($plugin);
my $output = $plugin->call('count_vowels', "this is a test");
ok($output);
my $outputhash = decode_json($output);
ok($outputhash->{count} == 4);
ok($plugin->reset());
my $failwasm = do { local(@ARGV, $/) = 'fail.wasm'; <> };
my $failplugin = Extism::Plugin->new($failwasm, 1);
my $failed = $failplugin->call('run_test', "");
ok(!$failed);
