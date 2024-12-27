const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

const Equation = struct {
    lhs: u128,
    rhs: std.ArrayList(u128),
};

pub fn d7() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var list = try getEquations(allocator);
    defer {
        for (list.items) |item| {
            item.rhs.deinit();
        }
        list.deinit();
    }
    var sum: i64 = 0;
    for (list.items) |eq| {
        const len: u6 = @intCast(eq.rhs.items.len);
        var j: i64 = (@as(i64, 1) << len) - 1;
        while (j > -1) : (j -= 1) {
            var i: u6 = 1;
            var c: i64 = eq.rhs.items[0];
            while (i < len) : (i += 1) {
                if ((j >> i) & 1 == 1) {
                    c *= eq.rhs.items[@intCast(i)];
                } else {
                    c += eq.rhs.items[@intCast(i)];
                }
            }
            if (c == eq.lhs) {
                sum += eq.lhs;
                break;
            }
        }
    }
    std.log.debug("d7 q1: {d}", .{sum});
}

fn countDigits(allocator: std.mem.Allocator, a: u128, map: *std.AutoHashMap(u128, u128)) !u128 {
    const res = try map.getOrPut(a);
    if (res.found_existing) {
        return res.value_ptr.*;
    }
    const str = try std.fmt.allocPrint(allocator, "{d}", .{a});
    defer allocator.free(str);
    res.value_ptr.* = str.len;
    return str.len;
}

pub fn d7_q2() !void {
    const nums = [_]u128{ 0, 1, 2 };
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var list = try getEquations(allocator);
    defer {
        for (list.items) |item| {
            item.rhs.deinit();
        }
        list.deinit();
    }
    var sum: u128 = 0;
    for (list.items) |eq| {
        var map = std.AutoHashMap(u128, u128).init(allocator);
        defer map.deinit();
        var i: usize = 0;
        const len = eq.rhs.items.len;
        while (i < std.math.pow(usize, nums.len, len - 1)) : (i += 1) {
            var c: u128 = eq.rhs.items[0];
            var temp = i;
            for (1..len) |j| {
                const next_num = eq.rhs.items[j];
                const cur = nums[temp % nums.len];
                temp /= nums.len;
                switch (cur) {
                    0 => c += next_num,
                    1 => c *= next_num,
                    else => c = std.math.pow(u128, 10, try countDigits(allocator, next_num, &map)) * c + next_num,
                }
            }
            if (c == eq.lhs) {
                sum += c;
                break;
            }
        }
    }
    std.log.debug("d7 q2: {d}", .{sum});
}

fn getEquations(allocator: std.mem.Allocator) !std.ArrayList(Equation) {
    var list = std.ArrayList(Equation).init(allocator);
    const file = try readDayFile(7);
    defer file.close();
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        var eq = std.mem.tokenizeAny(u8, line, " :");
        const lhs = try std.fmt.parseInt(u128, eq.next().?, 10);
        var rhs = std.ArrayList(u128).init(allocator);
        while (eq.next()) |val| {
            const num = try std.fmt.parseInt(u128, val, 10);
            try rhs.append(num);
        }
        try list.append(.{ .lhs = lhs, .rhs = rhs });
    }
    return list;
}
