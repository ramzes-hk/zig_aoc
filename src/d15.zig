const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

pub fn d15(allocator: std.mem.Allocator) !void {
    const mapMoves = try getMapMoves(allocator);
    const map = mapMoves.map;
    const moves = mapMoves.moves;
    var pos = mapMoves.start;
    defer {
        for (map) |line| {
            allocator.free(line);
        }
        allocator.free(map);
        moves.deinit();
    }
    outer: for (moves.items) |move| {
        var dir: usize = 0;
        var val: isize = 0;
        switch (move) {
            '^' => {
                dir = 1;
                val = -1;
            },
            '>' => {
                dir = 0;
                val = 1;
            },
            'v' => {
                dir = 1;
                val = 1;
            },
            '<' => {
                dir = 0;
                val = -1;
            },
            else => {},
        }
        var temp_pos = pos;
        var next = @as(isize, @intCast(pos[dir])) + val;
        temp_pos[dir] = @intCast(next);
        const first = temp_pos;
        if (map[temp_pos[1]][temp_pos[0]] == '#') continue :outer;
        while (map[temp_pos[1]][temp_pos[0]] != '.') {
            next = @as(isize, @intCast(temp_pos[dir])) + val;
            temp_pos[dir] = @intCast(next);
            if (map[temp_pos[1]][temp_pos[0]] == '#') continue :outer;
        }
        const temp = map[temp_pos[1]][temp_pos[0]];
        map[temp_pos[1]][temp_pos[0]] = map[first[1]][first[0]];
        map[first[1]][first[0]] = temp;
        pos = first;
    }
    var sum: u64 = 0;
    for (map, 0..) |line, y| {
        for (line, 0..) |c, x| {
            if (c == 'O') sum += 100 * y + x;
        }
    }
    std.log.debug("d15 q1: {d}", .{sum});
}

const MapMoves = struct {
    map: [][]u8,
    moves: std.ArrayList(u8),
    start: [2]usize,
};

fn getMapMoves(allocator: std.mem.Allocator) !MapMoves {
    var file = try readDayFile(15);
    defer file.close();
    const firstLine = try file.reader().readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
    const len = firstLine.len;
    var map = try allocator.alloc([]u8, len);
    map[0] = firstLine;
    var i: usize = 1;
    var start: [2]usize = .{0} ** 2;
    while (i < len) : (i += 1) {
        var line = try file.reader().readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
        for (line, 0..) |c, j| {
            if (c == '@') {
                start = .{ j, i };
                line[j] = '.';
            }
        }
        map[i] = line;
    }
    var moves = std.ArrayList(u8).init(allocator);
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        try moves.appendSlice(line);
    }
    return MapMoves{ .map = map, .moves = moves, .start = start };
}
