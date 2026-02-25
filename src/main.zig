const std = @import("std");
const upb_runtime = @import("upb_runtime");

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}

test "simple test" {
    const arena = try upb_runtime.upb_zig.Arena.init(std.heap.page_allocator);
    defer arena.deinit();
    var ts = try upb_runtime.wkt.timestamp_pb.Timestamp.init(arena);
    ts.setNanos(23);
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
