const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

pub fn d11(allocator: std.mem.Allocator) !void {
    const line = try getLine(allocator);
    defer allocator.free(line);
    var countDigitCache = std.AutoHashMap(u64, u64).init(allocator);
    defer countDigitCache.deinit();

    var sum: u64 = 0;
    for (line) |n| {
        sum += try recursion(allocator, n, 0, &countDigitCache);
    }
    std.log.debug("d11 q1: {d}", .{sum});
}

const Node = struct {
    val: u64,
    parent: *Node,
    rchild: *Node,
    lchild: *Node,
    child_n: u64,
};

pub fn d11_q2(allocator: std.mem.Allocator) !void {
    const line = try getLine(allocator);
    defer allocator.free(line);
    var countDigitCache = std.AutoHashMap(u64, u64).init(allocator);
    defer countDigitCache.deinit();
    var resultCache = std.AutoHashMap(u64, *Node).init(allocator);
    
    var sum: u64 = 0;
    for (line) |n| {
        
    }
}

fn recursion_q2(allocator: std.mem.Allocator, n: u64, iter: u64, countDigitCache: std.AutoHashMap(u64, u64), resultCahce: std.AutoHashMap(u64, *Node)) !u64 {
    if (iter == 75) return 1;
    
}


fn cntDigits(n: u64, cache: *std.AutoHashMap(u64, u64)) !u64 {
    if (cache.get(n)) |val| {
        return val;
    }
    inline for (1..18) |i| {
        const ref = std.math.pow(u64, 10, i);
        if (n < ref) {
            try cache.put(n, i);
            return i;
        }
    }
    return 0;
}

fn countDigits(allocator: std.mem.Allocator, n: u64, cache: *std.AutoHashMap(u64, u64)) !u64 {
    inline for (1..18) |i| {
        const ref = std.math.pow(u64, 10, i);
        if (n < ref) {
            return i;
        }
    }
    const res = try cache.getOrPut(n);
    if (res.found_existing) {
        return res.value_ptr.*;
    }
    const line = try std.fmt.allocPrint(allocator, "{d}", .{n});
    res.value_ptr.* = line.len;
    defer allocator.free(line);
    return line.len;
}

fn recursion(allocator: std.mem.Allocator, n: u64, iter: usize, countDigitCache: *std.AutoHashMap(u64, u64)) !u64 {
    if (iter == 25) return 1;
    var sum: u64 = 0;
    if (n == 0) {
        sum += try recursion(allocator, 1, iter + 1, countDigitCache);
    } else if (@mod(try countDigits(allocator, n, countDigitCache), 2) == 0) {
        const num = try std.fmt.allocPrint(allocator, "{d}", .{n});
        defer allocator.free(num);
        const a = try std.fmt.parseInt(u64, num[0 .. num.len / 2], 10);
        const b = try std.fmt.parseInt(u64, num[num.len / 2 .. num.len], 10);
        sum += try recursion(allocator, a, iter + 1, countDigitCache);
        sum += try recursion(allocator, b, iter + 1, countDigitCache);
    } else {
        sum += try recursion(allocator, n * 2024, iter + 1, countDigitCache);
    }
    return sum;
}

fn getLine(allocator: std.mem.Allocator) ![]u64 {
    var file = try readDayFile(11);
    defer file.close();
    const line = try file.reader().readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
    defer allocator.free(line);
    var len: usize = 1;
    for (line) |c| {
        if (c == ' ') len += 1;
    }
    var arr = try allocator.alloc(u64, len);
    var nums = std.mem.tokenizeAny(u8, line, " ");
    var i: usize = 0;
    while (nums.next()) |n| {
        arr[i] = try std.fmt.parseInt(u64, n, 10);
        i += 1;
    }
    return arr;
}
