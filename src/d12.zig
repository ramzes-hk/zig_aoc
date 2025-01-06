const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

const directions = [_][2]isize{
    .{ 0, -1 },
    .{ 1, 0 },
    .{ 0, 1 },
    .{ -1, 0 },
};
const corners = [_][2]usize{
    .{ 0, 1 }, .{ 1, 2 }, .{ 2, 3 }, .{ 3, 0 },
};
const diagonals = [_][2]isize{
    .{ 1, -1 }, .{ 1, 1 }, .{ -1, 1 }, .{ -1, -1 },
};
const SIZE = 140;

pub fn d12(allocator: std.mem.Allocator) !void {
    const map = try allocator.alloc([]u8, SIZE);
    defer {
        for (map) |line| {
            defer allocator.free(line);
        }
        allocator.free(map);
    }
    try readMap(allocator, map);
    var visited = std.AutoHashMap(usize, void).init(allocator);
    defer visited.deinit();

    var sum: u64 = 0;
    for (0..SIZE) |i| {
        for (0..SIZE) |j| {
            const res = try recursion(j, i, map, &visited);
            sum += res[0] * res[1];
            if (res[0] != 0) std.log.debug("{any}", .{res});
        }
    }
    std.log.debug("d12 q1: {d}", .{sum});
}

pub fn d12_q2(allocator: std.mem.Allocator) !void {
    const map = try allocator.alloc([]u8, SIZE);
    defer {
        for (map) |line| {
            defer allocator.free(line);
        }
        allocator.free(map);
    }
    try readMap(allocator, map);
    var visited = std.AutoHashMap(usize, void).init(allocator);
    defer visited.deinit();

    var sum: u64 = 0;
    for (0..SIZE) |i| {
        for (0..SIZE) |j| {
            const res = try recursion_q2(j, i, map, &visited);
            sum += res[0] * res[1];
            if (res[0] != 0) std.log.debug("{any}", .{res});
        }
    }
    std.log.debug("d12 q1: {d}", .{sum});
}

fn recursion_q2(x: usize, y: usize, map: [][]u8, visited: *std.AutoHashMap(usize, void)) ![2]u64 {
    if (visited.contains(x * 1000 + y)) {
        return .{0} ** 2;
    }
    try visited.put(x * 1000 + y, {});
    var area: u64 = 1;
    var sides: u64 = 0;
    var cornerArr: [4]u8 = .{0} ** 4;
    for (directions, 0..) |dir, idx| {
        const next_x = @as(isize, @intCast(x)) + dir[0];
        const next_y = @as(isize, @intCast(y)) + dir[1];
        if (next_x >= SIZE or next_x < 0 or next_y >= SIZE or next_y < 0) {
            std.log.debug("size issues {any} {d} {d} {d} {d}", .{ dir, x, y, next_x, next_y });
            cornerArr[idx] = 1;
            continue;
        }
        if (map[@intCast(next_y)][@intCast(next_x)] != map[y][x]) {
            std.log.debug("wrong char {any} {d} {d} {d} {d} {c} {c}", .{ dir, x, y, next_x, next_y, map[@intCast(next_y)][@intCast(next_x)], map[y][x] });
            cornerArr[idx] = 1;
            continue;
        }
        const add = try recursion_q2(@intCast(next_x), @intCast(next_y), map, visited);
        area += add[0];
        sides += add[1];
    }
    for (corners) |pair| {
        if (cornerArr[pair[0]] == 1 and cornerArr[pair[0]] == cornerArr[pair[1]]) {
            sides += 1;
        } else if (cornerArr[pair[0]] == 0 and cornerArr[pair[0]] == cornerArr[pair[1]]) {
            const diag_x = @as(isize, @intCast(x)) + diagonals[pair[0]][0];
            const diag_y = @as(isize, @intCast(y)) + diagonals[pair[0]][1];
            if (diag_x >= SIZE or diag_x < 0 or diag_y >= SIZE or diag_y < 0 or map[@intCast(diag_y)][@intCast(diag_x)] != map[y][x]) sides += 1;
        }
    }
    std.log.debug("{c} {d} {d} {any}", .{ map[y][x], x, y, cornerArr });
    return [_]u64{ area, sides };
}

fn recursion(x: usize, y: usize, map: [][]u8, visited: *std.AutoHashMap(usize, void)) ![2]u64 {
    if (visited.contains(x * 1000 + y)) {
        return .{0} ** 2;
    }
    try visited.put(x * 1000 + y, {});
    var area: u64 = 1;
    var per: u64 = 0;
    for (directions) |dir| {
        const next_x = @as(isize, @intCast(x)) + dir[0];
        const next_y = @as(isize, @intCast(y)) + dir[1];
        if (next_x >= SIZE or next_x < 0 or next_y >= SIZE or next_y < 0) {
            per += 1;
            continue;
        }
        if (map[@intCast(next_y)][@intCast(next_x)] != map[y][x]) {
            per += 1;
            continue;
        }
        const add = try recursion(@intCast(next_x), @intCast(next_y), map, visited);
        area += add[0];
        per += add[1];
    }
    return [_]u64{ area, per };
}

fn readMap(allocator: std.mem.Allocator, map: [][]u8) !void {
    var file = try readDayFile(12);
    defer file.close();
    var i: usize = 0;
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        map[i] = line;
        i += 1;
    }
}
fn validNextCell(next_x: isize, next_y: isize, x: usize, y: usize, map: [][]u8) bool {
    if (next_x >= SIZE or next_x < 0 or next_y >= SIZE or next_y < 0 or map[@intCast(next_y)][@intCast(next_x)] != map[y][x]) return false;
    return true;
}
