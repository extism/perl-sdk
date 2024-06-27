# CountVowels with and without Extism

tinygo is required to build.

## Install Deps

`cpanm Extism PeekPoke::FFI Wasm`

## Build

`make`

## Run

```
perl -Ilib count_vowels.pl
```

It should output

```
input hello
output 2
input hello
extism output 2
```

