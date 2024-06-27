use 5.016;
use strict; use warnings;

use CountVowels;
use PeekPoke::FFI qw( poke );
use feature 'say';
use Extism;

sub store_string {
    my ($dest, $src) = @_;
    foreach my $i (0..length($src)-1) {
        poke($dest + $i, ord substr($src, $i, 1));
    }
}

sub load_string {
    my ($ptr, $len) = @_;
    unpack("P$len", pack('Q', $ptr))
}

my $input = "hello";
say "input $input";
my $inptr = CountVowels::malloc(4);
store_string($CountVowels::memory->address + $inptr, $input);
my $outptrsize = CountVowels::count_vowels($inptr, length($input));
my $outsize = $outptrsize & 0xFFFFFFFF;
my $outptr = $outptrsize >> 32;
my $output = load_string($CountVowels::memory->address + $outptr, $outsize);
say "output $output";

my $wasm = do { local(@ARGV, $/) = 'count_vowels_extism_go.wasm'; <> };
my $plugin = Extism::Plugin->new($wasm, {wasi => 1});
say "input $input";
my $out = $plugin->call('count_vowels', $input);
say "extism output $out";
