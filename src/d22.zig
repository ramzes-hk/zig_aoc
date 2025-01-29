const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;
const PRUNE = 16777216;
const ITER = 2000;

pub fn d22(allocator: std.mem.Allocator) !void {
    const list = try getNumbers(allocator);
    defer list.deinit();
    var sum: u64 = 0;
    for (list.items) |n| {
        var current = n;
        for (ITER) |_| {
            current = predict(current);
        }
        sum += current;
    }
    std.log.debug("d22 q1: {}", .{sum});
}

fn predict(n: u64) u64 {
    var next_secret = cleanUp(n, n * 64);
    next_secret = cleanUp(@divTrunc(next_secret, 32), next_secret);
    return cleanUp(next_secret, 2048 * next_secret);
}

fn cleanUp(secret: u64, n: u64) u64 {
    const next_secret = n ^ secret;
    return @mod(next_secret, PRUNE);
}

fn getNumbers(allocator: std.mem.Allocator) !std.ArrayList(u64) {
    var file = try readDayFile(allocator, 22);
    defer file.close();
    var list = std.ArrayList(u64).init(allocator);
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        const n = try std.fmt.parseInt(u64, line, 10);
        try list.append(n);
    }
    return list;
}
