# Spinel

High-Entropy Binary Section Map & Structural Diff Engine

A headless, fast binary section parser for ELF, Mach-O, and PE targets that calculates sliding-window Shannon entropy, detects packing/obfuscation signatures, and renders terminal Braille density maps.

## Architecture

- Shannon Entropy Engine: Calculates exact byte frequency tables and Shannon entropy over arbitrary windows, differentiating between sparse data, machine code, and encrypted/virtualized bytecode blocks.
- Format Identification: Inspects binary headers for ELF (magic \x7FELF), Mach-O (32-bit and 64-bit universal fat / single arch), and PE/COFF (MZ signature).
- Freestanding WebAssembly: Compiles to a 1.3 KB freestanding WASM artifact (`spinel.wasm`) for instant in-browser drag-and-drop entropy mapping.
- Visual Terminal Sparkline: Generates Unicode Braille representations directly to stdout for terminal inspection workflows.

## Exported WebAssembly API

```c
double spinel_calc_entropy(const uint8_t* ptr, size_t len);
uint32_t spinel_detect_format(const uint8_t* ptr, size_t len);
size_t spinel_sliding_window(
    const uint8_t* in_ptr,
    size_t in_len,
    size_t win_size,
    size_t step,
    double* out_ptr,
    size_t out_cap
);
```

## Building and Testing

```bash
# Run unit tests
zig build test

# Compile native binary and freestanding WASM
zig build -Doptimize=ReleaseFast
```

## License

MIT License - Copyright (c) 2026 Jeong Hoon Kim
