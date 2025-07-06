const std = @import("std");

const time = std.time;

const sleep = struct {
    const Unit = enum(u64) {
        ns = 1,
        us = time.ns_per_us,
        ms = time.ns_per_ms,
        s = time.ns_per_s,

        _,

        pub fn from(n: u64) Unit {
            return @enumFromInt(n);
        }
        pub fn ns_per_t(n: u64) Unit {
            return @enumFromInt(n);
        }
    };

    fn sleep(t: anytype, unit: Unit) void {
        const T = @TypeOf(t);
        const nanoseconds = switch (@typeInfo(T)) {
            .int, .comptime_int => @as(u64, t) * @intFromEnum(unit),
            .float, .comptime_float => @as(u64, @intFromFloat(t * @as(f64, @floatFromInt(@intFromEnum(unit))))),
            else => @compileError("Expected numeric type for sleep duration, got " ++ @typeName(T)),
        };
        std.Thread.sleep(nanoseconds);
    }
}.sleep;

test sleep {
    sleep(1, .ns);
    sleep(1, .us);
    sleep(1, .ms);
    sleep(1, .s);

    sleep(0.5, .s);
    sleep(std.math.pi, .ms);

    sleep(1, .from(1));
    sleep(1, .from(2));

    sleep(1, .ns_per_t(2));
    sleep(1, .ns_per_t(4));
}
