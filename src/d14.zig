const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

const X = 101;
const Y = 103;

pub fn d14(allocator: std.mem.Allocator) !void {
    var arr = try getRobots(allocator);
    defer arr.deinit();
    var map: [Y][X]u64 = .{.{0} ** X} ** Y;
    for (arr.items) |robot| {
        var x = robot.p[0];
        var y = robot.p[1];
        for (0..100) |_| {
            var next_x = x + robot.v[0];
            if (next_x < 0) next_x = X + next_x;
            if (next_x >= X) next_x = next_x - X;
            var next_y = y + robot.v[1];
            if (next_y < 0) next_y = Y + next_y;
            if (next_y >= Y) next_y = next_y - Y;
            x = next_x;
            y = next_y;
        }
        map[@intCast(y)][@intCast(x)] += 1;
    }
    var quads: [4]u64 = .{0} ** 4;
    var k: usize = 0;
    for (0..2) |i| {
        for (0..2) |j| {
            var quad: u64 = 0;
            for (i * (Y / 2 + 1)..i * (Y / 2 + 1) + Y / 2) |ii| {
                for (j * (X / 2 + 1)..j * (X / 2 + 1) + X / 2) |jj| {
                    // std.log.debug("{d} {d}", .{ jj, ii });
                    quad += map[ii][jj];
                }
            }
            quads[k] = quad;
            k += 1;
        }
    }
    for (map) |line| {
        std.log.debug("{any}", .{line});
    }
    std.log.debug("d14 q1: {any}", .{quads[0] * quads[1] * quads[2] * quads[3]});
}

pub fn d14_q2(allocator: std.mem.Allocator) !void {
    var arr = try getRobots(allocator);
    defer arr.deinit();
    var i: usize = 0;
    outer: while (true) {
        i += 1;
        var map: [Y][X]u64 = .{.{0} ** X} ** Y;
        for (arr.items, 0..) |robot, idx| {
            var x = robot.p[0];
            var y = robot.p[1];
            var next_x = x + robot.v[0];
            if (next_x < 0) next_x = X + next_x;
            if (next_x >= X) next_x = next_x - X;
            var next_y = y + robot.v[1];
            if (next_y < 0) next_y = Y + next_y;
            if (next_y >= Y) next_y = next_y - Y;
            x = next_x;
            y = next_y;
            map[@intCast(y)][@intCast(x)] += 1;
            arr.items[idx].p = .{ x, y };
        }
        var s: u64 = 0;
        var t: u64 = 0;
        for (map) |line| {
            for (line) |n| {
                if (n > 0) {
                    t += 1;
                    s = @max(t, s);
                } else {
                    t = 0;
                }
            }
        }
        if (s > 10) {
            for (map) |line| {
                for (line) |n| {
                    if (n > 0) {
                        std.debug.print("0", .{});
                    } else {
                        std.debug.print(" ", .{});
                    }
                }
                std.debug.print("\n", .{});
            }
            std.log.debug("{d}", .{i});
            break :outer;
        }
    }
}

const Robot = struct {
    p: [2]i32,
    v: [2]i32,
};

fn getRobots(allocator: std.mem.Allocator) !std.ArrayList(Robot) {
    var file = try readDayFile(14);
    defer file.close();
    var arr = std.ArrayList(Robot).init(allocator);
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        var robot: Robot = .{
            .p = .{ 0, 0 },
            .v = .{ 0, 0 },
        };
        var tokens = std.mem.tokenizeAny(u8, line, " pv,=");
        var i: usize = 0;
        while (tokens.next()) |token| {
            const num = std.fmt.parseInt(i32, token, 10) catch 0;
            switch (i) {
                0 => robot.p[0] = num,
                1 => robot.p[1] = num,
                2 => robot.v[0] = num,
                3 => robot.v[1] = num,
                else => {},
            }
            i += 1;
        }
        try arr.append(robot);
    }
    return arr;
}
