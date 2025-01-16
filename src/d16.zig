const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

const directions: [4][2]isize = .{
    .{ 1, 0 },
    .{ 0, 1 },
    .{ -1, 0 },
    .{ 0, -1 },
};

pub fn d16(allocator: std.mem.Allocator) !void {
    const map_ = try readMap(allocator);
    const map = map_.map;
    defer {
        for (map_.map) |line| {
            allocator.free(line);
        }
        allocator.free(map_.map);
    }
    var visited = std.AutoHashMap(usize, i64).init(allocator);
    defer visited.deinit();
    const res = try recursion(allocator, map_.start[0], map_.start[1], 0, map, 0, &visited);
    std.log.debug("d16 q1: {d}", .{res});
}

pub fn d16_q2(allocator: std.mem.Allocator) !void {
    const map_ = try readMap(allocator);
    const map = map_.map;
    const start = map_.start;
    defer {
        for (map_.map) |line| {
            allocator.free(line);
        }
        allocator.free(map_.map);
    }
    var visited = std.AutoHashMap(usize, i64).init(allocator);
    defer visited.deinit();
    _ = try recursion_q2(allocator, start[0], start[1], 0, map, 0, &visited);
    var res: u64 = 1;
    for (map) |line| {
        for (line) |c| {
            if (c == PATH) res += 1;
        }
    }
    printMap(map);
    std.log.debug("d16 q2: {d}", .{res});
}

const TARGET = 0; // q1 result
const BORDER = '#';
const END = 'E';
const PATH = 'Q';
const SENTINEL = std.math.maxInt(i64);

fn recursion_q2(allocator: std.mem.Allocator, x: usize, y: usize, dir: usize, noalias map: [][]u8, w: i64, noalias visited: *std.AutoHashMap(usize, i64)) !i64 {
    if (map[y][x] == BORDER) return SENTINEL;
    if (map[y][x] == END) {
        return w;
    }
    const key = x * 1000 + y;
    if (visited.get(key)) |val| {
        if (val > w) try visited.put(key, w);
        if (val + 2000 < w) return SENTINEL; // this is so hacky bruh
    } else try visited.put(key, w);
    if (w > TARGET) return SENTINEL;
    var res: [4]i64 = .{SENTINEL} ** 4;
    for (directions, 0..) |d, idx| {
        const diff = absDiff(idx, dir);
        const next_x = addPos(x, d[0]);
        const next_y = addPos(y, d[1]);
        if (map[next_y][next_x] == '#') continue;
        res[idx] = try recursion_q2(allocator, next_x, next_y, idx, map, w + 1 + 1000 * diff, visited);
    }
    var m: i64 = SENTINEL;
    for (res) |n| {
        if (n == TARGET) {
            map[y][x] = PATH;
        }
        m = @min(m, n);
    }
    return m;
}

fn printMap(noalias map: [][]u8) void {
    for (map) |line| {
        for (line) |c| {
            std.debug.print("{c}", .{c});
        }
        std.debug.print("\n", .{});
    }
}

fn addPos(origin: usize, diff: isize) usize {
    return @as(usize, @intCast(@as(isize, @intCast(origin)) + diff));
}

fn absIsize(n: isize) isize {
    return if (n >= 0) n else -n;
}

fn absDiff(a: usize, b: usize) i64 {
    const diff = absIsize(@as(isize, @intCast(a)) - @as(isize, @intCast(b)));
    return @as(i64, @intCast(@min(diff, 4 - diff)));
}

test "absDiff" {
    try std.testing.expect(absDiff(0, 2) == 2);
    try std.testing.expect(absDiff(0, 3) == 1);
    try std.testing.expect(absDiff(3, 1) == 2);
    try std.testing.expect(absDiff(0, 0) == 0);
}

fn recursion(allocator: std.mem.Allocator, x: usize, y: usize, dir: usize, noalias map: [][]u8, w: i64, noalias visited: *std.AutoHashMap(usize, i64)) !i64 {
    if (map[y][x] == '#') return SENTINEL;
    if (map[y][x] == 'E') {
        return w;
    }
    if (visited.get(x * 1000 + y)) |val| {
        if (val < w) return SENTINEL;
    }
    try visited.put(x * 1000 + y, w);
    var res: [4]i64 = .{SENTINEL} ** 4;
    for (directions, 0..) |d, idx| {
        const diff = absDiff(idx, dir);
        const next_x = addPos(x, d[0]);
        const next_y = addPos(y, d[1]);
        if (map[next_y][next_x] == '#') continue;
        res[idx] = try recursion(allocator, next_x, next_y, idx, map, w + 1 + 1000 * diff, visited);
    }
    var m: i64 = SENTINEL;
    for (res) |n| {
        m = @min(m, n);
    }
    return m;
}

const Map = struct {
    map: [][]u8,
    start: [2]usize,
    end: [2]usize,
};

fn readMap(allocator: std.mem.Allocator) !Map {
    var file = try readDayFile(16);
    defer file.close();
    const firstLine = try file.reader().readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
    var arr = try allocator.alloc([]u8, firstLine.len);
    arr[0] = firstLine;
    var i: usize = 1;
    var start: [2]usize = undefined;
    var end: [2]usize = undefined;
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        arr[i] = line;
        for (line, 0..) |c, j| {
            if (c == 'S') {
                start = .{ j, i };
            } else if (c == 'E') {
                end = .{ j, i };
            }
        }
        i += 1;
    }
    return Map{ .map = arr, .start = start, .end = end };
}
