.PHONY: all
all: Extism Extism/host.wasm

Extism/host.wasm: host.c
	$(WASI_SDK_PATH)/bin/clang -o $@ $^ -mexec-model=reactor

Extism/Makefile: Extism/Makefile.PL
	cd Extism && perl Makefile.PL
.PHONY: Extism
Extism: Extism/Makefile
	$(MAKE) -C Extism

.PHONY: test
test: Extism/Makefile Extism/host.wasm
	$(MAKE) -C Extism test

.PHONY: install
install: Extism/Makefile
	$(MAKE) -C Extism install

.PHONY: unsafedists
unsafedists: Extism/Makefile Extism/host.wasm
	$(MAKE) -C Extism manifest && $(MAKE) -C Extism distcheck && $(MAKE) -C Extism dist

.PHONY: dists
dists: clean
	$(MAKE) unsafedists

.PHONY: clean
clean: Extism/Makefile
	$(MAKE) -C Extism veryclean
	rm -f Extism/host.wasm
	rm -f Extism/MANIFEST
	rm -f Extism/MANIFEST.bak
