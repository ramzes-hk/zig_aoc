const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

pub fn d9() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var file = try readDayFile(9);
    defer file.close();
    var line: [20001]u8 = undefined;
    const len = try file.read(&line) - 1;
    var arr = try allocator.alloc(u8, len);
    defer allocator.free(arr);
    for (0..len) |i| {
        arr[i] = try std.fmt.parseInt(u8, line[i .. i + 1], 10);
    }

    var sum: u64 = 0;
    var i: usize = 0;
    var j: usize = len - 1;
    var idx: u64 = 0;
    while (i < len and i <= j) : (i += 1) {
        if (@mod(i, 2) == 0) {
            for (0..arr[i]) |_| {
                sum += i / 2 * idx;
                idx += 1;
                std.log.debug("{d}", .{i / 2});
            }
            continue;
        }
        for (0..arr[i]) |_| {
            while (arr[j] == 0 or @mod(j, 2) == 1) {
                j -= 1;
            }
            sum += j / 2 * idx;
            idx += 1;
            arr[j] -= 1;
            std.log.debug("{d}", .{j / 2});
        }
    }
    std.log.debug("d9 q1: {d}", .{sum});
}

pub fn d9_q2(allocator: std.mem.Allocator) !void {
    var file = try readDayFile(9);
    defer file.close();
    var line: [20001]u8 = undefined;
    const len = try file.read(&line) - 1;
    var arr = try allocator.alloc(u8, len);
    defer allocator.free(arr);
    for (0..len) |i| {
        arr[i] = try std.fmt.parseInt(u8, line[i .. i + 1], 10);
    }

    var sum: u64 = 0;
    var idx: u64 = 0;
    for (0..len) |i| {
        if (@mod(i, 2) == 0) {
            for (0..arr[i]) |_| {
                sum += i / 2 * idx;
                std.log.debug("{d} {d}", .{ i / 2, idx });
                idx += 1;
            }
            if (arr[i] == 0) {
                const num = try std.fmt.parseInt(u8, line[i .. i + 1], 10);
                idx += num;
            }
            continue;
        }
        var j: usize = len - 1;
        while (j > i and arr[i] > 0) {
            while ((arr[j] > arr[i] or arr[j] == 0) and j > i) {
                j -= 2;
            }
            if (j <= i) break;
            for (0..arr[j]) |_| {
                sum += j / 2 * idx;
                arr[i] -= 1;
                std.log.debug("{d} {d}", .{ j / 2, idx });
                idx += 1;
            }
            arr[j] = 0;
        }
        idx += arr[i];
    }
    std.log.debug("d9 q2: {d}", .{sum});
}
