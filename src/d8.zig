const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

const SIZE = 50;

pub fn d8() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var map: std.AutoHashMap(u8, std.AutoHashMap(usize, @Vector(2, isize))) = try getMap(allocator);
    defer {
        var iter = map.valueIterator();
        while (iter.next()) |item| {
            item.*.deinit();
        }
        map.deinit();
    }
    var nodeMap = std.AutoHashMap(isize, void).init(allocator);
    defer nodeMap.deinit();
    var iter = map.valueIterator();
    while (iter.next()) |item| {
        var subIter = item.*.valueIterator();
        while (subIter.next()) |subItem| {
            var tempIter = item.*.valueIterator();
            while (tempIter.next()) |tempItem| {
                if (tempItem.*[0] == subItem.*[0] and tempItem.*[1] == subItem.*[1]) continue;
                const a = tempItem.* + tempItem.* - subItem.*;
                const b = subItem.* + subItem.* - tempItem.*;
                if (a[0] > -1 and a[0] < SIZE and a[1] > -1 and a[1] < SIZE) try nodeMap.put(a[0] * 100 + a[1], {});
                if (b[0] > -1 and b[0] < SIZE and b[1] > -1 and b[1] < SIZE) try nodeMap.put(b[0] * 100 + b[1], {});
            }
        }
    }
    var c: usize = 0;
    var nodeIter = nodeMap.iterator();
    while (nodeIter.next()) |_| {
        c += 1;
    }
    std.log.debug("d8 q1: {d}", .{c});
}

pub fn d8_q2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var map: std.AutoHashMap(u8, std.AutoHashMap(usize, @Vector(2, isize))) = try getMap(allocator);
    defer {
        var iter = map.valueIterator();
        while (iter.next()) |item| {
            item.*.deinit();
        }
        map.deinit();
    }
    var nodeMap = std.AutoHashMap(isize, void).init(allocator);
    defer nodeMap.deinit();
    var iter = map.valueIterator();
    while (iter.next()) |item| {
        var subIter = item.*.valueIterator();
        while (subIter.next()) |subItem| {
            var tempIter = item.*.valueIterator();
            while (tempIter.next()) |tempItem| {
                if (tempItem.*[0] == subItem.*[0] and tempItem.*[1] == subItem.*[1]) continue;
                var i: isize = 0;
                var a = tempItem.*;
                while (a[0] > -1 and a[0] < SIZE and a[1] > -1 and a[1] < SIZE) : (i += 1) {
                    try nodeMap.put(a[0] * 100 + a[1], {});
                    a = tempItem.* + (tempItem.* - subItem.*) * @as(@Vector(2, isize), @splat(i));
                }
                i = 0;
                var b = subItem.*;
                while (b[0] > -1 and b[0] < SIZE and b[1] > -1 and b[1] < SIZE) : (i += 1) {
                    try nodeMap.put(b[0] * 100 + b[1], {});
                    b = subItem.* + (subItem.* - tempItem.*) * @as(@Vector(2, isize), @splat(i));
                }
            }
        }
    }
    var c: usize = 0;
    var nodeIter = nodeMap.iterator();
    while (nodeIter.next()) |_| {
        c += 1;
    }
    std.log.debug("d8 q2: {d}", .{c});
}

fn getMap(allocator: std.mem.Allocator) !std.AutoHashMap(u8, std.AutoHashMap(usize, @Vector(2, isize))) {
    var file = try readDayFile(8);
    defer file.close();
    var map = std.AutoHashMap(u8, std.AutoHashMap(usize, @Vector(2, isize))).init(allocator);
    var i: usize = 0;
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        for (line, 0..) |c, j| {
            if (c == '.') continue;
            const result = try map.getOrPut(c);
            if (!result.found_existing) {
                result.value_ptr.* = std.AutoHashMap(usize, @Vector(2, isize)).init(allocator);
            }
            try result.value_ptr.*.put(j * 100 + i, .{ @intCast(j), @intCast(i) });
        }
        i += 1;
    }
    return map;
}
