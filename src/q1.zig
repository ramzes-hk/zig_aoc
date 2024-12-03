const std = @import("std");

pub fn q1() !void {
    var a: [1000]i64 = undefined;
    var b: [1000]i64 = undefined;

    const file = try std.fs.cwd().openFile("./input/d1.txt", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{ .thread_safe = true }){};
    const allocator = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) {
            std.log.err("memory leak", .{});
        }
    }
    var i: usize = 0;
    while (file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize)) catch |err| {
        std.log.err("failed to read line: {s}", .{@errorName(err)});
        return;
    }) |line| {
        defer allocator.free(line);
        var numbers = std.mem.tokenizeScalar(u8, line, ' ');
        const n1 = try std.fmt.parseInt(i64, numbers.next().?, 10);
        const n2 = try std.fmt.parseInt(i64, numbers.next().?, 10);
        a[i] = n1;
        b[i] = n2;
        i += 1;
    }
    std.sort.heap(i64, &a, {}, comptime std.sort.asc(i64));
    std.sort.heap(i64, &b, {}, comptime std.sort.asc(i64));
    var sum: u64 = 0;
    for (0..1000) |j| {
        sum += @abs(a[j] - b[j]);
    }
    std.log.err("{d}", .{sum});
}

pub fn q1_part() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var map_a = std.hash_map.AutoHashMap(i64, i64).init(allocator);
    defer map_a.deinit();

    var map_b = std.hash_map.AutoHashMap(i64, i64).init(allocator);
    defer map_b.deinit();

    const file = try std.fs.cwd().openFile("./input/d1.txt", .{});
    defer file.close();

    while (file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize)) catch |err| {
        std.log.err("failed to read line: {s}", .{@errorName(err)});
        return;
    }) |line| {
        defer allocator.free(line);
        var numbers = std.mem.tokenizeScalar(u8, line, ' ');
        const n1 = try std.fmt.parseInt(i64, numbers.next().?, 10);
        const n2 = try std.fmt.parseInt(i64, numbers.next().?, 10);
        const count_a = map_a.get(n1) orelse 0;
        const count_b = map_b.get(n2) orelse 0;
        try map_a.put(n1, count_a + 1);
        try map_b.put(n2, count_b + 1);
    }
    var sum: i64 = 0;
    var iterator_a = map_a.iterator();
    while (iterator_a.next()) |entry| {
        const c_b = map_b.get(entry.key_ptr.*) orelse 0;
        sum += entry.key_ptr.* * entry.value_ptr.* * c_b;
    }
    std.log.err("{d}", .{sum});
}
