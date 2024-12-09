const std = @import("std");

pub fn readDayFile(day: i64) !std.fs.File {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const path = try std.fmt.allocPrint(allocator, "./input/d{d}.txt", .{day});
    defer allocator.free(path);
    return std.fs.cwd().openFile(path, .{});
}
