package main

// #include <stdlib.h>
import "C"

import (
	"fmt"
	"unsafe"

	pdk "github.com/extism/go-pdk"
)

func is_vowel(input byte) uint {
	switch input {
	case 'a':
	case 'e':
	case 'i':
	case 'o':
	case 'u':
	default:
		return 0
	}
	return 1
}

func count_vowels(input string) string {
	var count uint = 0
	for i := 0; i < len(input); i++ {
		count += is_vowel(input[i])
	}
	return fmt.Sprintf("%d", count)
}

//export count_vowels
func _count_vowels() int32 {
	input := pdk.Input()
	inputString := string(input)
	outputString := count_vowels(inputString)
	output := []byte(outputString)
	pdk.Output(output)
	return 0
}

// ptrToString returns a string from WebAssembly compatible numeric types
// representing its pointer and length.
func ptrToString(ptr uint32, size uint32) string {
	return unsafe.String((*byte)(unsafe.Pointer(uintptr(ptr))), size)
}

// stringToPtr returns a pointer and size pair for the given string in a way
// compatible with WebAssembly numeric types.
// The returned pointer aliases the string hence the string must be kept alive
// until ptr is no longer needed.
func stringToPtr(s string) (uint32, uint32) {
	ptr := unsafe.Pointer(unsafe.StringData(s))
	return uint32(uintptr(ptr)), uint32(len(s))
}

// stringToLeakedPtr returns a pointer and size pair for the given string in a way
// compatible with WebAssembly numeric types.
// The pointer is not automatically managed by TinyGo hence it must be freed by the host.
func stringToLeakedPtr(s string) (uint32, uint32) {
	size := C.ulong(len(s))
	ptr := unsafe.Pointer(C.malloc(size))
	copy(unsafe.Slice((*byte)(ptr), size), s)
	return uint32(uintptr(ptr)), uint32(size)
}

func main() {}
