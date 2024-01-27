Extism/host.wasm: host.c
	$(WASI_SDK_PATH)/bin/clang -o $@ $^ -mexec-model=reactor