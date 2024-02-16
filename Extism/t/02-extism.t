#!perl
use 5.006;
use strict;
use warnings;
use Test::More;
use Extism ':all';
use JSON::PP qw(encode_json decode_json);
use Devel::Peek qw(Dump);
plan tests => 23;

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

my $count_vowels_kv = encode_json({
    wasm => [
        {
            url => "https://github.com/extism/plugins/releases/latest/download/count_vowels_kvstore.wasm"
        }
    ],
});

my @lowlevel;
{
    my %kv_store;
    my $kv_read = Extism::Function->new("kv_read", [Extism_I64], [Extism_I64], sub {
        my ($key_ptr) = @_;
        my $key = Extism::CurrentPlugin::memory_load_from_handle($key_ptr);
        if (!exists $kv_store{$key}) {
            return Extism::CurrentPlugin::memory_alloc_and_store("\x00" x 4);
        } else {
            return Extism::CurrentPlugin::memory_alloc_and_store($kv_store{$key});
        }
    });
    ok($kv_read);
    my $kv_write = Extism::Function->new("kv_write", [Extism_I64, Extism_I64], [], sub {
        my ($key_ptr, $value_ptr) = @_;
        my $key = Extism::CurrentPlugin::memory_load_from_handle($key_ptr);
        my $value = Extism::CurrentPlugin::memory_load_from_handle($value_ptr);
        $kv_store{$key} = $value;
        return;
    });
    ok($kv_write);
    my $fplugin = Extism::Plugin->new($count_vowels_kv, {functions => [$kv_read, $kv_write], wasi => 1});
    ok($fplugin);
    my $hello = "Hello, World!";
    $lowlevel[0] = $fplugin->call("count_vowels", $hello);
    $lowlevel[1] = $fplugin->call("count_vowels", $hello);
}

my @highlevel;
{
    my %kv_store;
    my $kv_read = Extism::Function->new("kv_read", [Extism_String], [Extism_String], sub {
        my ($key) = @_;
        if (!exists $kv_store{$key}) {
            return "\x00" x 4;
        } else {
            return $kv_store{$key};
        }
    });
    ok($kv_read);
    my $kv_write = Extism::Function->new("kv_write", [Extism_String, Extism_String], [], sub {
        my ($key, $value) = @_;
        $kv_store{$key} = $value;
        return;
    });
    ok($kv_write);
    my $fplugin = Extism::Plugin->new($count_vowels_kv, {functions => [$kv_read, $kv_write], wasi => 1});
    ok($fplugin);
    my $hello = "Hello, World!";
    $highlevel[0] = $fplugin->call("count_vowels", $hello);
    $highlevel[1] = $fplugin->call("count_vowels", $hello);
}
my @decoded = map {decode_json $_} @highlevel;
ok($decoded[0]{count} == $decoded[1]{count} == 3);
ok($decoded[0]{total} == 3);
ok($decoded[1]{total} == 6);
is($highlevel[0], $lowlevel[0]);
is($highlevel[1], $lowlevel[1]);
