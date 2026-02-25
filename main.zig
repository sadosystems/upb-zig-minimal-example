const std = @import("std");
const upb = @import("upb_runtime");
const example_pb = @import("example_pb");

pub fn main() !void {
    const arena = try upb.upb_zig.Arena.init(std.heap.page_allocator);
    defer arena.deinit();

    var person = try example_pb.Person.init(arena);
    person.setName("John");
    person.setId(42);
    person.setEmail("john@example.com");


    std.debug.print("Person: name={s}, id={d}, email={s}\n", .{
        person.getName(),
        person.getId(),
        person.getEmail(),
    });
}

test "Person: create and set scalar fields" {
    const arena = try upb.upb_zig.Arena.init(std.testing.allocator);
    defer arena.deinit();

    var person = try example_pb.Person.init(arena);
    person.setName("Bob");
    person.setId(123);
    person.setEmail("bob@test.com");

    try std.testing.expectEqualStrings("Bob", person.getName());
    try std.testing.expectEqual(@as(i32, 123), person.getId());
    try std.testing.expectEqualStrings("bob@test.com", person.getEmail());
}

test "Person: wire format encode/decode round-trip" {
    const arena = try upb.upb_zig.Arena.init(std.testing.allocator);
    defer arena.deinit();

    var person = try example_pb.Person.init(arena);
    person.setName("Charlie");
    person.setId(99);
    person.setEmail("charlie@test.com");

    const wire = try person.encode();
    try std.testing.expect(wire.len > 0);

    const decoded = try example_pb.Person.decode(arena, wire);
    try std.testing.expectEqualStrings("Charlie", decoded.getName());
    try std.testing.expectEqual(@as(i32, 99), decoded.getId());
    try std.testing.expectEqualStrings("charlie@test.com", decoded.getEmail());
}

test "Person: JSON encode/decode round-trip" {
    const arena = try upb.upb_zig.Arena.init(std.testing.allocator);
    defer arena.deinit();

    var person = try example_pb.Person.init(arena);
    person.setName("Diana");
    person.setId(7);

    const json = try person.encodeJson(.{ .emit_defaults = true });
    try std.testing.expect(json.len > 0);

    const decoded = try example_pb.Person.decodeJson(arena, json, .{});
    try std.testing.expectEqualStrings("Diana", decoded.getName());
    try std.testing.expectEqual(@as(i32, 7), decoded.getId());
}

test "AddressBook: repeated Person field" {
    const arena = try upb.upb_zig.Arena.init(std.testing.allocator);
    defer arena.deinit();

    var book = try example_pb.AddressBook.init(arena);

    var alice = try example_pb.Person.init(arena);
    alice.setName("Alice");
    alice.setId(1);
    try book.addPeople(alice);

    var bob = try example_pb.Person.init(arena);
    bob.setName("Bob");
    bob.setId(2);
    try book.addPeople(bob);

    try std.testing.expectEqual(@as(usize, 2), book.peopleCount());
    const first = book.getPeople(0) orelse return error.TestUnexpectedResult;
    try std.testing.expectEqualStrings("Alice", first.getName());
    const second = book.getPeople(1) orelse return error.TestUnexpectedResult;
    try std.testing.expectEqualStrings("Bob", second.getName());
}

test "PhoneType: enum conversion" {
    try std.testing.expectEqual(@as(i32, 1), example_pb.PhoneType.PHONE_TYPE_MOBILE.toInt());
    try std.testing.expectEqual(example_pb.PhoneType.PHONE_TYPE_WORK, example_pb.PhoneType.fromInt(3).?);
    try std.testing.expect(example_pb.PhoneType.fromInt(999) == null);
}
