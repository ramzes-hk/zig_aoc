const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

pub fn d13(allocator: std.mem.Allocator) !void {
    const rules = try getRules(allocator);
    defer rules.deinit();

    var sum: i64 = 0;
    for (rules.items) |item| {
        const det = item.a[0] * item.b[1] - item.a[1] * item.b[0];
        if (det == 0) {
            std.log.debug("{any}", .{item});
            @panic("determinant is 0");
        }
        const a = std.math.divExact(i64, item.prize[0] * item.b[1] - item.prize[1] * item.b[0], det) catch {
            continue;
        };
        const b = std.math.divExact(i64, item.prize[1] * item.a[0] - item.prize[0] * item.a[1], det) catch {
            continue;
        };
        if (a < 0 or b < 0) {
            std.log.debug("{any}", .{item});
            continue;
        }
        sum += a * 3 + b;
    }
    std.log.debug("d13 q1: {d}", .{sum});
}

pub fn d13_q2(allocator: std.mem.Allocator) !void {
    const rules = try getRules(allocator);
    defer rules.deinit();

    var sum: i64 = 0;
    for (rules.items) |item| {
        const prize_a = item.prize[0] + 10000000000000;
        const prize_b = item.prize[1] + 10000000000000;
        const det = item.a[0] * item.b[1] - item.a[1] * item.b[0];
        if (det == 0) {
            std.log.debug("{any}", .{item});
            @panic("determinant is 0");
        }
        const a = std.math.divExact(i64, prize_a * item.b[1] - prize_b * item.b[0], det) catch {
            std.log.debug("{any}", .{item});
            continue;
        };
        const b = std.math.divExact(i64, prize_b * item.a[0] - prize_a * item.a[1], det) catch {
            std.log.debug("{any}", .{item});
            continue;
        };
        if (a < 0 or b < 0) {
            std.log.debug("{any}", .{item});
            continue;
        }
        sum += a * 3 + b;
    }
    std.log.debug("d13 q2: {d}", .{sum});
}
fn confirmResult(item: Machine, a: i64, b: i64) bool {
    if (a > 0 and b > 0) return true;
    if (a * item.a[0] + b * item.b[0] == item.prize[0]) return true;
    if (a * item.a[1] + b * item.b[1] == item.prize[1]) return true;
    std.log.debug("wrong {any}", .{item});
    return false;
}

const Machine = struct {
    a: [2]i64,
    b: [2]i64,
    prize: [2]i64,
};

fn getRules(allocator: std.mem.Allocator) !std.ArrayList(Machine) {
    var file = try readDayFile(13);
    defer file.close();
    var arr = std.ArrayList(Machine).init(allocator);

    outer: while (true) {
        var machine: Machine = undefined;
        for (0..4) |i| {
            const line = file.reader().readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize)) catch {
                try arr.append(machine);
                break :outer;
            };
            defer allocator.free(line);
            if (i == 0 or i == 1) {
                const x = try std.fmt.parseInt(i64, line[12..14], 10);
                const y = try std.fmt.parseInt(i64, line[18..20], 10);
                if (i == 0) {
                    machine.a = .{ x, y };
                } else {
                    machine.b = .{ x, y };
                }
            } else if (i == 2) {
                var j: usize = 0;
                var temp: usize = 0;
                while (line[j] != '=') {
                    j += 1;
                }
                j += 1;
                temp = j;
                while (line[j] != ',') {
                    j += 1;
                }
                const x = try std.fmt.parseInt(i64, line[temp..j], 10);
                while (line[j] != '=') {
                    j += 1;
                }
                j += 1;
                temp = j;
                while (j < line.len) {
                    j += 1;
                }
                const y = try std.fmt.parseInt(i64, line[temp..j], 10);
                machine.prize = .{ x, y };
            }
        }
        try arr.append(machine);
    }
    return arr;
}
