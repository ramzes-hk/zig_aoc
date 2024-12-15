const std = @import("std");
const readDayFile = @import("./utils.zig").readDayFile;

pub fn d5() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file = try readDayFile(5);
    defer file.close();
    var map: std.AutoHashMap(i64, std.ArrayList(i64)) = try get_rules(allocator, file);
    defer {
        var map_iter = map.valueIterator();
        while (map_iter.next()) |item| {
            item.deinit();
        }
        map.deinit();
    }
    var list = std.ArrayList([]i64).init(allocator);
    defer {
        for (list.items) |item| {
            allocator.free(item);
        }
        list.deinit();
    }
    try get_updates(allocator, file, &list);

    var sum: i64 = 0;
    outer: for (list.items) |line| {
        for (line, 0..) |num, pos| {
            if (map.get(num)) |vals| {
                for (vals.items) |val| {
                    const wrong = for (line[pos..]) |prev| {
                        if (prev == val) break true;
                    } else false;
                    if (wrong) continue :outer;
                }
            }
        }
        const mid = line[line.len / 2];
        sum += mid;
    }
    std.log.debug("d5 q1: {d}", .{sum});
}

const SortContext = struct {
    map: *std.AutoHashMap(i64, void),
    fn inner(ctx: @This(), lhs: i64, rhs: i64) bool {
        if (ctx.map.get(lhs * 100 + rhs)) |_| {
            return true;
        }
        return false;
    }
};

pub fn d5_q2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file = try readDayFile(5);
    defer file.close();
    var map: std.AutoHashMap(i64, void) = try get_rules_map(allocator, file);
    defer map.deinit();
    var list = std.ArrayList([]i64).init(allocator);
    defer {
        for (list.items) |item| {
            allocator.free(item);
        }
        list.deinit();
    }
    try get_updates(allocator, file, &list);

    var sum: i64 = 0;

    for (list.items) |l| {
        var i: usize = l.len;
        var wrong: bool = false;
        while (i > 0) {
            i -= 1;
            const item = l[i];
            var j: usize = i;
            while (j > 0) {
                j -= 1;
                const past_item = l[j];
                if (map.get(item * 100 + past_item)) |_| {
                    wrong = true;
                    std.mem.sort(i64, l, SortContext{ .map = &map }, SortContext.inner);
                    break;
                }
            }
        }
        if (wrong) {
            std.log.debug("{any}", .{l});
        }
        sum += if (wrong) l[l.len / 2] else 0;
    }

    std.log.debug("d5 q2: {d}", .{sum});
}

fn get_rules(allocator: std.mem.Allocator, file: std.fs.File) !std.AutoHashMap(i64, std.ArrayList(i64)) {
    var map = std.AutoHashMap(i64, std.ArrayList(i64)).init(allocator);
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        if (line.len < 3) break;
        const before = try std.fmt.parseInt(i64, line[0..2], 10);
        const after = try std.fmt.parseInt(i64, line[3..5], 10);
        const entry = try map.getOrPut(after);
        if (!entry.found_existing) {
            entry.value_ptr.* = std.ArrayList(i64).init(allocator);
        }
        try entry.value_ptr.append(before);
    }
    return map;
}

fn get_rules_map(allocator: std.mem.Allocator, file: std.fs.File) !std.AutoHashMap(i64, void) {
    var map = std.AutoHashMap(i64, void).init(allocator);
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        if (line.len < 3) break;
        const before = try std.fmt.parseInt(i64, line[0..2], 10);
        const after = try std.fmt.parseInt(i64, line[3..5], 10);
        try map.put(before * 100 + after, {});
    }
    return map;
}

fn get_updates(allocator: std.mem.Allocator, file: std.fs.File, list: *std.ArrayList([]i64)) !void {
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        var subList = std.ArrayList(i64).init(allocator);
        defer subList.deinit();
        var numbers = std.mem.tokenizeAny(u8, line, ",");
        while (numbers.next()) |n| {
            const number = try std.fmt.parseInt(i64, n, 10);
            try subList.append(number);
        }
        const copy = try allocator.dupe(i64, subList.items);
        try list.append(copy);
    }
}
