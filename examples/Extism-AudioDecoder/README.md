# Pluggable Audio Decoder example

WASI-SDK is required and the enviornment variable `WASI_SDK_PATH` must point to it.

https://github.com/WebAssembly/wasi-sdk/releases

## Install Deps

`cpanm Extism Data::Printer`

## Build

`make`

## Run

`perl -Ilib demo.pl song.flac`

or

`perl -Ilib demo.pl song.wav`

If you have ffmpeg installed `ffplay` may be used to play the resulting extracted pcm audio

`ffplay -autoexit -ac 2 -f s16le song.wavorflac.pcm`

