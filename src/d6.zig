const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

const dirs = [_][2]isize{ [_]isize{ 0, -1 }, [_]isize{ 1, 0 }, [_]isize{ 0, 1 }, [_]isize{ -1, 0 } };
const SIZE = 130;

pub fn d6() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var obst = std.AutoHashMap(isize, void).init(allocator);
    defer obst.deinit();
    var path = std.AutoHashMap(isize, void).init(allocator);
    defer path.deinit();
    const start = try getObstAndStart(allocator, &obst);
    var x_pos: isize = start.x;
    var y_pos: isize = start.y;
    var dir: usize = 0;

    while (x_pos < SIZE and x_pos >= 0 and y_pos < SIZE and y_pos >= 0) {
        try path.put(x_pos * 1000 + y_pos, {});
        // std.log.debug("{d} {d}", .{ x_pos, y_pos });
        var next_x = x_pos + dirs[dir][0];
        var next_y = y_pos + dirs[dir][1];
        while (obst.get(next_x * 1000 + next_y) != null) {
            dir = if (dir == 3) 0 else dir + 1;
            next_x = x_pos + dirs[dir][0];
            next_y = y_pos + dirs[dir][1];
        }
        x_pos = next_x;
        y_pos = next_y;
    }
    var c: usize = 0;
    var iter = path.iterator();
    while (iter.next()) |_| {
        c += 1;
    }
    std.log.debug("d6 q1: {d}", .{c});
}

const Point = struct {
    x: isize,
    y: isize,
    fn copy(self: Point) Point {
        return Point{ .x = self.x, .y = self.y };
    }
};

pub fn d6_q2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var obst: [SIZE][SIZE]i64 = .{.{0} ** SIZE} ** SIZE;
    const start = try getObstAndStartWNumbers(allocator, &obst);
    var c: usize = 0;
    var i: usize = 0;

    while (i < SIZE) : (i += 1) {
        var j: usize = 0;
        while (j < SIZE) : (j += 1) {
            if (j == start.x and i == start.y) continue;
            var path = std.AutoHashMap(isize, [4]u8).init(allocator);
            defer path.deinit();
            var dir: usize = 0;
            var pos: Point = start.copy();
            obst[i][j] += 1;
            while (isInBounds(pos)) {
                var n: [4]u8 = .{0} ** 4;
                if (path.get(pos.x * 1000 + pos.y)) |val| {
                    if (val[dir] == 1) {
                        c += 1;
                        break;
                    }
                    n = val;
                }
                n[dir] = 1;
                try path.put(pos.x * 1000 + pos.y, n);
                var next_pos = Point{ .x = pos.x + dirs[dir][0], .y = pos.y + dirs[dir][1] };
                while (isInBounds(next_pos) and obst[@intCast(next_pos.y)][@intCast(next_pos.x)] > 0) {
                    dir = if (dir == 3) 0 else dir + 1;
                    next_pos.x = pos.x + dirs[dir][0];
                    next_pos.y = pos.y + dirs[dir][1];
                }
                pos = next_pos.copy();
            }
            obst[i][j] -= 1;
        }
    }
    std.log.debug("d6 q2: {d}", .{c});
}

fn isInBounds(pos: Point) bool {
    return pos.x >= 0 and pos.x < SIZE and pos.y >= 0 and pos.y < SIZE;
}

fn getObstAndStartWNumbers(allocator: std.mem.Allocator, arr: *[SIZE][SIZE]i64) !Point {
    const file = try readDayFile(6);
    defer file.close();
    var x_pos: isize = 0;
    var y_pos: isize = 0;
    var y: usize = 0;
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(isize))) |line| {
        defer allocator.free(line);
        for (line, 0..) |char, x| {
            if (char == '#') {
                arr[y][x] = 1;
            } else if (char == '^') {
                x_pos = @intCast(x);
                y_pos = @intCast(y);
            }
        }
        y += 1;
    }
    return Point{ .x = x_pos, .y = y_pos };
}

fn getObstAndStart(allocator: std.mem.Allocator, map: *std.AutoHashMap(isize, void)) !struct { x: isize, y: isize } {
    const file = try readDayFile(6);
    defer file.close();
    var x_pos: isize = 0;
    var y_pos: isize = 0;
    var y: isize = 0;
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(isize))) |line| {
        defer allocator.free(line);
        for (line, 0..) |char, x_| {
            const x: isize = @intCast(x_);
            if (char == '#') {
                try map.put(x * 1000 + y, {});
            } else if (char == '^') {
                x_pos = x;
                y_pos = y;
            }
        }
        y += 1;
    }
    return .{ .x = x_pos, .y = y_pos };
}
