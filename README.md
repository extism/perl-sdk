# Extism perl-sdk

The Perl SDK for integrating the [Extism](https://extism.org) runtime. Add the `Extism` distribution into your Perl project to run Extism plugins.

Join the [Extism Discord](https://extism.org/discord) and chat with us!

## Building and Installation

This isn't on CPAN yet, so libextism and the Extism distribution must be installed manually:

[libextism](https://extism.org/docs/install)

Installation under [`local::lib`](https://metacpan.org/pod/local::lib#The-bootstrapping-technique) is recommended. 

```bash
make install
```

## Getting Started

Take a look at `Extism/script/demo-perl-extism` or the tests in `Extism/t`.

## Testing

To test and internet connection is required and you must have the [WASI SDK](https://github.com/WebAssembly/wasi-sdk?tab=readme-ov-file#quick-start) setup with `WASI_SDK_PATH` pointing to it.

`make test`

## TODO
* Add bindings for `extism_log_file` and any other missing functions
* Remove `extism_log_file` from XS
* Switch back to using official `extism.h`
* Create `Alien::Extism` distribution to automatically install libextism
* Build `dists` with github actions
* Release on CPAN
* More host function / plugin->call bindings
