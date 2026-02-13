const std = @import("std");
const upb = @import("upb_zig");

pub fn main() !void {
    const arena = try upb.Arena.init(std.heap.page_allocator);
    defer arena.deinit();

    const mem = try arena.alloc(64);
    std.debug.print("upb_zig works! Allocated {} bytes from arena.\n", .{mem.len});
}
