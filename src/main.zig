const std = @import("std");
const upb = @import("upb_zig");

pub fn main() !void {
    const arena = try upb.Arena.init(std.heap.page_allocator);
    defer arena.deinit();

    std.debug.print("Hello from minimal example.\n", .{});
}
