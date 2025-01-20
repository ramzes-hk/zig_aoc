const std = @import("std");
const readDayFile = @import("utils.zig").readDayFile;

pub fn d19(allocator: std.mem.Allocator) !void {
    const towelPattern = try getTowels(allocator);
    const towels = towelPattern.towels;
    const patterns = towelPattern.patterns;
    defer {
        @constCast(&towels).deinit(allocator);
        for (patterns.items) |item| {
            allocator.free(item);
        }
        patterns.deinit();
    }
    var res: u64 = 0;
    for (patterns.items) |item| {
        if (recurse(item, &towels, 0, &towels)) res += 1;
    }
    std.log.debug("d19 q1: {d}", .{res});
}

fn recurse(pattern: []const u8, node: *const Node, pos: usize, head: *const Node) bool {
    if (pos == pattern.len) {
        return node.value;
    }
    const idx = getIndex(pattern[pos]);
    if (node.children[idx]) |val| {
        if (val.value) {
            if (recurse(pattern, head, pos + 1, head)) return true;
        }
        if (recurse(pattern, val, pos + 1, head)) return true;
    }
    return false;
}

const Letter = enum(usize) {
    w,
    u,
    b,
    r,
    g,
};

const Node = struct {
    children: [5]?*Node,
    value: bool,
    fn init() Node {
        return Node{
            .children = .{null} ** 5,
            .value = false,
        };
    }
    fn deinit(self: *Node, allocator: std.mem.Allocator) void {
        for (&self.children) |*child| {
            if (child.*) |node| {
                node.deinit(allocator);
                allocator.destroy(node);
            }
        }
    }
};

const TowelPatterns = struct {
    towels: Node,
    patterns: std.ArrayList([]const u8),
};

fn getIndex(char: u8) usize {
    return switch (char) {
        'w' => 0,
        'u' => 1,
        'b' => 2,
        'r' => 3,
        'g' => 4,
        else => unreachable,
    };
}

fn findNode(noalias head: *Node, key: []const u8) bool {
    var current = head;
    for (key) |c| {
        const idx = getIndex(c);
        if (current.children[idx]) |child| {
            current = child;
        } else {
            return false;
        }
    }
    return current.value;
}

fn insertNode(allocator: std.mem.Allocator, noalias head: *Node, key: []const u8) !void {
    var current = head;
    for (key) |c| {
        const idx = getIndex(c);
        if (current.children[idx]) |child| {
            current = child;
        } else {
            const newNode = try allocator.create(Node);
            newNode.* = Node.init();
            newNode.value = false;
            current.children[idx] = newNode;
            current = newNode;
        }
    }
    current.value = true;
}

test "trie" {
    const allocator = std.testing.allocator;
    var head = Node.init();
    std.debug.print("{any}\n", .{head});
    try insertNode(allocator, &head, "bwuug");
    try std.testing.expect(findNode(&head, "bwuug"));
    try std.testing.expect(!findNode(&head, "bwwwwww"));
    head.deinit(allocator);
}

fn getTowels(allocator: std.mem.Allocator) !TowelPatterns {
    var file = try readDayFile(19);
    defer file.close();
    var towels = Node.init();
    var patterns = std.ArrayList([]const u8).init(allocator);
    const firstLine = try file.reader().readUntilDelimiterAlloc(allocator, '\n', std.math.maxInt(usize));
    defer allocator.free(firstLine);
    var tokens = std.mem.tokenizeAny(u8, firstLine, " ,");
    while (tokens.next()) |token| {
        if (!filterW(token)) continue;
        try insertNode(allocator, &towels, token);
    }
    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize))) |line| {
        if (line.len == 0) continue;
        try patterns.append(line);
    }
    return TowelPatterns{ .patterns = patterns, .towels = towels };
}

fn filterW(str: []const u8) bool {
    var containsW = false;
    for (str) |c| {
        if (c == 'w') {
            containsW = true;
            break;
        }
    }
    return containsW or str.len == 1;
}
