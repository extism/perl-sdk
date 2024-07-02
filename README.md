# Extism perl-sdk

The Perl SDK for integrating the [Extism](https://extism.org) runtime. Add the `Extism` distribution into your Perl project to run Extism plugins.

Join the [Extism Discord](https://extism.org/discord) and chat with us!

## Building and Installation

Installation under [`local::lib`](https://metacpan.org/pod/local::lib#The-bootstrapping-technique) is recommended. 

From CPAN: `cpanm Extism`

## Getting Started

Take a look at `Extism/script/demo-perl-extism` or the tests in `Extism/t`.

## Testing

To test and internet connection is required and you must have the [WASI SDK](https://github.com/WebAssembly/wasi-sdk?tab=readme-ov-file#quick-start) setup with `WASI_SDK_PATH` pointing to it.

`make test`

## Presentation

The Extism perl-sdk was featured at TPRC 2024: [Native deps a pain? WebAssembly can help!](https://www.youtube.com/watch?v=7THl2DSbZNc) Slides are in `docs/`.

## TODO
* More host function / plugin->call bindings
