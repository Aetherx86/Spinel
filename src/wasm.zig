// Copyright (c) 2026 jk9576. All rights reserved.
// Spinel: High-Entropy Binary Section Map & Structural Diff Engine
// Licensed under the MIT License.

pub const entropy = @import("entropy.zig");

// WebAssembly exports
pub export fn spinel_calc_entropy(ptr: [*]const u8, len: usize) f64 {
    return entropy.calculateEntropy(ptr[0..len]);
}

pub export fn spinel_detect_format(ptr: [*]const u8, len: usize) u32 {
    return switch (entropy.detectFormat(ptr[0..len])) {
        .elf => 1,
        .macho => 2,
        .pe => 3,
        .raw => 0,
    };
}

pub export fn spinel_sliding_window(
    in_ptr: [*]const u8,
    in_len: usize,
    win_size: usize,
    step: usize,
    out_ptr: [*]f64,
    out_cap: usize,
) usize {
    return entropy.slidingWindowEntropy(in_ptr[0..in_len], win_size, step, out_ptr[0..out_cap]);
}
