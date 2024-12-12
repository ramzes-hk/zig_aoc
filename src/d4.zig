const std = @import("std");
const readDayFile = @import("./utils.zig").readDayFile;

const dirs = [_][2]isize{ [_]isize{ 0, 1 }, [_]isize{ 1, 1 }, [_]isize{ 1, 0 }, [_]isize{ 0, -1 }, [_]isize{ -1, -1 }, [_]isize{ -1, 0 }, [_]isize{ -1, 1 }, [_]isize{ 1, -1 } };
const XMAS = "XMAS";
const SIZE = 140;

pub fn q4() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const lines = try get_grid(allocator);
    var sum: i64 = 0;

    for (0..SIZE) |i| {
        for (0..SIZE) |j| {
            dir_label: for (dirs) |dir| {
                const x: isize = @intCast(j);
                const y: isize = @intCast(i);
                const s_x = x + dir[0] * 3;
                if (s_x < 0 or s_x > SIZE - 1) continue;
                const s_y = y + dir[1] * 3;
                if (s_y < 0 or s_y > SIZE - 1) continue;
                for (0..4) |d_| {
                    const d: isize = @intCast(d_);
                    const n_x = x + dir[0] * d;
                    const n_y = y + dir[1] * d;
                    if (lines[@intCast(n_y)][@intCast(n_x)] != XMAS[d_]) continue :dir_label;
                }
                sum += 1;
            }
        }
    }
    std.log.err("d4 q1: {d}", .{sum});
}

pub fn d4_q2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const lines = try get_grid(allocator);
    var sum: i64 = 0;

    for (1..SIZE - 1) |i| {
        for (1..SIZE - 1) |j| {
            if (lines[i][j] != 'A') continue;
            const top_r = lines[i - 1][j + 1];
            const bot_l = lines[i + 1][j - 1];
            const top_l = lines[i - 1][j - 1];
            const bot_r = lines[i + 1][j + 1];
            if ((top_r == 'M' and bot_l == 'S') or (top_r == 'S' and bot_l == 'M')) {
                if ((top_l == 'M' and bot_r == 'S') or (top_l == 'S' and bot_r == 'M')) sum += 1;
            }
        }
    }
    std.log.debug("d4 q2: {d}", .{sum});
}

fn get_grid(allocator: std.mem.Allocator) !*[SIZE][SIZE]u8 {
    const file = try readDayFile(4);
    defer file.close();
    var lines: [SIZE][SIZE]u8 = .{.{0} ** SIZE} ** SIZE;
    var k: usize = 0;
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        defer allocator.free(line);
        @memcpy(&lines[k], line);
        k += 1;
    }
    return &lines;
}
