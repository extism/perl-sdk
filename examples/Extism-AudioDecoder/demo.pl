#!/usr/bin/perl
use 5.010;
use strict; use warnings;
use feature 'say';
use Data::Printer;
use Extism::AudioDecoder;

my $input_audio = $ARGV[0] // die "no input audio provided";
my $plugins = ['flac_decoder.wasm', 'wav_decoder.wasm'];
my $decoder = Extism::AudioDecoder->new($input_audio, $plugins);
$decoder or die "Failed to open decoder";
my $metadata = $decoder->get_metadata() or die "Failed to load metadata";
say "metadata:";
p $metadata;
my $pcm = $decoder->decode() // die "Failed to decode";
open(my $fh, '>', "$input_audio.pcm") or die "Failed to open out.pcm";
print $fh $pcm;
