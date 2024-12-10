const std = @import("std");
const readDayFile = @import("./utils.zig").readDayFile;

pub fn d3() !void {
    const file = try readDayFile(3);
    defer file.close();
    var sum: i64 = 0;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        for (0..line.len - 8) |i| {
            if (!std.mem.eql(u8, line[i .. i + 4], "mul(")) {
                continue;
            }
            const firstNum = i + 4;
            var period = firstNum;
            while (line[period] != ',') {
                period += 1;
                if (period > firstNum + 2) {
                    break;
                }
            }
            const a = std.fmt.parseInt(i64, line[firstNum..period], 10) catch 0;
            if (a != 0) {
                var secondNum = period + 1;
                while (line[secondNum] != ')') {
                    secondNum += 1;
                    if (secondNum > period + 3) {
                        break;
                    }
                }
                if (line[secondNum] == ')') {
                    const b = std.fmt.parseInt(i64, line[period + 1 .. secondNum], 10) catch 0;
                    std.log.err("{s} {s}", .{ line[firstNum..period], line[period + 1 .. secondNum] });
                    sum += b * a;
                }
            }
        }
    }
    std.log.err("d3 q1: {d}", .{sum});
}

pub fn d3_q2() !void {
    const file = try readDayFile(3);
    defer file.close();
    var sum: i64 = 0;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var enabled: bool = true;

    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        for (0..line.len - 8) |i| {
            if (std.mem.eql(u8, line[i .. i + 4], "do()")) {
                enabled = true;
                continue;
            } else if (std.mem.eql(u8, line[i .. i + 7], "don't()")) {
                enabled = false;
                continue;
            }
            if (!enabled) continue;
            if (!std.mem.eql(u8, line[i .. i + 4], "mul(")) {
                continue;
            }
            const firstNum = i + 4;
            var period = firstNum;
            while (line[period] != ',') {
                period += 1;
                if (period > firstNum + 2) {
                    break;
                }
            }
            const a = std.fmt.parseInt(i64, line[firstNum..period], 10) catch 0;
            if (a != 0) {
                var secondNum = period + 1;
                while (line[secondNum] != ')') {
                    secondNum += 1;
                    if (secondNum > period + 3) {
                        break;
                    }
                }
                if (line[secondNum] == ')') {
                    const b = std.fmt.parseInt(i64, line[period + 1 .. secondNum], 10) catch 0;
                    std.log.err("{s} {s}", .{ line[firstNum..period], line[period + 1 .. secondNum] });
                    sum += b * a;
                }
            }
        }
    }
    std.log.err("d3 q2: {d}", .{sum});
}
