package Extism::Function;

use 5.006;
use strict;
use warnings;
use Extism::XS qw(
    function_new CopyToPtr);
use Extism::CurrentPlugin;
use Devel::Peek qw(Dump);
use Exporter 'import';
use Carp qw(croak);
use Data::Dumper;

our $VERSION = '0.01';


use constant {
  Extism_I32 => 0,
  Extism_I64 => 1,
  Extism_F32 => 2,
  Extism_F64 => 3,
  Extism_V128 => 4,
  Extism_FuncRef => 5,
  Extism_ExternRef => 6,
};

our @EXPORT_OK = qw(
  Extism_I32
  Extism_I64
  Extism_F32
  Extism_F64
  Extism_V128
  Extism_FuncRef
  Extism_ExternRef
);

our %EXPORT_TAGS;
$EXPORT_TAGS{all} = [@EXPORT_OK];

# [PTR_LENGTH, PTR_PAIR, SZ, JSON_PTR_LENGTH, JSON_PTR_PAIR, JSON_SZ, U8ARRAY_PTR_LENGTH, U8ARRAY_]

sub new {
    my ($class, $name, $input_types, $output_types, $func) = @_;
    my %hostdata = (func => $func);
    my $input_types_array = pack('L*', @{$input_types});
    my $input_types_ptr = unpack('Q', pack('P', $input_types_array));
    my $output_types_array = pack('L*', @{$output_types});
    my $output_types_ptr = unpack('Q', pack('P', $output_types_array));
    my $function = function_new($name, $input_types_ptr, scalar(@{$input_types}), $output_types_ptr, scalar(@{$output_types}), \%hostdata);
    bless \$function, $class
}

sub load_raw_array {
  my ($ptr, $elm_size, $n) = @_;
  my $input_array = unpack('P'.($elm_size * $n), pack('Q', $ptr));
  my @input_packed = unpack("(a$elm_size)*", $input_array);
  return \@input_packed;
}

sub host_function_caller_perl {
    my ($current_plugin, $input_ptr, $input_len, $output_ptr, $output_len, $user_data) = @_;
    print Dumper(\@_);
    local $Extism::CurrentPlugin::instance = $current_plugin;
    my $input_packed = \@{load_raw_array($input_ptr, 16, $input_len)};
    my @input = map {
      my $type = unpack('L', $_);
      my $value = substr($_, 8);
      if ($type == Extism_I32) {
        $value = unpack('l', $value);
      } elsif($type == Extism_I64) {
        $value = unpack('q', $value);
      } elsif($type == Extism_F32) {
        $value = unpack('f', $value);
      } elsif($type == Extism_F64) {
        $value = unpack('F', $value);
      }
      $value
    } @{$input_packed};
    my @outputs = $user_data->{func}(@input);
    scalar(@outputs) <= $output_len or croak "host function returned too many outputs";
    my $outputs_packed = load_raw_array($output_ptr, 16, $output_len);
    my @output_types = map { unpack('L', $_) } @{$outputs_packed};
    my $output_array = unpack('P'.(16 * $output_len), pack('Q', $output_ptr));
    my $outputi = 0;
    foreach my $type (@output_types) {
      my $value;
      if ($type == Extism_I32) {
        $value = pack('l', $outputs[$outputi]);
      } elsif($type == Extism_I64) {
        $value = pack('q', $outputs[$outputi]);
      } elsif($type == Extism_F32) {
        $value = pack('f', $outputs[$outputi]);
      } elsif($type == Extism_F64) {
        $value = pack('F', $outputs[$outputi]);
      } else {
        $value =  "\x00" x 8;
      }
      substr($output_array, 16*$outputi+8, 8, $value);
    }
    CopyToPtr($output_array, $output_ptr, length($output_array));
}

1; # End of Extism::Function
