const std = @import("std");
const upb_zig_minimal_example = @import("upb_zig_minimal_example");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"asd"});
    try upb_zig_minimal_example.bufferedPrint();
}
