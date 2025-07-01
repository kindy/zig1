const std = @import("std");

fn gg1(gpa: std.mem.Allocator, fn_: anytype, args: anytype) !void {
    _ = gpa;
    @call(.auto, fn_, args);
}

fn gg3(gpa: std.mem.Allocator, fn_: anytype, args: anytype) !void {
    const g = struct {
        const G = @This();
        var items: std.ArrayListUnmanaged(G) = .empty;

        fn_: *const fn (*G) void,

        fn call(self: *const G) void {
            self.fn_(@constCast(self));
        }
    };

    const A = @TypeOf(args);
    const gg = struct {
        args: A,
        g: g = .{ .fn_ = callFn },

        fn callFn(g0: *g) void {
            const self: *@This() = @fieldParentPtr("g", g0);
            std.debug.print("gg.callFn g0.fn_*: {*}\n", .{g0.fn_});
            std.debug.print("gg.args: {any}\n", .{A});
            @call(.auto, fn_, self.args);
        }
    };

    const gg_v = try gpa.create(gg);
    gg_v.* = .{
        .args = args,
    };

    try g.items.append(gpa, gg_v.g);

    for (g.items.items) |item| {
        item.call();
    }
}

fn gg3_ex(gpa: std.mem.Allocator, fn_: anytype, args: anytype) !void {
    const g = struct {
        const G = @This();
        var items: std.ArrayListUnmanaged(*G) = .empty;

        fn_: *const fn (*G) void,

        fn call(self: *G) void {
            self.fn_(self);
        }
    };

    const A = @TypeOf(args);
    const gg = struct {
        args: A,
        g: g = .{ .fn_ = callFn },

        fn callFn(g0: *g) void {
            const self: *@This() = @fieldParentPtr("g", g0);
            std.debug.print("gg.callFn g0.fn_*: {*}\n", .{g0.fn_});
            std.debug.print("gg.args: {any}\n", .{A});
            @call(.auto, fn_, self.args);
        }
    };

    const gg_v = try gpa.create(gg);
    gg_v.* = .{
        .args = args,
    };

    try g.items.append(gpa, &gg_v.g);

    for (g.items.items) |item| {
        item.call();
    }
}

fn testGg(comptime gg: anytype) !void {
    const Test = struct {
        fn f1(v: u8) void {
            std.debug.print("f1 called with {}\n", .{v});
        }
        fn f2(v: []const u8) void {
            std.debug.print("f2 called with {s}\n", .{v});
        }
    };

    var v0: u8 = 10;
    std.debug.print("-- gg --\n", .{});
    try gg(std.testing.allocator, Test.f1, .{v0});
    std.debug.print("-- gg --\n", .{});
    v0 = 11;
    try gg(std.testing.allocator, Test.f1, .{v0});
    std.debug.print("-- gg --\n", .{});
    try gg(std.testing.allocator, Test.f2, .{"abc"});
}

test gg1 {
    try testGg(gg1);
}

test gg3 {
    try testGg(gg3);
    std.process.exit(0);
}

test gg3_ex {
    try testGg(gg3_ex);
    std.process.exit(0);
}
