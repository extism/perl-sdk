
.PHONY: all clean
all: flac_decoder.wasm wav_decoder.wasm

flac_decoder.wasm: flac_decoder.c dr_flac.h extism-pdk.h
	$(WASI_SDK_PATH)/bin/clang \
	-o flac_decoder.wasm flac_decoder.c \
	-mexec-model=reactor

wav_decoder.wasm: wav_decoder.c dr_wav.h extism-pdk.h
	$(WASI_SDK_PATH)/bin/clang \
	-o wav_decoder.wasm wav_decoder.c \
	-mexec-model=reactor

clean:
	rm *.wasm

