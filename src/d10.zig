const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

const directions = [_][2]isize{
    .{ 1, 0 },
    .{ 0, 1 },
    .{ -1, 0 },
    .{ 0, -1 },
};

pub fn d10(allocator: std.mem.Allocator) !void {
    const map = try readMap(allocator);
    defer {
        for (map) |line| {
            allocator.free(line);
        }
        allocator.free(map);
    }

    var sum: u64 = 0;
    for (map, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c != '0') continue;
            var visited = std.AutoHashMap(usize, void).init(allocator);
            defer visited.deinit();
            std.log.debug("{d} {d}", .{ j, i });
            sum += try recursion(j, i, map, '0', &visited);
        }
    }
    std.log.debug("d10 q1: {d}", .{sum});
}

pub fn d10_q2(allocator: std.mem.Allocator) !void {
    const map = try readMap(allocator);
    defer {
        for (map) |line| {
            allocator.free(line);
        }
        allocator.free(map);
    }

    var sum: u64 = 0;
    for (map, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c != '0') continue;
            std.log.debug("{d} {d}", .{ j, i });
            sum += try recursion_q2(j, i, map, '0');
        }
    }
    std.log.debug("d10 q2: {d}", .{sum});
}

fn inBorders(T: type, x: T, y: T, min: T, max: T) bool {
    if (x < min or x > max or y < min or y > max) {
        return false;
    }
    return true;
}

fn recursion(x: usize, y: usize, map: [][]u8, target: u8, visited: *std.AutoHashMap(usize, void)) !u64 {
    if (map[y][x] != target) return 0;
    if (target == '9' and !visited.contains(x * 100 + y)) {
        std.log.debug("9: {d} {d}", .{ x, y });
        try visited.put(x * 100 + y, {});
        return 1;
    }
    try visited.put(x * 100 + y, {});
    var sum: u64 = 0;
    const len = map.len;
    for (directions) |dir| {
        const new_x: isize = @as(isize, @intCast(x)) + dir[0];
        const new_y: isize = @as(isize, @intCast(y)) + dir[1];
        if (inBorders(isize, new_x, new_y, 0, @intCast(len - 1))) {
            sum += try recursion(@intCast(new_x), @intCast(new_y), map, target + 1, visited);
        }
    }
    return sum;
}

fn recursion_q2(x: usize, y: usize, map: [][]u8, target: u8) !u64 {
    if (map[y][x] != target) return 0;
    if (target == '9') {
        std.log.debug("9: {d} {d}", .{ x, y });
        return 1;
    }
    var sum: u64 = 0;
    const len = map.len;
    for (directions) |dir| {
        const new_x: isize = @as(isize, @intCast(x)) + dir[0];
        const new_y: isize = @as(isize, @intCast(y)) + dir[1];
        if (inBorders(isize, new_x, new_y, 0, @intCast(len - 1))) {
            sum += try recursion_q2(@intCast(new_x), @intCast(new_y), map, target + 1);
        }
    }
    return sum;
}
fn readMap(allocator: std.mem.Allocator) ![][]u8 {
    var file = try readDayFile(10);
    defer file.close();
    const firstLine = try file.reader().readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
    var arr = try allocator.alloc([]u8, firstLine.len);
    arr[0] = firstLine;
    var i: usize = 1;
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        arr[i] = line;
        i += 1;
    }
    return arr;
}
