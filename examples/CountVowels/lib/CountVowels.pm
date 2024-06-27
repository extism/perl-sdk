package CountVowels;
use 5.016;
use strict; use warnings;

use Wasm
  -api => 0,
  #-file => 'count_vowels.wasm'
  #-file => 'count_vowels_go/count_vowels_go.wasm'
  -file => 'count_vowels_go.wasm'
  ;

1;
