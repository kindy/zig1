const std = @import("std");

fn gg2(gpa: std.mem.Allocator, fn_: anytype, args: anytype) !void {
    const g = struct {
        const G = @This();
        var items: std.ArrayListUnmanaged(G) = .empty;

        fn_: *const fn (*anyopaque) void,
        data: *anyopaque,

        fn call(self: @This()) void {
            self.fn_(self.data);
        }

        fn of(comptime F: type, comptime A: type) type {
            return struct {
                fn_: F,
                args: A,

                fn callFn(ptr: *anyopaque) void {
                    const self = @as(*@This(), @ptrCast(@alignCast(ptr)));
                    @call(.auto, self.fn_, self.args);
                }

                fn toCallable(self: *@This()) G {
                    return .{
                        .fn_ = callFn,
                        .data = self,
                    };
                }
            };
        }
    };

    const gg = g.of(@TypeOf(fn_), @TypeOf(args));

    const gg_v = (&gg{
        .fn_ = fn_,
        .args = args,
    });

    try g.items.append(gpa, @constCast(gg_v).toCallable());

    for (g.items.items) |item| {
        item.call();
    }
}

test gg2 {
    const Test = struct {
        fn f1(v: u8) void {
            std.debug.print("f1 called with {}\n", .{v});
        }
        fn f2(v: []const u8) void {
            std.debug.print("f2 called with {s}\n", .{v});
        }
    };

    const gg = gg2;
    var v0: u8 = 10;
    std.debug.print("-- gg --\n", .{});
    try gg(std.testing.allocator, Test.f1, .{v0});
    std.debug.print("-- gg --\n", .{});
    v0 = 11;
    try gg(std.testing.allocator, Test.f1, .{v0});
    std.debug.print("-- gg --\n", .{});
    try gg(std.testing.allocator, Test.f2, .{"abc"});
}

test "gg2_fail" {
    const Test = struct {
        fn f1(v: u8) void {
            std.debug.print("f1 called with {}\n", .{v});
        }
        fn f2(v: []const u8) void {
            std.debug.print("f2 called with {s}\n", .{v});
        }
    };

    const gg = gg2;
    std.debug.print("-- gg --\n", .{});
    try gg(std.testing.allocator, Test.f1, .{10});
    std.debug.print("-- gg --\n", .{});
    try gg(std.testing.allocator, Test.f2, .{"abc"});
}
