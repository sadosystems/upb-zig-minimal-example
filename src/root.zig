//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "Basic Protobuf functionality" {
    // todo add some basic protobuf functionality
    try std.testing.expect(add(3, 7) == 10);
}
