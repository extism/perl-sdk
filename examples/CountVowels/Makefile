
.PHONY: all clean
all: count_vowels_go.wasm count_vowels_extism_go.wasm

count_vowels_go.wasm: main.go
	tinygo build -o count_vowels_go.wasm -target=wasi main.go

count_vowels_extism_go.wasm: extism_go/main.go
	cd extism_go && tinygo build -o ../count_vowels_extism_go.wasm -target=wasi main.go

clean:
	rm *.wasm
