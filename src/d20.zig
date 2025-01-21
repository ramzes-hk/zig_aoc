const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

const CHEAT = 100;
const directions: [4][2]isize = .{
    .{ 1, 0 },
    .{ 0, 1 },
    .{ -1, 0 },
    .{ 0, -1 },
};

pub fn d20(allocator: std.mem.Allocator) !void {
    var map_ = try readMap(allocator);
    defer {
        for (map_.map) |line| {
            allocator.free(line);
        }
        allocator.free(map_.map);
    }
    const og = try findFastest(allocator, map_, std.math.maxInt(usize), 0);
    var res: u64 = 0;
    for (map_.map, 0..) |line, i| {
        for (line, 0..) |c, j| {
            if (c != '#') continue;
            map_.map[i][j] = '.';
            const time = try findFastest(allocator, map_, og, CHEAT);
            map_.map[i][j] = '#';
            if (time > og) continue;
            if (og - time >= CHEAT) res += 1;
        }
    }
    std.log.debug("{d}", .{res});
}

fn findFastest(allocator: std.mem.Allocator, map_: Map, target: usize, diff: usize) !usize {
    var arena = std.heap.ArenaAllocator.init(allocator);
    const arena_allocator = arena.allocator();
    defer arena.deinit();
    const queue_type = std.DoublyLinkedList([3]usize);
    var queue = queue_type{};
    var head = queue_type.Node{ .data = .{ map_.start[0], map_.start[1], 0 } };
    queue.append(&head);
    var visited = std.AutoHashMap(isize, usize).init(allocator);
    defer visited.deinit();
    const map = map_.map;
    while (queue.len > 0) {
        const current = queue.popFirst().?;
        if (target - current.data[2] < diff) return std.math.maxInt(usize);
        for (directions) |dir| {
            const next_x = addPos(current.data[0], dir[0]);
            const next_y = addPos(current.data[1], dir[1]);
            if (next_x >= map.len or next_x < 0 or next_y >= map.len or next_y < 0) continue;
            if (visited.contains(next_x * 1000 + next_y)) continue;
            if (map[@intCast(next_y)][@intCast(next_x)] == '#') continue;
            if (map[@intCast(next_y)][@intCast(next_x)] == 'E') {
                return current.data[2] + 1;
            }
            try visited.put(next_x * 1000 + next_y, current.data[2] + 1);
            const node = try arena_allocator.create(queue_type.Node);
            node.* = queue_type.Node{ .data = .{ @intCast(next_x), @intCast(next_y), current.data[2] + 1 } };
            queue.append(node);
        }
    }
    return 0;
}

fn addPos(origin: usize, diff: isize) isize {
    return @as(isize, @intCast(origin)) + diff;
}

const Map = struct {
    map: [][]u8,
    start: [2]usize,
};

fn readMap(allocator: std.mem.Allocator) !Map {
    var file = try readDayFile(20);
    defer file.close();
    var start: [2]usize = undefined;
    const firstLine = try file.reader().readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
    var map = try allocator.alloc([]u8, firstLine.len);
    map[0] = firstLine;
    var i: usize = 1;
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        for (line, 0..) |c, j| {
            if (c == 'S') start = .{ j, i };
        }
        map[i] = line;
        i += 1;
    }
    return Map{ .start = start, .map = map };
}
