const std = @import("std");
const openDayFile = @import("./utils.zig").readDayFile;

pub fn q2() !void {
    const file = try openDayFile(2);
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var sum: i64 = 0;
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        var last: ?i64 = null;
        var j: usize = 0;
        var dec: ?bool = null;
        var faulty: bool = true;
        for (line, 0..) |char, i| {
            if (char == ' ' or i + 1 == line.len) {
                if (j == i) continue;
                var k = i;
                if (i + 1 == line.len) k += 1;
                const current = std.fmt.parseInt(i64, line[j..k], 10) catch |err| {
                    std.log.err("{s} j={d} i={d}", .{ line[j..k], j, k });
                    return err;
                };
                if (last != null) {
                    const diff = current - last.?;
                    const isDec = diff < 0;
                    const abs_diff = @abs(diff);
                    if (abs_diff > 3 or abs_diff < 1) {
                        faulty = false;
                        break;
                    }
                    if (dec != null and (isDec != dec.?)) {
                        faulty = false;
                        break;
                    }
                    if (dec == null) {
                        dec = isDec;
                    }
                }
                last = current;
                j = i + 1;
            }
        }
        if (faulty == true) {
            sum += 1;
        }
    }
    std.log.err("day2 q1:{d}", .{sum});
}

pub fn d2_q2() !void {
    const file = try openDayFile(2);
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var sum: i64 = 0;
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        var j: usize = 0;
        var length: usize = 1;
        for (line) |char| {
            if (char == ' ') length += 1;
        }
        var arr_fat: [10]i64 = undefined;
        var arr = arr_fat[0..length];
        var pos: usize = 0;
        for (line, 0..) |char, i| {
            if (char == ' ' or i + 1 == line.len) {
                var k: usize = i;
                if (i + 1 == line.len) k += 1;
                const number = try std.fmt.parseInt(i64, line[j..k], 10);
                arr[pos] = number;
                pos += 1;
                j = i + 1;
            }
        }
        var f_counter: usize = 0;
        for (0..length) |skip| {
            var dec: ?bool = null;
            const result = try std.mem.concat(allocator, i64, &[_][]const i64{ arr[0..skip], arr[skip + 1 .. length] });
            defer allocator.free(result);
            for (0..result.len - 1) |idx| {
                const diff = result[idx + 1] - result[idx];
                const abs_diff = @abs(diff);
                const isDec = diff < 0;
                if (abs_diff > 3 or abs_diff < 1) {
                    f_counter += 1;
                    break;
                }
                if (dec != null and dec != isDec) {
                    f_counter += 1;
                    break;
                }
                if (dec == null) dec = isDec;
            }
            if (f_counter <= skip) {
                f_counter = 0;
                break;
            }
        }
        if (f_counter < length) {
            sum += 1;
        } else {
            std.log.err("wrong: {any}", .{arr});
        }
    }
    std.log.err("d2 q2: {d}", .{sum});
}
