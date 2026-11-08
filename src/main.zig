// Copyright (c) 2026 jk9576. All rights reserved.
// Spinel: High-Entropy Binary Section Map & Structural Diff Engine
// Licensed under the MIT License.

const std = @import("std");
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

pub fn main() !void {
    // Sample payload: low entropy zeros + medium code + high entropy pseudo-random
    var buffer: [1024]u8 = undefined;
    @memset(buffer[0..256], 0); // Zero sparse data
    for (buffer[256..512], 0..) |*b, i| {
        b.* = @truncate(i % 16); // Patterned low-entropy data
    }
    var prng = std.Random.DefaultPrng.init(0x1337);
    prng.random().bytes(buffer[512..1024]); // High-entropy simulated encrypted payload

    const overall = entropy.calculateEntropy(&buffer);
    std.debug.print("Spinel: Analyzed 1024-byte payload. Overall Shannon Entropy: {d:.4} bits/byte\n", .{overall});
    std.debug.print("Format: {s}\n", .{@tagName(entropy.detectFormat(&buffer))});
}

test "Shannon entropy of zero buffer is 0.0" {
    var zeros: [256]u8 = undefined;
    @memset(&zeros, 0);
    const h = entropy.calculateEntropy(&zeros);
    try std.testing.expectApproxEqAbs(@as(f64, 0.0), h, 0.0001);
}

test "Shannon entropy of uniform distribution is 8.0" {
    var uniform: [256]u8 = undefined;
    for (&uniform, 0..) |*b, i| {
        b.* = @truncate(i);
    }
    const h = entropy.calculateEntropy(&uniform);
    try std.testing.expectApproxEqAbs(@as(f64, 8.0), h, 0.0001);
}

test "Format detection identifies ELF, Mach-O, and PE" {
    try std.testing.expectEqual(entropy.BinaryFormat.elf, entropy.detectFormat("\x7FELF\x02\x01\x01\x00"));
    try std.testing.expectEqual(entropy.BinaryFormat.pe, entropy.detectFormat("MZ\x90\x00\x03\x00\x00\x00"));
}

test "Sliding window entropy calculates windows correctly" {
    var data: [256]u8 = undefined;
    @memset(data[0..128], 0);
    @memset(data[128..256], 0xFF);
    var out: [16]f64 = undefined;
    const written = entropy.slidingWindowEntropy(&data, 64, 32, &out);
    try std.testing.expect(written > 0);
}
