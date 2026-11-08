// Copyright (c) 2026 jk9576. All rights reserved.
// Spinel: High-Entropy Binary Section Map & Structural Diff Engine
// Licensed under the MIT License.

const std = @import("std");

pub const BinaryFormat = enum {
    elf,
    macho,
    pe,
    raw,
};

pub const SectionInfo = struct {
    name: []const u8,
    offset: u64,
    size: u64,
    entropy: f64,
    is_packed: bool,
};

pub fn detectFormat(data: []const u8) BinaryFormat {
    if (data.len >= 4) {
        if (std.mem.eql(u8, data[0..4], "\x7FELF")) return .elf;
        const magic = std.mem.readInt(u32, data[0..4], .little);
        if (magic == 0xFEEDFACE or magic == 0xFEEDFACF or magic == 0xCEFAEDFE or magic == 0xCFFAEDFE) {
            return .macho;
        }
    }
    if (data.len >= 2 and data[0] == 'M' and data[1] == 'Z') {
        return .pe;
    }
    return .raw;
}

/// Computes Shannon entropy over a byte slice. Value range is [0.0, 8.0].
pub fn calculateEntropy(data: []const u8) f64 {
    if (data.len == 0) return 0.0;

    var counts: [256]u64 = undefined;
    @memset(&counts, 0);
    for (data) |b| {
        counts[b] += 1;
    }

    const total: f64 = @floatFromInt(data.len);
    var entropy: f64 = 0.0;

    for (counts) |c| {
        if (c > 0) {
            const p: f64 = @as(f64, @floatFromInt(c)) / total;
            entropy -= p * @log2(p);
        }
    }

    return entropy;
}

/// Computes sliding-window Shannon entropy array.
pub fn slidingWindowEntropy(data: []const u8, window_size: usize, step_size: usize, out: []f64) usize {
    if (data.len < window_size or out.len == 0) return 0;
    var written: usize = 0;
    var offset: usize = 0;

    while (offset + window_size <= data.len and written < out.len) : (offset += step_size) {
        out[written] = calculateEntropy(data[offset .. offset + window_size]);
        written += 1;
    }

    return written;
}

/// Converts an entropy value [0.0, 8.0] into a Braille bar character.
pub fn entropyToBraille(entropy: f64) []const u8 {
    if (entropy < 1.0) return " ";
    if (entropy < 2.5) return "⣀";
    if (entropy < 4.0) return "⣤";
    if (entropy < 5.5) return "⣶";
    if (entropy < 7.2) return "⣿";
    return "█"; // High-entropy encrypted/packed marker
}

/// Renders a Braille sparkline representation of the entropy buffer into a slice.
pub fn renderBrailleSparkline(entropy_vals: []const f64, writer: anytype) !void {
    for (entropy_vals) |val| {
        try writer.print("{s}", .{entropyToBraille(val)});
    }
}
