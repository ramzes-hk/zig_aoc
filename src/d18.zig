const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

const N = 1024;
const SIZE = 71;
const START = [2]usize{ 0, 0 };
const END = [2]usize{ SIZE - 1, SIZE - 1 };
const directions: [4][2]isize = .{
    .{ 1, 0 },
    .{ -1, 0 },
    .{ 0, 1 },
    .{ 0, -1 },
};
const Point = struct {
    x: usize,
    y: usize,
    d: u64,
};

pub fn d18(allocator: std.mem.Allocator) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();
    const bytes = try readBytes(allocator);
    defer bytes.deinit();
    var visited = std.AutoHashMap(usize, void).init(allocator);
    defer visited.deinit();
    var map: [SIZE][SIZE]u8 = .{.{0} ** SIZE} ** SIZE;
    genMap(&map, bytes);
    const queue_type = std.DoublyLinkedList(Point);
    var queue = queue_type{};
    const initial = try arena_allocator.create(queue_type.Node);
    initial.data = .{ .x = START[0], .y = START[1], .d = 0 };
    queue.append(initial);
    var res: u64 = 0;
    while (queue.len > 0) {
        const current = queue.popFirst().?;
        if (current.data.x == END[0] and current.data.y == END[1]) {
            res = current.data.d;
            break;
        }
        for (directions) |dir| {
            const next_x = addPos(current.data.x, dir[0]);
            const next_y = addPos(current.data.y, dir[1]);
            if (next_x >= SIZE or next_x < 0 or next_y >= SIZE or next_y < 0) continue;
            if (map[@intCast(next_y)][@intCast(next_x)] == 1) continue;
            if (visited.contains(@intCast(next_x * 100 + next_y))) continue;
            try visited.put(@intCast(next_x * 100 + next_y), {});
            const node = try arena_allocator.create(queue_type.Node);
            node.data = .{ .x = @intCast(next_x), .y = @intCast(next_y), .d = current.data.d + 1 };
            queue.append(node);
        }
    }
    std.log.debug("d18 q1: {d}", .{res});
}

pub fn d18_q2(allocator: std.mem.Allocator) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();
    const bytes = try readBytes(allocator);
    defer bytes.deinit();
    var map: [SIZE][SIZE]u8 = .{.{0} ** SIZE} ** SIZE;
    genMap(&map, bytes);
    const queue_type = std.DoublyLinkedList(Point);
    var res: [2]usize = undefined;
    for (bytes.items[N + 1 ..], N + 1..) |obst, idx| {
        map[obst[1]][obst[0]] = 1;
        var visited = std.AutoHashMap(usize, void).init(allocator);
        defer visited.deinit();
        var queue = queue_type{};
        const initial = try arena_allocator.create(queue_type.Node);
        initial.data = .{ .x = START[0], .y = START[1], .d = 0 };
        queue.append(initial);
        while (queue.len > 0) {
            const current = queue.popFirst().?;
            if (current.data.x == END[0] and current.data.y == END[1]) break;
            for (directions) |dir| {
                const next_x = addPos(current.data.x, dir[0]);
                const next_y = addPos(current.data.y, dir[1]);
                if (next_x >= SIZE or next_x < 0 or next_y >= SIZE or next_y < 0) continue;
                if (map[@intCast(next_y)][@intCast(next_x)] == 1) continue;
                if (visited.contains(@intCast(next_x * 100 + next_y))) continue;
                try visited.put(@intCast(next_x * 100 + next_y), {});
                const node = try arena_allocator.create(queue_type.Node);
                node.data = .{ .x = @intCast(next_x), .y = @intCast(next_y), .d = current.data.d + 1 };
                queue.append(node);
            }
        }
        if (!visited.contains(END[0] * 100 + END[1])) {
            std.log.debug("{d}", .{idx});
            res = bytes.items[idx];
            break;
        }
    }
    std.log.debug("d18 q2: {d}", .{res});
}

fn addPos(origin: usize, diff: isize) isize {
    return @as(isize, @intCast(origin)) + diff;
}

fn genMap(map: *[SIZE][SIZE]u8, arr: std.ArrayList([2]usize)) void {
    for (0..N) |i| {
        map[arr.items[i][1]][arr.items[i][0]] = 1;
    }
    return;
}

fn readBytes(allocator: std.mem.Allocator) !std.ArrayList([2]usize) {
    var file = try readDayFile(18);
    defer file.close();
    var arr = std.ArrayList([2]usize).init(allocator);
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        var tokens = std.mem.tokenizeAny(u8, line, ",");
        var pos: [2]usize = undefined;
        var i: usize = 0;
        while (tokens.next()) |token| {
            pos[i] = try std.fmt.parseInt(usize, token, 10);
            i += 1;
        }
        try arr.append(pos);
    }
    return arr;
}
